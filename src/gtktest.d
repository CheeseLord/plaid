module GTKTest;

private import std.stdio;

private import gtk.Button;
private import gtk.Main;
private import gtk.MainWindow;

void testWindow()
{
    string[] args = [];
    Main.init(args);
    MainWindow win = new MainWindow("We have buttons!");

    Button button = new Button();
    button.setLabel("Click for magic(k)!");

    // The callback needs to be a delegate, not a function pointer.
    void onClick(Button b) { writefln("magic(k)"); }
    void delegate(Button b) oc = &onClick;
    button.addOnClicked(oc);

    win.add(button);
    win.showAll();
    Main.run();
}

