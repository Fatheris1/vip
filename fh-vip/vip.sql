CREATE TABLE IF NOT EXISTS `player_vip` (
    `identifier` VARCHAR(60) NOT NULL,
    `vip_level` INT(11) NOT NULL DEFAULT 1,
    `expiration` DATETIME NULL DEFAULT NULL,
    `last_daily` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`identifier`)
);