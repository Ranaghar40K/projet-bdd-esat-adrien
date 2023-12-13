SELECT 
    Series_SeriesID,
    TotalScore / TotalRatings AS AverageRating, -- Calculating the average rating on-the-fly
    TotalRatings
FROM 
    dbo.SeriesRatingsSummary
ORDER BY 
    AverageRating DESC;


BEGIN TRY
    -- Attempt to insert an invalid rating (score out of range)
    INSERT INTO Ratings (Series_SeriesID, Users_UserID, Score, Comment, RatingDate) 
    VALUES (1, 1, 11, 'Invalid score', GETDATE());
    PRINT 'Invalid rating insertion should have failed.';
END TRY
BEGIN CATCH
    PRINT 'Expected error for invalid rating insertion: ' + ERROR_MESSAGE();
END CATCH;



BEGIN TRY
  -- This should fail due to the gender constraint (use 'M' or 'F')
  INSERT INTO Users (UserName, RegistrationDate, Age, Gender) VALUES ('testuser', '2020-01-01', 25, 'X');
END TRY
BEGIN CATCH
  SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;



EXECUTE AS USER = 'BusinessUser1';
GO

BEGIN TRY
    -- Assume 'AdminUser' is an authorized user name.
    -- The trigger should allow this update if you're running it as 'AdminUser'.
    UPDATE Ratings SET Comment = 'Updated Comment' WHERE RatingID = 1;
    PRINT 'Authorized update performed successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error occurred during authorized update: ' + ERROR_MESSAGE();
END CATCH;

REVERT; -- to switch back to your previous user context
GO



USE mydb;
GO

-- Assuming we have a user with UserID = 1, we test the function for this user
SELECT * FROM dbo.fn_moyenne(1);

-- Now we execute the stored procedure to get the average scores and grades for all users
EXEC pr_resultat;