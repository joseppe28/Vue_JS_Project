CREATE DATABASE IF NOT EXISTS VueJSProject;

USE VueJSProject;

CREATE TABLE IF NOT EXISTS enemies (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	description TEXT NULL,
	creature_type VARCHAR(100) NULL,
	challenge_rating VARCHAR(50) NULL,
	source VARCHAR(255) NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE KEY uq_enemies_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS attributes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	code VARCHAR(10) NOT NULL,
	name VARCHAR(100) NOT NULL,
	description TEXT NULL,
	UNIQUE KEY uq_attributes_code (code),
	UNIQUE KEY uq_attributes_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enemy_attributes (
	enemy_id INT NOT NULL,
	attribute_id INT NOT NULL,
	value INT NOT NULL,
	PRIMARY KEY (enemy_id, attribute_id),
	CONSTRAINT fk_enemy_attributes_enemy
		FOREIGN KEY (enemy_id) REFERENCES enemies (id)
		ON DELETE CASCADE,
	CONSTRAINT fk_enemy_attributes_attribute
		FOREIGN KEY (attribute_id) REFERENCES attributes (id)
		ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS weapons (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	weapon_type VARCHAR(50) NOT NULL,
	combat_technique VARCHAR(100) NULL,
	damage_dice_count INT NULL,
	damage_dice_sides INT NULL,
	damage_bonus INT NULL,
	attack_mod INT NULL,
	parry_mod INT NULL,
	range_distance VARCHAR(50) NULL,
	initiative_mod INT NULL,
	load_value INT NULL,
	weight DECIMAL(6,2) NULL,
	price DECIMAL(10,2) NULL,
	hands_required TINYINT(1) NOT NULL DEFAULT 1,
	is_ranged TINYINT(1) NOT NULL DEFAULT 0,
	special_rules TEXT NULL,
	source VARCHAR(255) NULL,
	UNIQUE KEY uq_weapons_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enemy_weapons (
	enemy_id INT NOT NULL,
	weapon_id INT NOT NULL,
	is_primary TINYINT(1) NOT NULL DEFAULT 0,
	notes TEXT NULL,
	PRIMARY KEY (enemy_id, weapon_id),
	CONSTRAINT fk_enemy_weapons_enemy
		FOREIGN KEY (enemy_id) REFERENCES enemies (id)
		ON DELETE CASCADE,
	CONSTRAINT fk_enemy_weapons_weapon
		FOREIGN KEY (weapon_id) REFERENCES weapons (id)
		ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advantages (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	category VARCHAR(100) NULL,
	ap_cost INT NULL,
	description TEXT NULL,
	source VARCHAR(255) NULL,
	UNIQUE KEY uq_advantages_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS disadvantages (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	category VARCHAR(100) NULL,
	ap_cost INT NULL,
	description TEXT NULL,
	source VARCHAR(255) NULL,
	UNIQUE KEY uq_disadvantages_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS special_abilities (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	category VARCHAR(100) NULL,
	ap_cost INT NULL,
	prerequisites TEXT NULL,
	description TEXT NULL,
	source VARCHAR(255) NULL,
	UNIQUE KEY uq_special_abilities_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enemy_advantages (
	enemy_id INT NOT NULL,
	advantage_id INT NOT NULL,
	notes TEXT NULL,
	PRIMARY KEY (enemy_id, advantage_id),
	CONSTRAINT fk_enemy_advantages_enemy
		FOREIGN KEY (enemy_id) REFERENCES enemies (id)
		ON DELETE CASCADE,
	CONSTRAINT fk_enemy_advantages_advantage
		FOREIGN KEY (advantage_id) REFERENCES advantages (id)
		ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enemy_disadvantages (
	enemy_id INT NOT NULL,
	disadvantage_id INT NOT NULL,
	notes TEXT NULL,
	PRIMARY KEY (enemy_id, disadvantage_id),
	CONSTRAINT fk_enemy_disadvantages_enemy
		FOREIGN KEY (enemy_id) REFERENCES enemies (id)
		ON DELETE CASCADE,
	CONSTRAINT fk_enemy_disadvantages_disadvantage
		FOREIGN KEY (disadvantage_id) REFERENCES disadvantages (id)
		ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enemy_special_abilities (
	enemy_id INT NOT NULL,
	special_ability_id INT NOT NULL,
	notes TEXT NULL,
	PRIMARY KEY (enemy_id, special_ability_id),
	CONSTRAINT fk_enemy_special_abilities_enemy
		FOREIGN KEY (enemy_id) REFERENCES enemies (id)
		ON DELETE CASCADE,
	CONSTRAINT fk_enemy_special_abilities_special_ability
		FOREIGN KEY (special_ability_id) REFERENCES special_abilities (id)
		ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO attributes (code, name) VALUES
	('MU', 'Mut'),
	('KL', 'Klugheit'),
	('IN', 'Intuition'),
	('CH', 'Charisma'),
	('FF', 'Fingerfertigkeit'),
	('GE', 'Gewandtheit'),
	('KO', 'Konstitution'),
	('KK', 'Körperkraft');