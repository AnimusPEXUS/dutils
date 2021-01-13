module dutils.gtkcollection.FileTreeView;

import std.path;
import std.file;
import std.algorithm;
import std.stdio;

/* import std.stdio; */

import gtk.TreeView;
import gtk.ScrolledWindow;
import gtk.TreeStore;
import gtk.TreeModelIF;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.TreePath;
import gtk.CellRendererPixbuf;
import gtk.CellRendererText;

import gtk.c.types;
import gobject.Value;

import dutils.path;

class FileTreeView
{

    private
    {
        TreeView tv;
        ScrolledWindow tv_sw;
        TreeStore ts;

        string rootDir;
        bool showHidden;
    }

    this()
    {
        ts = new TreeStore(cast(GType[])[GType.STRING, GType.STRING]);

        tv = new TreeView();
        tv_sw = new ScrolledWindow();
        tv_sw.add(tv);

        tv.setModel(ts);

        tv.setHeadersVisible(false);
        tv.setSearchColumn(1);

        {
            auto c = new TreeViewColumn();
            auto r = new CellRendererPixbuf();
            c.packStart(r, false);
            c.addAttribute(r, "icon-name", 0);
            tv.appendColumn(c);
        }

        {
            auto c = new TreeViewColumn();
            auto r = new CellRendererText();
            c.packStart(r, false);
            c.addAttribute(r, "text", 1);
            tv.appendColumn(c);
        }

        setRootDirectory(expandTilde("~"));
    }

    ScrolledWindow getWidget()
    {
        return tv_sw;
    }

    TreeView getTreeView()
    {
        return tv;
    }

    void setRootDirectory(string path)
    {
        rootDir = buildNormalizedPath(path);
        refresh();
    }

    string getRootDirectory()
    {
        return rootDir;
    }

    gulong addOnRowActivated(void delegate(TreePath, TreeViewColumn,
            TreeView) dlg, ConnectFlags connectFlags = cast(ConnectFlags) 0)
    {
        return tv.addOnRowActivated(dlg, connectFlags);
    }

    /* if FileTreeView finks tp is File */
    bool isFile(TreePath tp)
    {
        return !isDir(tp); // for now. will be changed if FileTreeView will support more file types
    }

    bool isDir(TreePath tp)
    {
        TreeIter ti = new TreeIter;
        bool ok = cast(bool)(ts.getIter(ti, tp));
        if (ok)
        {
            auto value = ts.getValue(ti, 0);
            return value.getString() == "folder";
        }
        return false;
    }

    // expands directory relatively to selected root
    void expandByTreePath(TreePath tp)
    {
        auto pth = convertTreePathToFilePath(tp);
        pth = dutils.path.join([rootDir, pth]);
        if (std.file.isDir(pth))
        {
            TreeIter itr = new TreeIter;
            ts.getIter(itr, tp);
            loadDir(itr, pth);
        }
    }

    // NOTE: this doesn't adds root path before result
    string convertTreePathToFilePath(TreePath tp)
    {
        auto indices = tp.getIndices();
        string[] values;
        /* values ~= rootDir; */
        for (int i = 0; i != indices.length; i++)
        {
            TreeIter value = new TreeIter;
            auto res = ts.getIter(value, new TreePath(indices[0 .. i + 1]));
            values ~= ts.getValue(value, 1).getString();
        }
        string ret = dutils.path.join(values);
        return ret;
    }

    void refresh()
    {
        auto m = tv.getModel();
        loadDir(null, rootDir);
    }

    void loadDir(TreeIter itera, string path)
    {
        string[] lst;
        string[] lst_dirs;
        string[] lst_files;

        foreach (string i; dirEntries(path, SpanMode.shallow, false))
        {
            lst ~= baseName(i);
        }

        loop: foreach (i; lst)
        {
            auto joined = dutils.path.join(cast(string[])[path, i]);
            if (isSymlink(joined))
            {
                {

                    string link_value = readLink(joined);
                    /* string link_value_real = ""; */

                    try
                    {
                        // TODO: impliment and use realPath() function
                        auto t = new DirEntry(link_value);
                    }
                    catch (std.file.FileException)
                    {
                        lst_files ~= i;
                        continue loop;
                    }

                }
            }

            if (std.file.isDir(joined))
            {
                lst_dirs ~= i;
            }
            else
            {
                lst_files ~= i;
            }

        }

        lst_dirs.sort();
        lst_files.sort();

        auto m = tv.getModel();

        {
            TreeIter chi = new TreeIter;

            bool res = m.iterChildren(chi, itera);

            // TODO: remove only really missing files
            while (res)
            {
                res = (cast(TreeStore) m).remove(chi);
            }
        }

        foreach (i; lst_dirs)
        {
            TreeIter new_iter = new TreeIter;
            (cast(TreeStore) m).append(new_iter, itera);
            (cast(TreeStore) m).setValuesv(new_iter, [0, 1], [
                    new Value("folder"), new Value(i)
                    ]);
        }

        foreach (i; lst_files)
        {
            TreeIter new_iter = new TreeIter;
            (cast(TreeStore) m).append(new_iter, itera);
            (cast(TreeStore) m).setValuesv(new_iter, [0, 1], [
                    new Value("txt"), new Value(i)
                    ]);
        }

    }

}
