module main;

import gtk.Window;

import dutils.gtkcollection.FileTreeView;


class MainWindow : Window {
    private {
        FileTreeView ftw;
    }

    this() {
        super();
        setTitle("test");

        ftw = new FileTreeView();

        packStart(ftw, true, true, 0);
    }
}

void main() {
    auto app = new gtk.Application.Application(
        "filetreeviewtest.wayround.i2p",
        gio.Application.GApplicationFlags.FLAGS_NONE
        );

    app.addOnActivate(
            delegate void(gio.Application.Application gioapp) {

                auto w = new MainWindow();

                app.addWindow(w);

                w.showAll();
            }
        );

    return app.run(args);
}
