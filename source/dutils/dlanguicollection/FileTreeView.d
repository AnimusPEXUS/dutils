module dutils.dlanguicollection.FileTreeView;

import std.path;
import std.file;
import std.algorithm;
import std.stdio;
import std.typecons;

import dlangui;

import dutils.path;

class FileTreeView
{

    private
    {
        TreeWidget tv;

        string rootDir;
        bool showHidden;
    }

    public
    {
        // NOTE: simple callback for simplicity
        void delegate(TreeItem ti) itemActivated;
    }

    this()
    {
        tv = new TreeWidget("");
        tv.selectionChange = &onTreeItemSelected;

        setRootDirectory(expandTilde("~"));
    }

    TreeWidget getWidget()
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

    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated)
    {
        debug
        {
            writeln("selected " ~ to!string(
                    selectedItem.text) ~ " activated: " ~ to!string(activated));
        }

        if (!activated)
        {
            return;
        }

        if (itemActivated == null)
        {
            return;
        }

        itemActivated(selectedItem);
    }

    Tuple!(bool, bool) isFile(T)(T value) if (isSomeString(T))
    {
        return !isDir(value);
    }

    // result (ok?, yes?)
    Tuple!(bool, bool) isDir(dstring path)
    {
        auto t = dutils.path.split(to!string(path));

        TreeItem tti = tv.items;

        main_loop: for (int i = 0; i != t.length; i++)
        {
            for (int j = 0; j != tti.childCount; j++)
            {
                auto tticj = tti.child(j);
                if (to!string(tticj.text) == (t[i] ~ "/"))
                {
                    tti = tticj;
                    continue main_loop;
                }
            }

            if (i == t.length - 1)
            {
                return tuple(true, false);
            }
            else
            {
                return tuple(false, false);
            }
        }

        return tuple(true, true);
    }

    // result (ok?, yes?)
    Tuple!(bool, bool) isDir(string path)
    {
        return isDir(to!dstring(path));
    }

    // result (yes?)
    bool isFile(TreeItem value)
    {
        return !isDir(value);
    }

    // result (yes?)
    bool isDir(TreeItem value)
    {
        return value.text.endsWith("/"d);
    }

    void loadByTreeItem(TreeItem value)
    {
        auto pth = convertTreeItemToFilePath(value);
        pth = dutils.path.join([rootDir, pth]);
        if (std.file.isDir(pth))
        {
            loadDir(value, pth);
        }
    }

    void expandByTreeItem(TreeItem value)
    {
        value.expand();
    }

    // NOTE: this doesn't prepends root path before result
    string convertTreeItemToFilePath(TreeItem value)
    {
        string[] path_items;

        do
        {
            auto valuet = to!string(value.text);
            path_items = (valuet.endsWith("/") ? valuet[0 .. $ - 1] : valuet) ~ path_items;
            value = value.parent;
        }
        while (value !is null);

        string ret = dutils.path.join(path_items);
        return ret;
    }

    void refresh()
    {
        /* auto m = tv.getModel(); */
        loadDir(tv.items, rootDir);
    }

    void loadDir(TreeItem itera, string path)
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

        // TODO: remove only really missing files
        itera.clear();

        /* {
            TreeIter chi = new TreeIter;

            bool res = m.iterChildren(chi, itera);

            // TODO: remove only really missing files
            while (res)
            {
                res = (cast(TreeStore) m).remove(chi);
            }
        } */

        foreach (i; lst_dirs)
        {
            itera.newChild("", to!dstring(i ~ '/'));
        }

        foreach (i; lst_files)
        {
            itera.newChild("", to!dstring(i));
        }

    }

}
