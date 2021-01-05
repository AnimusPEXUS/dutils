module dutils.gtkcollection.FileTreeView;

import std.path;
import std.file;

import gtk.TreeView;
import gtk.TreeStore;
import gtk.TreeModelIF;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.CellRendererPixbuf;
import gtk.CellRendererText;

import gtk.c.types;
import gobject.Value;

import dutils.path;

class FileTreeView
{

    private
    {
        TreeView tw;
        TreeStore ts;

        string rootDir;
        bool showHidden;
    }

    this()
    {
        ts = new TreeStore(cast(GType[])[GType.STRING, GType.STRING]);

        tw.setHeadersVisible(false);
        tw.setSearchColumn(1);

        {
            auto c = new TreeViewColumn();
            auto r = new CellRendererPixbuf();
            c.packStart(r, false);
            c.addAttribute(r, "icon-name", 0);
            tw.appendColumn(c);
        }

        {
            auto c = new TreeViewColumn();
            auto r = new CellRendererText();
            c.packStart(r, false);
            c.addAttribute(r, "text", 1);
            tw.appendColumn(c);
        }

        setRootDirectory(expandTilde("~"));
    };

    void setRootDirectory(string path)
    {
        rootDir = buildNormalizedPath(path);
        refresh();
    };

    string getRootDirectory()
    {
        return rootDir;
    };

    /* private void listExpanded2() {

    }; */

    void refresh()
    {
        auto m = tw.getModel();
        loadDir(null, rootDir);
    }

    void loadDir(TreeIter itera, string path)
    {
        string[] lst;
        string[] lst_dirs;
        string[] lst_files;

        foreach (string i; dirEntries(path, SpanMode.shallow, false))
        {
            lst ~= i;
        }

        foreach (i; lst)
        {
            auto joined = dutils.path.join(cast(string[])[path, i]);
            if (isDir(joined))
            {
                lst_dirs ~= i;
            }
            else
            {
                lst_files ~= i;
            }
        }

        auto m = tw.getModel();

        {
            TreeIter chi;

            bool res = m.iterChildren(chi, itera);

            // TODO: remove only really missing files
            while (res)
            {
                res = (cast(TreeStore) m).remove(chi);
            }
        }

        foreach (i; lst_dirs)
        {
            TreeIter new_iter;
            (cast(TreeStore) m).append(new_iter, itera);
            (cast(TreeStore) m).setValuesv(new_iter, [0, 1], [
                    new Value("folder"), new Value(i)
                    ]);
        }

        foreach (i; lst_files)
        {
            TreeIter new_iter;
            (cast(TreeStore) m).append(new_iter, itera);
            (cast(TreeStore) m).setValuesv(new_iter, [0, 1], [
                    new Value("txt"), new Value(i)
                    ]);
        }

    }

}
