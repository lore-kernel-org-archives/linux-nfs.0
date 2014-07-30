Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f175.google.com ([209.85.217.175]:38060 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbaG3LXd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:33 -0400
Received: by mail-lb0-f175.google.com with SMTP id 10so750131lbg.6
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:32 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 05/11] mountd: define _GNU_SOURCE for statfs64 and use standard dev_t
Date: Wed, 30 Jul 2014 13:23:13 +0200
Message-Id: <1406719399-1735-6-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 utils/mountd/cache.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index b0cc6a8..b36255b 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -11,6 +11,10 @@
 #include <config.h>
 #endif
 
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+
 #include <sys/types.h>
 #include <sys/select.h>
 #include <sys/stat.h>
@@ -1419,7 +1423,7 @@ static int cache_export_ent(char *domain, struct exportent *exp, char *path)
 		 */
 		struct stat stb;
 		size_t l = strlen(exp->e_path);
-		__dev_t dev;
+		dev_t dev;
 
 		if (strlen(path) <= l || path[l] != '/' ||
 		    strncmp(exp->e_path, path, l) != 0)
-- 
2.0.3

