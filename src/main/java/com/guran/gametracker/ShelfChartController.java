package com.guran.gametracker;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin
@RestController
@RequestMapping("/shelves")
public class ShelfChartController {

    ChartDataDbDAO dbdao = new ChartDataDbDAO();

    @RequestMapping(method = RequestMethod.GET)
    public ChartData[] getAll() {
        return dbdao.getShelfChart().toArray(new ChartData[0]);
    }
}
