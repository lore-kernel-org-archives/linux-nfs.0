Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37246 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbaCYPYP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 11:24:15 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2PFNe7b018091
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Mar 2014 11:24:14 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-54-69.rdu2.redhat.com [10.10.54.69])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s2PFAFKn006246
	for <linux-nfs@vger.kernel.org>; Tue, 25 Mar 2014 11:10:15 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmap: Keys need to be invalidated instead of revoked
Date: Tue, 25 Mar 2014 11:10:12 -0400
Message-Id: <1395760212-22265-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With some recent kernel changes to the key ring
for a key to be removed they need to be invalidated
instead of revoked.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2518ed6..3f51b4d 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -166,7 +166,7 @@ static int keyring_clear(char *keyring)
 /*
  * Revoke a key 
  */
-static int key_revoke(char *keystr, int keymask)
+static int key_invalidate(char *keystr, int keymask)
 {
 	FILE *fp;
 	char buf[BUFSIZ], *ptr;
@@ -200,7 +200,7 @@ static int key_revoke(char *keystr, int keymask)
 
 		if (verbose) {
 			*(strchr(buf, '\n')) = '\0';
-			xlog_warn("revoking '%s'", buf);
+			xlog_warn("invalidating '%s'", buf);
 		}
 		/*
 		 * The key is the first arugment in the string
@@ -208,8 +208,8 @@ static int key_revoke(char *keystr, int keymask)
 		*(strchr(buf, ' ')) = '\0';
 		sscanf(buf, "%x", &key);
 
-		if (keyctl_revoke(key) < 0) {
-			xlog_err("keyctl_revoke(0x%x) failed: %m", key);
+		if (keyctl_invalidate(key) < 0) {
+			xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
 			fclose(fp);
 			return 1;
 		}
@@ -273,7 +273,7 @@ int main(int argc, char **argv)
 		}
 	}
 
-	if (rc = nfs4_init_name_mapping(PATH_IDMAPDCONF))  {
+	if ((rc = nfs4_init_name_mapping(PATH_IDMAPDCONF)))  {
 		xlog_errno(rc, "Unable to create name to user id mappings.");
 		return 1;
 	}
@@ -281,7 +281,7 @@ int main(int argc, char **argv)
 		verbose = conf_get_num("General", "Verbosity", 0);
 
 	if (keystr) {
-		rc = key_revoke(keystr, keymask);
+		rc = key_invalidate(keystr, keymask);
 		return rc;		
 	}
 	if (clearing) {
-- 
1.8.5.3

