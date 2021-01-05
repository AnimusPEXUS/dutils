module main;

import gtk.Window;
import gtk.Widget;
import gtk.Application;
import gio.Application;


import dutils.gtkcollection.FileTreeView;


class MainWindow : Window {
    private {
        FileTreeView ftw;
    }

    this() {
        super("test");

        ftw = new FileTreeView();

        add(cast(Widget)ftw);
    }
}

int main(string[] args) {
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
