import dlangui;

class StringGridWidgetWithTools : StringGridWidget
{

    void removeRow(int index)
    {

        if (index < 0 || index > rows)
        {
            return;
        }

        for (int x = index; x != rows - 1; x++)
        {
            for (int y = 0; y != cols; y++)
            {
                setCellText(x, y, cellText(x + 1, y));
            }
        }
    }
}