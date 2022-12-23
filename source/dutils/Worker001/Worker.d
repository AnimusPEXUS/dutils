module dutils.Worker001.Worker;

import core.sync.mutex;
import core.sync.condition;

import std.parallelism;

import dlgo;

enum WorkerStatus : ubyte
{
    stopped,
    starting,
    working,
    stopping
}

struct EmptyStruct
{
}

alias WorkerControlChanResult = Chan!EmptyStruct;
alias WaitExitResult = Chan!EmptyStruct;

interface Worker001I
{
    WorkerControlChanResult start();
    WorkerControlChanResult stop();
    WorkerControlChanResult restart();
    WorkerStatus getStatus();
    WaitExitResult wait();

    // those two not needed, as dutils using dlgo channels implementation
    // WaitExitResult wait(Duration timeout);
    // WaitExitResult wait(DateTime endTime);
}

// dfmt keeps deformating it to single line
alias WorkerThreadFunction = void delegate(
    void delegate() set_starting,
    void delegate() set_working,
    void delegate() set_stopping,
    void delegate() set_stopped,
    bool delegate() is_stop_flag
);

class Worker001 : Worker001I
{
    private
    {
        WorkerStatus status;

        bool stop_flag;

        WorkerThreadFunction thread_func;

        Mutex start_stop_mutex;
        Mutex wait_lock;
        Condition wait_cond;
    }

    this(WorkerThreadFunction thread_func)
    {
        this.status = WorkerStatus.stopped;
        this.thread_func = thread_func;

        this.start_stop_mutex = new Mutex();
        this.wait_lock = new Mutex();
        this.wait_cond = new Condition(this.wait_lock);
    }

    WorkerControlChanResult start()
    {
        auto ret = new Chan!WorkerControlChanResult(1);
        task(delegate void() {
            synchronized (this.start_stop_mutex)
            {
                if (status == WorkerStatus.stopped)
                {
                    this.status = WorkerStatus.starting;
                    this.stop_flag = false;

                    task(delegate void() {

                        scope (exit)
                        {
                            this.stop_flag = true;
                            this.wait_cond.notifyAll();
                            this.status = WorkerStatus.stopped;
                        }
                    }).executeInNewThread();
                }
                ret.push(EmptyStruct());
            }
        }).executeInNewThread();
        return ret;
    }

    WorkerControlChanResult stop()
    {
        auto ret = new Chan!WorkerControlChanResult(1);
        task(delegate void() {
            synchronized (this.start_stop_mutex)
            {
                this.stop_flag = true;
                ret.push(EmptyStruct());
            }
        }).executeInNewThread();
        return ret;
    }

    WorkerControlChanResult restart()
    {
        auto ret = new Chan!WorkerControlChanResult(1);
        task(delegate void() {
            synchronized (this.start_stop_mutex)
            {
                this.stop().pull();
                this.start().pull();
                ret.push(EmptyStruct());
            }
        }).executeInNewThread();
        return ret;
    }

    WaitExitResult wait()
    {
        auto ret = new Chan!WaitExitResult(1);
        if (this.status == WorkerStatus.stopped)
        {
            ret.push(EmptyStruct());
        }
        else
        {
            task(delegate void() {

                scope (exit)
                {
                    ret.push(EmptyStruct());
                }
                this.wait_cond.Wait();

            }).executeInNewThread();
        }
        return ret;
    }

    WorkerStatus getStatus()
    {
        synchronized (this.status)
        {
            return this.status;
        }
    }

    private void setStatus(WorkerStatus val)
    {
        synchronized (this.status)
        {
            this.status = val;
        }
    }
}
