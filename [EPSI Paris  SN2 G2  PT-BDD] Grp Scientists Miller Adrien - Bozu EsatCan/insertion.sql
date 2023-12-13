-- Inserting data into 'Genres' Table
INSERT INTO Genres (Name) VALUES ('Drama'), ('Comedy'), ('Thriller'), ('Science Fiction'), ('Romance');

-- Inserting data into 'People' Table
INSERT INTO People (FirstName, LastName) VALUES 
('John', 'Doe'),
('Jane', 'Smith'),
('Michael', 'Johnson'),
('Emma', 'Brown');

-- Inserting data into 'Series' Table
INSERT INTO Series (Title, Year, CountryOfOrigin, CreationDate) VALUES 
('The Example Show', 2020, 'USA', '2019-05-01'),
('Another Series', 2019, 'Canada', '2018-06-10'),
('Fictional Series', 2018, 'UK', '2017-07-20');

-- Inserting data into 'SeriesPeople' Table (assuming IDs for People and Series)
INSERT INTO SeriesPeople (People_PersonID, Series_SeriesID) VALUES 
(1, 1), 
(2, 1), 
(1, 2);

-- Inserting data into 'Episodes' Table
INSERT INTO Episodes (Series_SeriesID, Title, Duration, AirDate, Summary) VALUES 
(1, 'Pilot', 45, '2020-01-01', 'The very first episode.'),
(1, 'Second Episode', 45, '2020-01-08', 'The story continues.'),
(2, 'Pilot', 50, '2019-01-01', 'The beginning of another story.');

-- Inserting data into 'Seasons' Table
INSERT INTO Seasons (Series_SeriesID, Number) VALUES 
(1, 1), 
(2, 1), 
(1, 2);

-- Inserting data into 'Users' Table
INSERT INTO Users (UserName, RegistrationDate, Age, Gender) VALUES 
('user1', '2020-01-01', 25, 'M'),
('user2', '2020-02-01', 30, 'F');

-- Inserting data into 'Ratings' Table
INSERT INTO Ratings (Series_SeriesID, Users_UserID, Score, Comment, RatingDate) VALUES 
(1, 1, 8, 'Great show!', '2020-03-01'),
(2, 2, 7, 'Pretty good.', '2020-03-02');

-- Inserting data into 'Messages' Table
INSERT INTO Messages (Users_UserID, PostedDate, Text, Messages_MessageID, Series_SeriesID, First_Message) VALUES 
(1, GETDATE(), 'I loved the pilot!', NULL, 1, 1),
(2, GETDATE(), 'Can''t wait for the next episode!', 1, 1, 0);

-- Inserting data into 'EpisodePeople' Table (assuming IDs for Episodes and People)
INSERT INTO EpisodePeople (Episodes_EpisodeID, People_PersonID) VALUES 
(1, 1), 
(2, 2);

-- Inserting data into 'SeriesGenres' Table (assuming IDs for Series and Genres)
INSERT INTO SeriesGenres (Series_SeriesID, Genres_GenreID) VALUES 
(1, 1), 
(2, 2);

-- Inserting data into 'Roles' Table
INSERT INTO Roles (Role) VALUES ('Director'), ('Actor'), ('Producer');

-- Inserting data into 'RolesSeriesPeople' Table (assuming IDs for Roles, People, and Series)
INSERT INTO RolesSeriesPeople (Roles_RoleID, SeriesPeople_People_PersonID, SeriesPeople_Series_SeriesID) VALUES 
(1, 1, 1), 
(2, 2, 1);

-- Inserting data into 'RolesEpisodePeople' Table (assuming IDs for Roles, Episodes, and People)
INSERT INTO RolesEpisodePeople (Roles_RoleID, EpisodeActors_Episodes_EpisodeID, EpisodeActors_People_PersonID) VALUES 
(2, 1, 1), 
(3, 2, 2);