SELECT 
    Series_SeriesID,
    TotalScore / TotalRatings AS AverageRating, -- Calculating the average rating on-the-fly
    TotalRatings
FROM 
    dbo.SeriesRatingsSummary
ORDER BY 
    AverageRating DESC;


-- Query 1: List of all series
SELECT SeriesID, Title, Year, CountryOfOrigin, CreationDate
FROM Series;

-- Query 2: Count of different countries that have created series
SELECT COUNT(DISTINCT CountryOfOrigin) AS NumberOfCountries
FROM Series;

-- Query 3: Titles of series from Japan, sorted by title
SELECT Title
FROM Series
WHERE CountryOfOrigin = 'Japan'
ORDER BY Title;

-- Query 4: Number of series from each country
SELECT CountryOfOrigin, COUNT(*) AS NumberOfSeries
FROM Series
GROUP BY CountryOfOrigin;

-- Query 5: Number of series created between 2001 and 2015
SELECT COUNT(*) AS SeriesCount
FROM Series
WHERE Year BETWEEN 2001 AND 2015;

-- Query 6: Series that are both "Comedy" and "Science-Fiction"
SELECT S.SeriesID, S.Title
FROM Series S
JOIN SeriesGenres SG1 ON S.SeriesID = SG1.Series_SeriesID
JOIN SeriesGenres SG2 ON S.SeriesID = SG2.Series_SeriesID
JOIN Genres G1 ON SG1.Genres_GenreID = G1.GenreID AND G1.Name = 'Comedy'
JOIN Genres G2 ON SG2.Genres_GenreID = G2.GenreID AND G2.Name = 'Science Fiction';

-- Query 7: Series produced by "Spielberg", ordered by creation date descending
SELECT S.SeriesID, S.Title, S.CreationDate
FROM Series S
JOIN SeriesPeople SP ON S.SeriesID = SP.Series_SeriesID
JOIN People P ON SP.People_PersonID = P.PersonID
WHERE P.FirstName + ' ' + P.LastName = 'Steven Spielberg'
ORDER BY S.CreationDate DESC;

-- Query 8: American series ordered by the number of seasons ascending
SELECT S.SeriesID, S.Title, COUNT(Se.SeasonID) AS NumberOfSeasons
FROM Series S
JOIN Seasons Se ON S.SeriesID = Se.Series_SeriesID
WHERE S.CountryOfOrigin = 'USA'
GROUP BY S.SeriesID, S.Title
ORDER BY NumberOfSeasons;

-- Query 9: Series with the most episodes
SELECT TOP 1 S.SeriesID, S.Title, COUNT(E.EpisodeID) AS NumberOfEpisodes
FROM Series S
JOIN Episodes E ON S.SeriesID = E.Series_SeriesID
GROUP BY S.SeriesID, S.Title
ORDER BY NumberOfEpisodes DESC;

-- Query 10: Is "Big Bang Theory" more appreciated by men or women?
SELECT Gender, AVG(R.Score) AS AvgRating
FROM Ratings R
JOIN Users U ON R.Users_UserID = U.UserID
JOIN Series S ON R.Series_SeriesID = S.SeriesID
WHERE S.Title = 'Big Bang Theory'
GROUP BY Gender;

--11
SELECT S.SeriesID, S.Title, AVG(R.Score) AS AverageRating
FROM Series S
JOIN Ratings R ON S.SeriesID = R.Series_SeriesID
GROUP BY S.SeriesID, S.Title
HAVING AVG(R.Score) < 5
ORDER BY AverageRating;

--12
;WITH HighestRating AS (
    SELECT 
        Series_SeriesID,
        MAX(Score) AS MaxScore
    FROM Ratings
    GROUP BY Series_SeriesID
)
SELECT 
    S.SeriesID, 
    S.Title, 
    R.Comment
FROM Series S
JOIN HighestRating HR ON S.SeriesID = HR.Series_SeriesID
JOIN Ratings R ON S.SeriesID = R.Series_SeriesID AND R.Score = HR.MaxScore;

--13
SELECT S.SeriesID, S.Title
FROM Series S
JOIN Episodes E ON S.SeriesID = E.Series_SeriesID
JOIN Ratings R ON E.EpisodeID = R.Series_SeriesID
GROUP BY S.SeriesID, S.Title
HAVING AVG(R.Score) > 8;

--14
SELECT AVG(EpisodeCount) AS AverageEpisodes
FROM (
    SELECT 
        S.SeriesID, 
        COUNT(E.EpisodeID) AS EpisodeCount
    FROM Series S
    JOIN Episodes E ON S.SeriesID = E.Series_SeriesID
    JOIN EpisodePeople EP ON E.EpisodeID = EP.Episodes_EpisodeID
    JOIN People P ON EP.People_PersonID = P.PersonID
    WHERE P.FirstName = 'Bryan' AND P.LastName = 'Cranston'
    GROUP BY S.SeriesID
) AS SeriesWithActor;

--15
SELECT DISTINCT P.FirstName, P.LastName
FROM People P
JOIN RolesEpisodePeople REP ON P.PersonID = REP.EpisodeActors_People_PersonID
JOIN Roles R ON REP.Roles_RoleID = R.RoleID
WHERE R.Role = 'Director';

--17
SELECT P.FirstName, P.LastName
FROM People P
JOIN EpisodePeople EP ON P.PersonID = EP.People_PersonID
JOIN Episodes E ON EP.Episodes_EpisodeID = E.EpisodeID
JOIN Series S ON E.Series_SeriesID = S.SeriesID
WHERE S.Title = 'Breaking Bad'
GROUP BY P.FirstName, P.LastName, S.SeriesID
HAVING COUNT(E.EpisodeID) = (SELECT COUNT(*) FROM Episodes WHERE Series_SeriesID = S.SeriesID);

--18
SELECT U.UserName
FROM Users U
WHERE NOT EXISTS (
    SELECT S.SeriesID
    FROM Series S
    WHERE NOT EXISTS (
        SELECT R.RatingID
        FROM Ratings R
        WHERE R.Series_SeriesID = S.SeriesID AND R.Users_UserID = U.UserID
    )
);

--19
SELECT 
    M.MessageID, 
    M.Text AS MessageText,
    CASE 
        WHEN M.First_Message = 1 THEN 'Initial Message' 
        ELSE 'Reply' 
    END AS MessageType,
    S.Title AS SeriesTitle
FROM Messages M
LEFT JOIN Series S ON M.Series_SeriesID = S.SeriesID;

--20
SELECT 
    AVG(ReplyCount) AS AverageReplies
FROM (
    SELECT 
        M.MessageID, 
        COUNT(Reply.MessageID) AS ReplyCount
    FROM Messages M
    LEFT JOIN Messages Reply ON M.MessageID = Reply.Messages_MessageID
    JOIN Users U ON M.Users_UserID = U.UserID
    WHERE U.UserName = 'Azrod95' AND M.First_Message = 1
    GROUP BY M.MessageID
) AS InitialMessages;



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



