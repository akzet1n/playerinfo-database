
CREATE TABLE `data` (
  `steamid` varchar(32) NOT NULL,
  `first_visit` datetime NOT NULL,
  `last_visit` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `data`
  ADD UNIQUE KEY `steamid` (`steamid`);
