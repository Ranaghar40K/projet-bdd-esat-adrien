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