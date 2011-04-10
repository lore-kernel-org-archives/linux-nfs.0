Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57455 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754912Ab1DJQ3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:29:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: allow fh_verify caller to skip pseudoflavor checks
Date: Sun, 10 Apr 2011 12:29:30 -0400
Message-Id: <1302452973-27272-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20110410162536.GC26233@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsfh.c |    2 +-
 fs/nfsd/vfs.h   |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 55c8e63..90c6aa6 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -344,7 +344,7 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 	 * which clients virtually always use auth_sys for,
 	 * even while using RPCSEC_GSS for NFS.
 	 */
-	if (access & NFSD_MAY_LOCK)
+	if (access & NFSD_MAY_LOCK || access & NFSD_MAY_BYPASS_GSS)
 		goto skip_pseudoflavor_check;
 	/*
 	 * Clients may expect to be able to use auth_sys during mount,
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1036913..4d2509f 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -24,6 +24,7 @@
 #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
 #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
 #define NFSD_MAY_NOT_BREAK_LEASE 512
+#define NFSD_MAY_BYPASS_GSS	1024
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
-- 
1.7.1

