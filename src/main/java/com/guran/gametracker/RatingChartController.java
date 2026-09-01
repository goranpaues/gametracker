package com.guran.gametracker;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin
@RestController
@RequestMapping("/ratings")
public class RatingChartController {

    ChartDataDbDAO dbdao = new ChartDataDbDAO();

    @RequestMapping(method = RequestMethod.GET)
    public ChartData[] getAll() {
        return dbdao.getRatingChart().toArray(new ChartData[0]);
    }
}
