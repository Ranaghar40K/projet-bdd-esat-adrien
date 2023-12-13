-- SQL Server Script for Database Schema Creation

-- Assuming 'mydb' is your database name. Replace with your actual database name if different.
USE mydb;
GO

-- Creating 'Series' Table
CREATE TABLE Series (
  SeriesID INT IDENTITY(1,1) NOT NULL,
  Title NVARCHAR(255),
  Year INT,
  CountryOfOrigin NVARCHAR(100),
  CreationDate DATE,
  CONSTRAINT PK_Series PRIMARY KEY (SeriesID)
);
GO

-- Creating 'People' Table
CREATE TABLE People (
  PersonID INT IDENTITY(1,1) NOT NULL,
  FirstName NVARCHAR(100),
  LastName NVARCHAR(100),
  CONSTRAINT PK_People PRIMARY KEY (PersonID)
);
GO

-- Creating 'SeriesPeople' Table
CREATE TABLE SeriesPeople (
  People_PersonID INT NOT NULL,
  Series_SeriesID INT NOT NULL,
  CONSTRAINT PK_SeriesPeople PRIMARY KEY (People_PersonID, Series_SeriesID),
  CONSTRAINT FK_SeriesPeople_People FOREIGN KEY (People_PersonID) REFERENCES People (PersonID),
  CONSTRAINT FK_SeriesPeople_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID)
);
GO

-- Creating 'Episodes' Table
CREATE TABLE Episodes (
  EpisodeID INT IDENTITY(1,1) NOT NULL,
  Series_SeriesID INT NOT NULL,
  Title NVARCHAR(255),
  Duration INT,
  AirDate DATE,
  Summary NVARCHAR(MAX),
  CONSTRAINT PK_Episodes PRIMARY KEY (EpisodeID),
  CONSTRAINT FK_Episodes_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID)
);
GO

-- Creating 'Seasons' Table
CREATE TABLE Seasons (
  SeasonID INT IDENTITY(1,1) NOT NULL,
  Series_SeriesID INT NOT NULL,
  Number INT,
  CONSTRAINT PK_Seasons PRIMARY KEY (SeasonID),
  CONSTRAINT FK_Seasons_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID)
);
GO

-- Creating 'Users' Table
CREATE TABLE Users (
  UserID INT IDENTITY(1,1) NOT NULL,
  UserName NVARCHAR(100),
  RegistrationDate DATE,
  Age INT,
  Gender CHAR(1),
  CONSTRAINT PK_Users PRIMARY KEY (UserID)
);
GO

-- Creating 'Ratings' Table
CREATE TABLE Ratings (
  RatingID INT IDENTITY(1,1) NOT NULL,
  Series_SeriesID INT NOT NULL,
  Users_UserID INT NOT NULL,
  Score INT,
  Comment NVARCHAR(MAX),
  RatingDate DATE,
  CONSTRAINT PK_Ratings PRIMARY KEY (RatingID),
  CONSTRAINT FK_Ratings_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID),
  CONSTRAINT FK_Ratings_Users FOREIGN KEY (Users_UserID) REFERENCES Users (UserID)
);
GO

-- Creating 'Messages' Table
CREATE TABLE Messages (
  MessageID INT IDENTITY(1,1) NOT NULL,
  Users_UserID INT NOT NULL,
  PostedDate DATETIME,
  Text NVARCHAR(MAX),
  Messages_MessageID INT,
  Series_SeriesID INT,
  First_Message TINYINT NOT NULL,
  CONSTRAINT PK_Messages PRIMARY KEY (MessageID),
  CONSTRAINT FK_Messages_Users FOREIGN KEY (Users_UserID) REFERENCES Users (UserID),
  CONSTRAINT FK_Messages_Messages FOREIGN KEY (Messages_MessageID) REFERENCES Messages (MessageID),
  CONSTRAINT FK_Messages_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID)
);
GO

-- Creating 'EpisodePeople' Table
CREATE TABLE EpisodePeople (
  Episodes_EpisodeID INT NOT NULL,
  People_PersonID INT NOT NULL,
  CONSTRAINT PK_EpisodePeople PRIMARY KEY (Episodes_EpisodeID, People_PersonID),
  CONSTRAINT FK_EpisodePeople_Episodes FOREIGN KEY (Episodes_EpisodeID) REFERENCES Episodes (EpisodeID),
  CONSTRAINT FK_EpisodePeople_People FOREIGN KEY (People_PersonID) REFERENCES People (PersonID)
);
GO

-- Creating 'Genres' Table
CREATE TABLE Genres (
  GenreID INT IDENTITY(1,1) NOT NULL,
  Name NVARCHAR(50),
  CONSTRAINT PK_Genres PRIMARY KEY (GenreID)
);
GO

-- Creating 'SeriesGenres' Table
CREATE TABLE SeriesGenres (
  Series_SeriesID INT NOT NULL,
  Genres_GenreID INT NOT NULL,
  CONSTRAINT PK_SeriesGenres PRIMARY KEY (Series_SeriesID, Genres_GenreID),
  CONSTRAINT FK_SeriesGenres_Series FOREIGN KEY (Series_SeriesID) REFERENCES Series (SeriesID),
  CONSTRAINT FK_SeriesGenres_Genres FOREIGN KEY (Genres_GenreID) REFERENCES Genres (GenreID)
);
GO

-- Creating 'Roles' Table
CREATE TABLE Roles (
  RoleID INT IDENTITY(1,1) NOT NULL,
  Role NVARCHAR(50) NOT NULL,
  CONSTRAINT PK_Roles PRIMARY KEY (RoleID)
);
GO

-- Creating 'RolesSeriesPeople' Table
CREATE TABLE RolesSeriesPeople (
  Roles_RoleID INT NOT NULL,
  SeriesPeople_People_PersonID INT NOT NULL,
  SeriesPeople_Series_SeriesID INT NOT NULL,
  CONSTRAINT PK_RolesSeriesPeople PRIMARY KEY (Roles_RoleID, SeriesPeople_People_PersonID, SeriesPeople_Series_SeriesID),
  CONSTRAINT FK_RolesSeriesPeople_Roles FOREIGN KEY (Roles_RoleID) REFERENCES Roles (RoleID),
  CONSTRAINT FK_RolesSeriesPeople_SeriesPeople FOREIGN KEY (SeriesPeople_People_PersonID, SeriesPeople_Series_SeriesID) REFERENCES SeriesPeople (People_PersonID, Series_SeriesID)
);
GO

-- Creating 'RolesEpisodePeople' Table
CREATE TABLE RolesEpisodePeople (
  Roles_RoleID INT NOT NULL,
  EpisodeActors_Episodes_EpisodeID INT NOT NULL,
  EpisodeActors_People_PersonID INT NOT NULL,
  CONSTRAINT PK_RolesEpisodePeople PRIMARY KEY (Roles_RoleID, EpisodeActors_Episodes_EpisodeID, EpisodeActors_People_PersonID),
  CONSTRAINT FK_RolesEpisodePeople_Roles FOREIGN KEY (Roles_RoleID) REFERENCES Roles (RoleID),
  CONSTRAINT FK_RolesEpisodePeople_EpisodePeople FOREIGN KEY (EpisodeActors_Episodes_EpisodeID, EpisodeActors_People_PersonID) REFERENCES EpisodePeople (Episodes_EpisodeID, People_PersonID)
);
GO


USE mydb;
GO

-- Drop the view if it already exists
IF OBJECT_ID('dbo.SeriesRatingsSummary', 'V') IS NOT NULL
    DROP VIEW dbo.SeriesRatingsSummary;
GO

-- Creating the view without any aliases as per SCHEMABINDING requirements
CREATE VIEW dbo.SeriesRatingsSummary
WITH SCHEMABINDING
AS
SELECT 
    Series_SeriesID,
    SUM(ISNULL(CAST(Score AS FLOAT), 0)) AS TotalScore, -- Use ISNULL to ensure non-nullable result
    COUNT_BIG(*) AS TotalRatings
FROM 
    dbo.Ratings
GROUP BY 
    Series_SeriesID;
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- Creating a Unique Clustered Index on the view
    CREATE UNIQUE CLUSTERED INDEX IDX_VW_SeriesRatingsSummary
    ON dbo.SeriesRatingsSummary (Series_SeriesID);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW; -- Re-throws the error caught by the CATCH block
END CATCH;
GO
-------------------------------------------------------------------------------------

ALTER TABLE Ratings
ADD CONSTRAINT CHK_Score CHECK (Score BETWEEN 0 AND 10);


ALTER TABLE Users
ADD CONSTRAINT CHK_Gender CHECK (Gender IN ('M', 'F', 'm', 'f') OR Gender IS NULL);

GO

CREATE TRIGGER trg_CheckRatingScore
ON Ratings
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF EXISTS (SELECT * FROM inserted WHERE Score < 0 OR Score > 10)
    BEGIN
      RAISERROR ('Score must be between 0 and 10.', 16, 1);
      ROLLBACK TRANSACTION;
    END
  END TRY
  BEGIN CATCH
    -- Handle the error appropriately
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
  END CATCH
END;
GO


-- Creating 'Audit_Comments' Table
CREATE TABLE Audit_Comments (
  AuditID INT IDENTITY(1,1) PRIMARY KEY,
  UserName NVARCHAR(100),
  RatingID INT,
  OldComment NVARCHAR(MAX),
  NewComment NVARCHAR(MAX),
  UpdateDate DATETIME
);
GO -- Ensures the creation of the table is a separate batch

-- Creating Trigger for Auditing Comments
CREATE TRIGGER trg_AuditComments
ON Ratings
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF UPDATE(Comment) -- This checks if the 'Comment' column is being updated
  BEGIN
    -- Insert audit record
    INSERT INTO Audit_Comments (UserName, RatingID, OldComment, NewComment, UpdateDate)
    SELECT S.UserName, I.RatingID, D.Comment, I.Comment, GETDATE()
    FROM deleted D
    INNER JOIN inserted I ON D.RatingID = I.RatingID
    INNER JOIN Users S ON S.UserID = I.Users_UserID;
  END
END;

GO

CREATE TRIGGER trg_SecureCommentUpdate
ON Ratings
INSTEAD OF UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @AuthorizedUser NVARCHAR(100) = 'dbo'; -- Replace with the actual admin user name
    IF (USER_NAME() = @AuthorizedUser OR ORIGINAL_LOGIN() = @AuthorizedUser)
    BEGIN
      UPDATE R
      SET Score = I.Score,
          Comment = I.Comment,
          RatingDate = I.RatingDate
      FROM Ratings R
      INNER JOIN inserted I ON R.RatingID = I.RatingID;
    END
    ELSE
    BEGIN
      RAISERROR ('Unauthorized update attempt.', 16, 1);
    END
  END TRY
  BEGIN CATCH
    -- Handle the error appropriately
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
  END CATCH
END;



UPDATE Ratings
SET Comment = 'Updated Comment'
WHERE RatingID = 1;
-- Check if the audit entry is logged
SELECT * FROM Audit_Comments;




GO

-- Function to calculate the average rating score of a user
CREATE FUNCTION fn_moyenne (@UserID INT)
RETURNS TABLE
AS
RETURN (
    SELECT AVG(CAST(Score AS FLOAT)) AS AverageScore
    FROM Ratings
    WHERE Users_UserID = @UserID
);
GO


USE mydb;
GO

-- Procedure to display the average rating score and corresponding grade for each user
CREATE PROCEDURE pr_resultat
AS
BEGIN
    BEGIN TRY
        -- Temp table to hold average scores
        CREATE TABLE #AverageScores (
            UserID INT,
            AverageScore FLOAT,
            Grade NVARCHAR(50)
        );
        
        -- Insert average scores into the temp table
        INSERT INTO #AverageScores (UserID, AverageScore)
        SELECT UserID, AverageScore
        FROM Users u
        CROSS APPLY dbo.fn_moyenne(u.UserID);

        -- Update the temp table with grades
        UPDATE #AverageScores
        SET Grade = CASE 
                        WHEN AverageScore >= 9 THEN 'Excellent'
                        WHEN AverageScore BETWEEN 7 AND 8.99 THEN 'Good'
                        WHEN AverageScore BETWEEN 5 AND 6.99 THEN 'Average'
                        WHEN AverageScore < 5 THEN 'Poor'
                        ELSE 'Not Rated'
                    END;
        
        -- Select the final results
        SELECT UserID, AverageScore, Grade FROM #AverageScores;
        
        -- Drop the temp table
        DROP TABLE #AverageScores;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH
END;
GO