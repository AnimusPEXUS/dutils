module dutils.string;

import std.string;

ptrdiff_t index(string s, string sub, ptrdiff_t start=0) {

    auto sub_length = sub.length;

    while (true) {

        s = s[start .. $];

        auto index = indexOf(s, sub);
        if (index == -1) {
            return -1;
        }

        string s_sub = s[index .. index+sub_length];
        if (cmp(s_sub, sub) == 0 ){
            return start+ index;
        }

        start += 1;
    }

    return -1;
}

unittest {
    import std.stdio;
    import std.format;

    {
    auto t1=    index("abbc", "bb");
    assert(t1 == 1, format("must be 1, not %d", t1));

    t1=    index("abbc", "d");
    assert(t1 == -1, format("must be -1, not %d", t1));

    t1=    index("abbc", "b");
    assert(t1 == 1, format("must be 1, not %d", t1));

    t1=    index("abbc", "b",2);
    assert(t1 == 2, format("must be 2, not %d", t1));

    t1=    index("abb", "bb");
    assert(t1 == 1, format("must be 1, not %d", t1));

    t1=    index("abb", "bb", 2);
    assert(t1 == -1, format("must be -1, not %d", t1));
    }
}

string[] split(string s, string sub) {

    auto sub_length = sub.length;

    string[] ret;


    while (true) {
        auto next_index = index(s, sub);
        if (next_index == -1) {
            break;
        }
        ret ~= s[0 .. next_index];
        s = s[next_index+sub_length .. $];
    }

    ret ~= s;

    return ret;
}


string join(string[] values, string sub) {

    string ret;
    auto values_length = values.length;

    foreach (ptrdiff_t index , string i ; values) {
        ret ~= i;
        if (index < values_length-1) {
            ret ~= sub;
        }
    }

    return ret;
}

 debug {
    void main() {}
}
