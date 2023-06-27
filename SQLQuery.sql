--1. Показать TOP-10 пользователей с самым высоким средним рейтингом анкеты 
--   (Anketa_Rate, AVG, средний рейтинг должен быть представлен в виде вещественного числа)
SELECT TOP 10 u.nick AS [имя пользователя],
    u.user_id,
    u.age,
    ROUND(AVG(CAST(rating AS float)), 2) AS [средний балл профиля]
FROM anketa_rate r JOIN users u
ON u.user_id = r.id_kogo
GROUP BY u.nick, u.user_id, u.age
ORDER BY 4 DESC

--2. Показать всех пользователей с высшим образованием, которые не курят, не пьют и не употребляют наркотики
SELECT users.user_id, users.nick, users.age, users.sex
FROM users
WHERE users.id_education >= 4 AND
	users.my_smoke = 1 AND users.my_drink = 1 AND users.my_drugs = 1

--3. Сделать запрос, который позволит найти пользователей по указанным данным:
-- - ник (не обязательно точный)
-- - пол
-- - минимальный и максимальный возраст
-- - минимальный и максимальный рост
-- - минимальный и максимальный вес
SELECT u.user_id, u.nick, u.age, u.sex
FROM users u
WHERE u.nick LIKE 'К%' AND u.sex = 2 AND 
	u.age BETWEEN 20 AND 30 AND 
	u.rost BETWEEN 160 AND 180 AND 
	u.ves BETWEEN 50 AND 60

--4. Показать всех стройных голубоглазых блондинок, затем всех спортивных кареглазых брюнетов, а в конце 
--   их общее количество (UNION, одним запросом на SELECT)
SELECT u.user_id, u.nick, u.age, u.sex
FROM users u
WHERE u.sex = 2 AND u.my_build = 2 AND u.eyes_color = 4 AND u.hair_color = 1

UNION ALL

SELECT u.user_id, u.nick, u.age, u.sex
FROM users u
WHERE u.sex = 1 AND u.my_build = 4 AND u.eyes_color = 2 AND u.hair_color = 4

SELECT 'All', SUM(AllSum.AllCount)
FROM
(
	SELECT COUNT(*) AS AllCount
	FROM users u
	WHERE u.sex = 2 AND u.my_build = 2 AND u.eyes_color = 4 AND u.hair_color = 1

	UNION ALL

	SELECT COUNT(*) AS AllCount
	FROM users u
	WHERE u.sex = 1 AND u.my_build = 4 AND u.eyes_color = 2 AND u.hair_color = 4
) AS AllSum

--5. Показать всех программистов с пирсингом, которые к тому же умеют вышивать крестиком 
--   (Moles, Framework и Interes)
SELECT u.user_id, u.nick, u.age, u.sex
FROM users u JOIN users_moles u_m ON u.user_id = u_m.user_id
JOIN moles m ON u_m.moles_id = m.id
JOIN users_interes u_i ON u.user_id = u_i.user_id
JOIN interes i ON u_i.interes_id = i.id
WHERE m.name = 'пирсинг' AND u.id_framework = 1 AND i.id = 23

--6. Показать сколько подарков подарили каждому пользователю, у которого знак зодиака Рыбы
SELECT u.user_id, u.nick, u.age, u.sex, COUNT(*) AS AllCount
FROM users u JOIN gift_service g_s ON u.user_id = g_s.id_to
WHERE u.id_zodiak = 12
GROUP BY u.user_id, u.nick, u.age, u.sex

--7. Показать как много зарабатывают себе на жизнь полиглоты (знающие более 5 языков), совершенно не умеющие готовить
SELECT u.user_id, u.nick, u.age, u.sex, u.my_rich
FROM users u JOIN users_languages u_l ON u.user_id = u_l.user_id
WHERE u.like_kitchen = 2
GROUP BY u.user_id, u.nick, u.age, u.sex, u.my_rich
HAVING COUNT(*) > 5

--8. Показать всех буддистов, которые занимаются восточными единоборствами, живут на вокзале, и в 
--   свободное время катаются на скейте
SELECT u.user_id, u.nick, u.age, u.sex
FROM users u JOIN users_sport u_s ON u.user_id = u_s.user_id
JOIN sport s ON u_s.sport_id = s.id
WHERE u.religion = 6 AND s.name = 'единоборства' AND u.my_home = 9

--9. Показать возрастную аудиторию пользователей в виде:
SELECT 'до 18' AS [возраст], COUNT(*) AS [кол-во], ROUND(CAST(COUNT(*) AS float) / (SELECT COUNT(*) FROM users), 3) * 100 AS [%]
FROM users u
WHERE u.age < 18

UNION ALL

SELECT '18-24' AS [возраст], COUNT(*) AS [кол-во], ROUND(CAST(COUNT(*) AS float) / (SELECT COUNT(*) FROM users), 3) * 100 AS [%]
FROM users u
WHERE u.age >= 18 AND u.age < 24

UNION ALL

SELECT '24-30' AS [возраст], COUNT(*) AS [кол-во], ROUND(CAST(COUNT(*) AS float) / (SELECT COUNT(*) FROM users), 3) * 100 AS [%]
FROM users u
WHERE u.age >= 24 AND u.age < 30

UNION ALL

SELECT 'от 24' AS [возраст], COUNT(*) AS [кол-во], ROUND(CAST(COUNT(*) AS float) / (SELECT COUNT(*) FROM users), 3) * 100 AS [%]
FROM users u
WHERE u.age >= 30

--10*. Показать 5 самых популярных слов, отправленных в личных сообщениях, и то, как часто они встречаются
CREATE TABLE Words(
	ID int not null identity(1, 1) primary key,
	Word nvarchar(100) not null,
	Amount int null)

DECLARE cursorMessage CURSOR FOR SELECT mess FROM Messages 
OPEN cursorMessage -- 
DECLARE @strMess nvarchar(500) 
DECLARE @index int = -1 
DECLARE @amount int
FETCH NEXT FROM cursorMessage INTO @strMess 
WHILE @@FETCH_STATUS = 0 
BEGIN
	DECLARE cursorWord CURSOR FOR SELECT value FROM STRING_SPLIT(@strMess, ' ')
	OPEN cursorWord
	DECLARE @strWord nvarchar(100)
	FETCH NEXT FROM cursorWord INTO @strWord
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @index = Words.ID, @amount = Words.Amount FROM Words WHERE Word = @strWord
		IF @index = -1
		BEGIN
			IF @strWord != ''
			BEGIN
				INSERT INTO Words(Word, Amount)
				VALUES (@strWord, 1)
			END
		END
		ELSE
		BEGIN
			SET @amount += 1
			UPDATE Words SET Amount = @amount WHERE ID = @index
			SET @index = -1
		END		
		FETCH NEXT FROM cursorWord INTO @strWord 
	END
	CLOSE cursorWord 
	DEALLOCATE cursorWord
	FETCH NEXT FROM cursorMessage INTO @strMess 
END 
CLOSE cursorMessage 
DEALLOCATE cursorMessage

SELECT TOP 5 * FROM Words
ORDER BY 3 DESC
TRUNCATE TABLE Words
