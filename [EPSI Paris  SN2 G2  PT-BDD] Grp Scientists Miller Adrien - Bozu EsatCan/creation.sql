-- SQL Server Script for Database Schema Creation

-- Assuming 'mydb' is your database name. Replace with your actual database name if different.
USE mydb; -- Change this to your actual database name
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


USE mydb; --change this to your actual database name
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

