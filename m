Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40020 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbcGVRtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/7] nfsd: Make creates return EEXIST instead of EACCES
Date: Fri, 22 Jul 2016 13:48:50 -0400
Message-Id: <1469209736-6490-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Oleg Drokin <green@linuxhacker.ru>

When doing a create (mkdir/mknod) on a name, it's worth
checking the name exists first before returning EACCES in case
the directory is not writeable by the user.
This makes return values on the client more consistent
regardless of whenever the entry there is cached in the local
cache or not.
Another positive side effect is certain programs only expect
EEXIST in that case even despite POSIX allowing any valid
error to be returned.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  6 +++++-
 fs/nfsd/vfs.c      | 11 ++++++++++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e0c15f879d89..9d7e1edf0cca 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -605,8 +605,12 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	fh_init(&resfh, NFS4_FHSIZE);
 
+	/*
+	 * We just check that parent is accessible here, nfsd_* do their
+	 * own access permission checks
+	 */
 	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
-			   NFSD_MAY_CREATE);
+			   NFSD_MAY_EXEC);
 	if (status)
 		return status;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6fbd81ecb410..fda4f86161f8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1161,7 +1161,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (isdotent(fname, flen))
 		goto out;
 
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+	/*
+	 * Even though it is a create, first let's see if we are even allowed
+	 * to peek inside the parent
+	 */
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
 	if (err)
 		goto out;
 
@@ -1211,6 +1215,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out; 
 	}
 
+	/* Now let's see if we actually have permissions to create */
+	err = nfsd_permission(rqstp, fhp->fh_export, dentry, NFSD_MAY_CREATE);
+	if (err)
+		goto out;
+
 	if (!(iap->ia_valid & ATTR_MODE))
 		iap->ia_mode = 0;
 	iap->ia_mode = (iap->ia_mode & S_IALLUGO) | type;
-- 
2.7.4

