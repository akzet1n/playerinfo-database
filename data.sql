CREATE TABLE `data` (
  `steamid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `data`
  ADD KEY `steamid` (`steamid`);
