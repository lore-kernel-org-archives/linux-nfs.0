From: Pavel Shilovsky <piastry@etersoft.ru>
Subject: [PATCH] mountd: Fix missing varialble assigment in auth_unix_gid
Date: Wed,  1 Jun 2011 22:49:54 +0400
Message-ID: <1306954194-2392-1-git-send-email-piastry@etersoft.ru>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38884 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab1FASul (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 14:50:41 -0400
Received: by bwz15 with SMTP id 15so302255bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2011 11:50:40 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we get into auth_unix_gid at the second time, groups_len
is not 0 and ngroups variable leave as 0. Then we use ngroups
in getgrouplist that fails in this case. This patch fixes it.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 utils/mountd/cache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index df6b38f..dbe20e9 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -138,7 +138,7 @@ static void auth_unix_gid(FILE *f)
 	static gid_t *groups = NULL;
 	static int groups_len = 0;
 	gid_t *more_groups;
-	int ngroups = 0;
+	int ngroups;
 	int rv, i;
 	char *cp;
 
@@ -147,9 +147,11 @@ static void auth_unix_gid(FILE *f)
 		if (!groups)
 			return;
 
-		groups_len = ngroups = INITIAL_MANAGED_GROUPS;
+		groups_len = INITIAL_MANAGED_GROUPS;
 	}
 
+	ngroups = groups_len;
+
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
-- 
1.7.4.5

