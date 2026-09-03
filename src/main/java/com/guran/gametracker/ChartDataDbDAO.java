package com.guran.gametracker;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by goranpaues on 2017-04-25.
 */
public class ChartDataDbDAO implements ChartDataDAO{

    private final Connection conn = DBConnection.getInstance().getConnection();


    public List<ChartData> query(String sqlQueryStr) {
        List<ChartData> resultList = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sqlQueryStr)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                resultList.add(
                        new ChartData(rs.getString("category"), rs.getString("amount")));
            }
        } catch (SQLException e) {
            System.out.println("SQL Query Error: " + e.getMessage());
        } catch (Exception e) {
            System.out.println("Query Error: " + e.getMessage());
        }
        return resultList;
    }

    @Override
    public List<ChartData> getPlatformChart(){
        String queryStr = "select p.name as category, count(*) as amount from\n" +
                                "platforms p\n" +
                                "join platform_list pl on pl.platform_id = p.id\n" +
                                "join games g on g.id = pl.game_id\n" +
                                "where p.name not in ('Linux','Mac','iPhone')\n" +
                                "and pl.game_id not in (select game_id \n" +
                                "                         from shelf_list sl\n" +
                                "                         join shelves s on s.id = sl.shelf_id\n" +
                                "                         where s.name = 'Backlog')\n" +
                                "group by p.name\n" +
                                "having count(*) > 10\n" +
                                "order by count(*) desc";
        List<ChartData> resultList = this.query(queryStr);
        return resultList;
    }


    @Override
    public List<ChartData> getRatingChart(){
        String queryStr = "select\n" +
                                "to_char(g.rating) as category,\n" +
                                "count(*) as amount\n" +
                                "from games g\n" +
                                "where g.rating is not null\n" +
                                "group by g.rating\n" +
                                "order by g.rating desc";
        List<ChartData> resultList = this.query(queryStr);
        return resultList;
    }

    @Override
    public List<ChartData> getShelfChart(){
        String queryStr = "select\n" +
                                "s.name as category,\n" +
                                "count(*) as amount\n" +
                                "from shelves s\n" +
                                "join shelf_list sl on sl.shelf_id = s.id\n" +
                                "group by s.name\n" +
                                "order by count(*) desc";
        List<ChartData> resultList = this.query(queryStr);
        return resultList;
    }

}
