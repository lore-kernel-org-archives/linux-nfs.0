Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:13028 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752884Ab1CaJmH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 05:42:07 -0400
Message-ID: <E1Q5EOD-0001a7-IQ@seldlx2151.corpusers.net>
From: Sean Finney <Sean.Finney@sonyericsson.com>
Date: Tue, 29 Mar 2011 09:48:36 +0200
Subject: [PATCH] Use a named constant for max number of managed groups, and increase it.
To: linux-nfs@vger.kernel.org
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

---
 utils/mountd/cache.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9bbbfb3..75a1052 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -37,6 +37,7 @@
 #include "blkid/blkid.h"
 #endif
 
+#define MAX_MANAGED_GROUPS 1000
 
 enum nfsd_fsid {
 	FSID_DEV = 0,
@@ -127,8 +128,8 @@ void auth_unix_gid(FILE *f)
 	 */
 	int uid;
 	struct passwd *pw;
-	gid_t glist[100], *groups = glist;
-	int ngroups = 100;
+	gid_t glist[MAX_MANAGED_GROUPS], *groups = glist;
+	int ngroups = MAX_MANAGED_GROUPS;
 	int rv, i;
 	char *cp;
 
@@ -144,7 +145,7 @@ void auth_unix_gid(FILE *f)
 		rv = -1;
 	else {
 		rv = getgrouplist(pw->pw_name, pw->pw_gid, groups, &ngroups);
-		if (rv == -1 && ngroups >= 100) {
+		if (rv == -1 && ngroups >= MAX_MANAGED_GROUPS) {
 			groups = malloc(sizeof(gid_t)*ngroups);
 			if (!groups)
 				rv = -1;
-- 
1.7.2.3

