Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754908Ab1DJQ3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:29:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd: distinguish functions of NFSD_MAY_* flags
Date: Sun, 10 Apr 2011 12:29:29 -0400
Message-Id: <1302452973-27272-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20110410162536.GC26233@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Most of the NFSD_MAY_* flags actually request permissions, but over the
years we've accreted a few that modify the behavior of the permission or
open code in other ways.

Distinguish the two cases a little more.  In particular, allow the
shortcut at the start of nfsd_permission to ignore the
non-permission-requesting bits.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |    2 +-
 fs/nfsd/vfs.h |    3 +++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2e1cebd..ac4f0b4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2027,7 +2027,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	struct inode	*inode = dentry->d_inode;
 	int		err;
 
-	if (acc == NFSD_MAY_NOP)
+	if (acc & NFSD_MAY_MASK == NFSD_MAY_NOP)
 		return 0;
 #if 0
 	dprintk("nfsd: permission 0x%x%s%s%s%s%s%s%s mode 0%o%s%s%s\n",
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 9a370a5..1036913 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -17,6 +17,9 @@
 #define NFSD_MAY_SATTR		8
 #define NFSD_MAY_TRUNC		16
 #define NFSD_MAY_LOCK		32
+#define NFSD_MAY_MASK		63
+
+/* extra hints to permission and open routines: */
 #define NFSD_MAY_OWNER_OVERRIDE	64
 #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
 #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
-- 
1.7.1

