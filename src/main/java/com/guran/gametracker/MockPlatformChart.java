package com.guran.gametracker;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Arrays;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Created by goranpaues on 2017-04-24.
 */
public class MockPlatformChart {
    private static final CopyOnWriteArrayList<ChartData> eList = new CopyOnWriteArrayList<>();

    static {

        String jsonString = "[{\"category\":\"PS3\",\"amount\":\"442\"},{\"category\":\"iPad\",\"amount\":\"57\"},{\"category\":\"PC\",\"amount\":\"449\"}]";

        try {

            ObjectMapper mapper = new ObjectMapper();

            ChartData[] myPlatformChart = mapper.readValue(jsonString, ChartData[].class);

            eList.addAll(Arrays.asList(myPlatformChart));

        } catch (IOException exception) {
            System.out.println("Error: " + exception.getMessage());
        }

    }

    private MockPlatformChart(){}

    public static CopyOnWriteArrayList<ChartData> getInstance(){
        return eList;
    }

}
