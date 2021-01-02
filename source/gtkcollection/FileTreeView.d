module dedit.FileTreeView;

import std.path;

import gtk.TreeView;
import gtk.TreeStore;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.CellRendererPixbuf;
import gtk.CellRendererText;

class FileTreeView {

private {
    TreeView tw;
    TreeStore ts;

    string rootDir;
    bool showHidden;
    }

    this() {

        /* show_hidden = false; */


        ts = new TreeStore(cast(GType[])[GType.STRING,GType.STRING]);

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

    void setRootDirectory(string path) {
        rootDir = asNormalizedPath(path);
        reload();
    };

    string getRootDirectory() {
        return rootDir;
    };

    /* private void listExpanded2() {

    }; */

    void refresh() {
        loadDir()
    }

    void loadDir(TreeIter itera, string path) {
        auto m = tw.getModel();

        auto chi = m.getChildren(itera);
        bool res = true;

        while (chi !is null && res != false) {
            res = m.remove(chi);
            chi = m.getChildren(itera);
        }

        string[] lst;

        foreach (string i ; dirEntries(path, SpanMode.shallow, false) {
            lst ~= i;
        }

        foreach (string i; lst) {
            isDir()
        }

    }

}
