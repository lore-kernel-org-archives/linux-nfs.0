Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f170.google.com ([209.85.217.170]:40089 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697AbaHFGZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:19 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so1564101lbi.29
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:18 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 05/11] mountd: use standard dev_t instead of glibc internals
Date: Wed,  6 Aug 2014 08:25:00 +0200
Message-Id: <1407306306-29796-6-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The __dev_t is a GNU libc internal. Use the standard dev_t instead,
which is specified in POSIX.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 utils/mountd/cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index b0cc6a8..663a52a 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1419,7 +1419,7 @@ static int cache_export_ent(char *domain, struct exportent *exp, char *path)
 		 */
 		struct stat stb;
 		size_t l = strlen(exp->e_path);
-		__dev_t dev;
+		dev_t dev;
 
 		if (strlen(path) <= l || path[l] != '/' ||
 		    strncmp(exp->e_path, path, l) != 0)
-- 
2.0.4

