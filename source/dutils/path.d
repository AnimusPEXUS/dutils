module dutils.path;

import std.path;
import std.algorithm;
import std.array;
import std.string;

import dutils.string;

// TODO: make more unittests?
// TODO: use templates for allowing dstring and wstring

private const doubleDirSeparator = dirSeparator ~ dirSeparator;

private string[] deleteEmptyItems(string[] args)
{
    // TODO: maybe add searchin and splitting by separator in args items
    string[] ret;
    foreach (i; args)
    {
        if (i == "")
        {
            continue;
        }
        ret ~= i;
    }
    return ret;
}

unittest
{
    import std.stdio;

    auto t1 = deleteEmptyItems(cast(string[])["", "a", "b", "", "c"]);
    assert(t1 == cast(string[])["a", "b", "c"]);
}

private string deleteEmptyItems(string value)
{

    while (value.indexOf(doubleDirSeparator) != -1)
    {
        value = value.replace(doubleDirSeparator, dirSeparator);
    }

    return value;
}

/*
split string by dirSeparator.
This function preserves root slash and (optionally) preserves trailing slash
note: this function removes any empty ements from result.
*/
string[] split(string value, bool keep_end_separator = false)
{
    auto const start_separator = startsWithSeparator(value);
    auto const end_separator = endsWithSeparator(value);

    value = deleteEmptyItems(value);
    auto splitted = dutils.string.split(value, dirSeparator);
    splitted = deleteEmptyItems(splitted);

    if (start_separator)
    {
        splitted = (cast(string[])[""]) ~ splitted;
    }

    if (keep_end_separator && end_separator)
    {
        splitted ~= "";
    }

    return splitted;
}

unittest
{
    auto t1 = split("/a/b/c");
    assert(t1 == cast(string[])["", "a", "b", "c"]);

    t1 = split("/a/b/c/", true);
    assert(t1 == cast(string[])["", "a", "b", "c", ""]);

    t1 = split("a/b/c");
    assert(t1 == cast(string[])["a", "b", "c"]);

    t1 = split("a/b/c/", true);
    assert(t1 == cast(string[])["a", "b", "c", ""]);

    t1 = split("a/b/c//", true);
    assert(t1 == cast(string[])["a", "b", "c", ""]);
}

/*
split string by dirSeparator.
This function preserves root slash (in form of "" as #0 element) and (optionally)
preserves trailing slash (in form of "" as last element)
note: there are two ways to state what where shold be a root slash in result:
1. put empty string as first element of args array
2. insert slash as first character in first element of args array.
note: this function removes any empty ements from result.
note: this function removes any slashes from elements (by splitting elements
with slashes),
note: this function inserts empty element at #0 index, if args determined as rooted.
*/
string[] split(string[] args, bool keep_end_separator = false)
{

    auto const start_separator = startsWithSeparator(args);
    auto const end_separator = endsWithSeparator(args);

    string[] splitted;

    foreach (item; args)
    {
        splitted ~= split(item, false);
    }

    splitted = deleteEmptyItems(splitted);

    if (start_separator)
    {
        splitted = (cast(string[])[""]) ~ splitted;
    }

    if (keep_end_separator && end_separator)
    {
        splitted ~= "";
    }

    return splitted;
}

unittest
{
    auto t1 = split(["/a", "//", "", "b", "/c"]);
    assert(t1 == cast(string[])["", "a", "b", "c"]);

    t1 = split(["d/a", "//", "", "b", "/c"]);
    assert(t1 == cast(string[])["d", "a", "b", "c"]);

    t1 = split(["d/a", "//", "", "b", "/c", ""]);
    assert(t1 == cast(string[])["d", "a", "b", "c"]);

    t1 = split(["d/a", "//", "", "b", "/c", ""], true);
    assert(t1 == ["d", "a", "b", "c", ""]);
}

private bool startsWithSeparator(string value)
{
    return value.startsWith(dirSeparator);
}

private bool startsWithSeparator(string[] args)
{
    return (args.length != 0 && (args[0] == "" || args[0].startsWith(dirSeparator)));
}

unittest
{
    auto t1 = startsWithSeparator(["/a", "//", "", "b", "/c"]);
    assert(t1 == true);

    t1 = startsWithSeparator(["d/a", "//", "", "b", "/c"]);
    assert(t1 == false);

    t1 = startsWithSeparator(["d/a", "//", "", "b", "/c", ""]);
    assert(t1 == false);

    t1 = startsWithSeparator(["d/a", "//", "", "b", "/c", ""]);
    assert(t1 == false);

    t1 = startsWithSeparator(["", "d/a", "//", "", "b", "/c", ""]);
    assert(t1 == true);
}

private bool endsWithSeparator(string value)
{
    return value.endsWith(dirSeparator);
}

private bool endsWithSeparator(string[] args)
{
    return (args.length != 0 && (args[$ - 1] == "" || args[$ - 1].endsWith(dirSeparator)));
}

unittest
{
    auto t1 = endsWithSeparator(["/a", "//", "", "b", "/c"]);
    assert(t1 == false);

    t1 = endsWithSeparator(["d/a", "//", "", "b", "/c/"]);
    assert(t1 == true);

    t1 = endsWithSeparator(["d/a", "//", "", "b", "/c", ""]);
    assert(t1 == true);
}

string join(string value, bool keep_end_empty = false)
{
    return join(cast(string[])[value], keep_end_empty);
}

string join(string[] args, bool keep_end_empty = false)
{
    auto const start_separator = startsWithSeparator(args);
    auto const end_separator = endsWithSeparator(args);

    string ret;

    args = deleteEmptyItems(args);

    foreach (index, item; args)
    {
        ret ~= item;
        if (index < args.length)
        {
            ret ~= dirSeparator;
        }
    }

    ret = deleteEmptyItems(ret);

    ret = ret.strip(dirSeparator[0]);

    if (start_separator)
    {
        ret = dirSeparator ~ ret;
    }

    if (keep_end_empty && end_separator)
    {
        ret ~= dirSeparator;
    }

    return ret;
}

unittest
{
    auto t1 = join(["/a", "//", "", "b", "/c"]);
    assert(t1 == "/a/b/c");

    t1 = join(["d/a", "//", "", "b", "/c/"]);
    assert(t1 == "d/a/b/c");

    t1 = join(["d/a", "//", "", "b", "/c/"], true);
    assert(t1 == "d/a/b/c/");

    t1 = join(["", "d/a", "//", "", "b", "/c/"]);
    assert(t1 == "/d/a/b/c");

    t1 = join([" ", "", "d/a", "//", "", "b", "/c/"]);
    assert(t1 == " /d/a/b/c");

    t1 = join(["d/a", "//", "", "b", "/c", ""]);
    assert(t1 == "d/a/b/c");

    t1 = join(["d/a", "//", "", "b", "/c", ""], true);
    assert(t1 == "d/a/b/c/");
}
