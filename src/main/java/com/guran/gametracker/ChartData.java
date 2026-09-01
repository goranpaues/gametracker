package com.guran.gametracker;

/**
 * Created by goranpaues on 2017-04-23.
 */
public class ChartData {
    private String category;
    private String amount;

    public ChartData() {
        super();
        this.category = "";
        this.amount = "";
    }

    public ChartData(String category, String amount) {
        this.category = category;
        this.amount = amount;
    }

    @Override
    public String toString() {
        return String.format(
                "ChartData[category='%s', amount=%s]",
                category, amount);
    }

    public String getCategory() {
        return this.category;
    }

    public String getAmount() {
        return this.amount;
    }
}
