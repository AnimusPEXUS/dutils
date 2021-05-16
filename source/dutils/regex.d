module dutils.regex;

import std.regex;
import std.stdio;

const LINE_STARTS = ctRegex!("(?<=^|\n)");

version (unittest)
{
    const TEST_STRING_0 = "123test456\ntest789\n\ntest\n";
    const TEST_STRING_0_0 = "test";
}

unittest
{
    writeln("TEST_STRING_0 ", TEST_STRING_0);
}

ulong[] lineStarts(string txt)
{
    debug
    {
        writeln("lineStarts debug:");
    }

    auto x = matchAll(txt, LINE_STARTS);

    // ulong current_line = 0;

    ulong[] ret;

    foreach (m; x)
    {
        ret ~= m.pre.length + m.hit.length;
        debug
        {
            writeln("m.pre.length ", m.pre.length);
            writeln("m.hit.length ", m.hit.length);
            writef("%d: '%s'\n", m.pre.length, m.post);
        }
    }

    return ret;
}

unittest
{

}

ulong[] matchPositions(string txt, string re, ulong[] lineStarts_ = null)
{
    return matchPositions(txt, regex(re), lineStarts_);
}

ulong[] matchPositions(string txt, Regex!char re, ulong[] lineStarts_ = null)
{
    debug
    {
        writeln("matchPositions debug:");
        writeln("  searching for ", re);
        writeln("  inside of ", txt);
    }

    if (lineStarts_ is null)
    {
        lineStarts_ = lineStarts(txt);
    }

    debug
    {
        writeln("line starts");
        foreach (size_t i, v; lineStarts_)
        {
            writeln(i, " ", v);
        }
    }

    ulong[] ret;

    foreach (m; matchAll(txt, re))
    {
        auto match_index0 = m.pre.length;
        ulong line_num = 0;
        foreach (size_t k, v; lineStarts_)
        {
            if (v <= match_index0)
            {
                line_num = k;
            }
            else
            {
                break;
            }
        }
        ret ~= line_num;
    }

    return ret;
}

unittest
{

    ulong[] lstarts;

    {
        auto x = lineStarts(TEST_STRING_0);
        lstarts = x;
        assert(x == cast(ulong[])[0, 11, 19, 20, 25]);
    }

    {
        auto x = matchPositions(TEST_STRING_0, TEST_STRING_0_0, lstarts);
        writeln("lines");
        foreach (size_t i, v; x)
        {
            writeln(i, " ", v);
        }
        assert(x == cast(ulong[])[0, 1, 3]);
    }

}
