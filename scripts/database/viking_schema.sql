CREATE TABLE `cdr` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime_start` datetime NOT NULL,
  `sip_call_id` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `sip_from_user` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `sip_from_display` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `sip_to_user` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `datetime_answer` datetime NOT NULL,
  `duration` int NOT NULL DEFAULT 0,
  `rtp_audio_in_mos` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `rtp_audio_in_packet_count` int NOT NULL DEFAULT 0,
  `rtp_audio_in_skip_packet_count` int NOT NULL DEFAULT 0,
  `datetime_end` datetime NOT NULL,
  `hangup_cause` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `hangup_cause_q850` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `remote_media_ip` char(15) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `read_codec` char(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `local_public_ip` char(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `write_codec` char(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `context` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `last_app` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `last_arg` char(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY (sip_call_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE INDEX datetime_from_to ON cdr (datetime_start,sip_from_user,sip_to_user);
