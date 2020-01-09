-- INSERT users

INSERT INTO `elicitator`.`users`(`username`,`password`,`name`,`lastname`,`role`)
VALUES('user_a',AES_ENCRYPT('&F5A$','123abc45!'),'Corrado','Lanera',1),
('user_b',AES_ENCRYPT('&F5A$','123abc45!'),'Marco','Ghidina',1),
('user_c',AES_ENCRYPT('&F5A$','123abc45!'),'Danila','Azzolina',1),
('user_d',AES_ENCRYPT('&F5A$','123abc45!'),'Paola','Berchialla',1),
('admin',AES_ENCRYPT('&F5A$','123abc45!'),'Dario','Gregori',2);

-- INSERT
INSERT INTO `opinions` (`users_id`,`date_opinion`,`perc1`,`perc25`,`perc50`,`perc75`,`perc99`)
VALUES(?,NOW(),?,?,?,?,?);
