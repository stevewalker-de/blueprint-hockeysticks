/* To use the Migration Service, in the top pane, go to More --> Enable SQL translation.
The queries below are examples of non-BigQuery SQL syntax that can be used with the 
interactive translator to see before and after changes performed.

The sample queries below use PostgreSQL syntax.*/

/* Query 1 
-------------
SELECT FORMAT_DATE("%w", Pickup_DateTime) AS WeekdayNumber,
      FORMAT_DATE("%A", Pickup_DateTime) AS WeekdayName,
      vendor.Vendor_Description,
      payment_type.Payment_Type_Description,
      SUM(taxi_trips.Total_Amount) AS high_value_trips
 FROM ds_edw.taxi_trips AS taxi_trips
      INNER JOIN ds_edw.vendor AS vendor
              ON cast(taxi_trips.Vendor_Id as int) = vendor.Vendor_Id
             AND taxi_trips.Pickup_DateTime BETWEEN '2022-01-01' AND '2022-02-01'
       LEFT JOIN ds_edw.payment_type AS payment_type
              ON taxi_trips.payment_type::int = payment_type.Payment_Type_Id
GROUP BY 1, 2, 3, 4
HAVING SUM(taxi_trips.Total_Amount) > 50
ORDER BY WeekdayNumber, 3, 4;
*/


/* Query 2 
-------------
WITH TaxiDataRanking AS
(
SELECT CAST(Pickup_DateTime AS DATE) AS Pickup_Date,
      taxi_trips.payment_type as Payment_Type_Id,
      taxi_trips.Passenger_Count,
      taxi_trips.Total_Amount,
      RANK() OVER (PARTITION BY CAST(Pickup_DateTime AS DATE),
                                taxi_trips.payment_type
                       ORDER BY taxi_trips.Passenger_Count DESC,
                                taxi_trips.Total_Amount DESC) AS Ranking
 FROM ds_edw.taxi_trips AS taxi_trips
WHERE taxi_trips.Pickup_DateTime BETWEEN '2022-01-01' AND '2022-02-01'
  AND taxi_trips.payment_type::int IN (1,2)
)
SELECT Pickup_Date,
      Payment_Type_Description,
      Passenger_Count,
      Total_Amount
 FROM TaxiDataRanking
      INNER JOIN ds_edw.payment_type AS payment_type
              ON TaxiDataRanking.Payment_Type_Id = payment_type.Payment_Type_Id
WHERE Ranking = 1
ORDER BY Pickup_Date, Payment_Type_Description;
*/

SELECT 'OPEN THE STORED PROCEDURE FOR MORE DETAILS TO USE THE TRANSLATION SERVICE' as sql_text;