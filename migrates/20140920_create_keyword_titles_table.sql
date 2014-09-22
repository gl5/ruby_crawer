# Dump of table keyword_titles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `keyword_titles`;

CREATE TABLE `keyword_titles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'title ID',
  `keyword_id` int(10) unsigned NOT NULL COMMENT '关键字ID',
  `title` varchar(255) NOT NULL COMMENT 'title',
  `domain` varchar(255) NOT NULL COMMENT 'title domain',
  `status` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='关键字 title 表';
