Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:3519 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752044Ab1DHLRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Apr 2011 07:17:04 -0400
From: Sean Finney <sean.finney@sonyericsson.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Sean Finney <sean.finney@sonyericsson.com>
Subject: [PATCH v2] nfs-utils: mountd: Use a dynamic buffer for storing lists of gid's
Date: Fri, 8 Apr 2011 13:16:45 +0200
Message-ID: <1302261406-9048-1-git-send-email-sean.finney@sonyericsson.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Previously, in auth_unix_gid, group lists were stored in an array of
hard-coded length 100, and in the situation that the group lists for a
particular call were too large, the array was swapped with a dynamically
allocated/freed buffer.  For environments where users are commonly in
a large number of groups, this isn't an ideal approach.

Instead, use malloc/realloc to grow the list on an as-needed basis.

Signed-off-by: Sean Finney <sean.finney@sonyericsson.com>
---
 utils/mountd/cache.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9bbbfb3..34808cd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -37,6 +37,7 @@
 #include "blkid/blkid.h"
 #endif
 
+#define INITIAL_MANAGED_GROUPS 100
 
 enum nfsd_fsid {
 	FSID_DEV = 0,
@@ -127,11 +128,21 @@ void auth_unix_gid(FILE *f)
 	 */
 	int uid;
 	struct passwd *pw;
-	gid_t glist[100], *groups = glist;
-	int ngroups = 100;
+	static gid_t *groups = NULL;
+	static int groups_len = 0;
+	gid_t *more_groups;
+	int ngroups = 0;
 	int rv, i;
 	char *cp;
 
+	if (groups_len == 0) {
+		groups = malloc(sizeof(gid_t) * INITIAL_MANAGED_GROUPS);
+		if (!groups)
+			return;
+
+		groups_len = ngroups = INITIAL_MANAGED_GROUPS;
+	}
+
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -144,13 +155,16 @@ void auth_unix_gid(FILE *f)
 		rv = -1;
 	else {
 		rv = getgrouplist(pw->pw_name, pw->pw_gid, groups, &ngroups);
-		if (rv == -1 && ngroups >= 100) {
-			groups = malloc(sizeof(gid_t)*ngroups);
-			if (!groups)
+		if (rv == -1 && ngroups >= groups_len) {
+			more_groups = realloc(groups, sizeof(gid_t)*ngroups);
+			if (!more_groups)
 				rv = -1;
-			else
+			else {
+				groups = more_groups;
+				groups_len = ngroups;
 				rv = getgrouplist(pw->pw_name, pw->pw_gid,
 						  groups, &ngroups);
+			}
 		}
 	}
 	qword_printint(f, uid);
@@ -162,9 +176,6 @@ void auth_unix_gid(FILE *f)
 	} else
 		qword_printint(f, 0);
 	qword_eol(f);
-
-	if (groups != glist)
-		free(groups);
 }
 
 #if USE_BLKID
-- 
1.7.4.1

