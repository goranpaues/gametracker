package com.guran.gametracker;

/**
 * Created by goranpaues on 2017-04-23.
 */
import java.util.List;

public interface ChartDataDAO {
    public List<ChartData> getPlatformChart();

    public List<ChartData> getRatingChart();

    public List<ChartData> getShelfChart();
}