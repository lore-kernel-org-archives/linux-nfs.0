Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021AbcERInA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2016 04:43:00 -0400
From: yongcheng.yang@gmail.com
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, yoyang@redhat.com,
        Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] mountd: update usage string to add "-P port" argument
Date: Wed, 18 May 2016 16:42:46 +0800
Message-Id: <1463560966-27405-1-git-send-email-yongcheng.yang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

Also make some change to keep the grammar consistent.

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/mountd/mountd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index b584afc..0a3a404 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -909,10 +909,10 @@ usage(const char *prog, int n)
 	fprintf(stderr,
 "Usage: %s [-F|--foreground] [-h|--help] [-v|--version] [-d kind|--debug kind]\n"
 "	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
-"	[-p|--port port] [-V version|--nfs-version version]\n"
+"	[-p port|-P port|--port port] [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
-"	[-H ha-callout prog] [-r | --reverse-lookup]\n"
-"	[-s|--state-directory-path path] [-g|--manage-gids]\n"
+"	[-H prog|--ha-callout prog] [-r|--reverse-lookup]\n"
+"	[-s path|--state-directory-path path] [-g|--manage-gids]\n"
 "	[-t num|--num-threads=num] [-u|--no-udp]\n", prog);
 	exit(n);
 }
-- 
2.4.3

