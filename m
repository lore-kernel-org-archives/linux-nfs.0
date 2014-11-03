Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbaKCRMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 12:12:33 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: [PATCH v2] nfsidmap: keyctl_invalidate kernel compatibility
Date: Mon,  3 Nov 2014 12:12:30 -0500
Message-Id: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the keyctl_invalidate call to use the syscall interface directly so
that when building with libkeyutils missing keyctl_invalidate the build succeeds.
Attempt to use _invalidate and fall back to _revoke if the current kernel is
missing _invalidate.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index e0d31e7..96149cc 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -209,10 +209,23 @@ static int key_invalidate(char *keystr, int keymask)
 		*(strchr(buf, ' ')) = '\0';
 		sscanf(buf, "%x", &key);
 
-		if (keyctl_invalidate(key) < 0) {
-			xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
-			fclose(fp);
-			return 1;
+/* older libkeyutils compatibility */
+#ifndef KEYCTL_INVALIDATE
+#define KEYCTL_INVALIDATE 21      /* invalidate a key */
+#endif
+		if (keyctl(KEYCTL_INVALIDATE, key) < 0) {
+			if (errno != EOPNOTSUPP) {
+				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
+				fclose(fp);
+				return 1;
+			} else {
+				/* older kernel compatibility attempt: */
+				if (keyctl_revoke(key) < 0) {
+					xlog_err("keyctl_revoke(0x%x) failed: %m", key);
+					fclose(fp);
+					return 1;
+				}
+			}
 		}
 
 		keymask &= ~mask;
-- 
1.7.1

