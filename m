From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/7] nfsd: special readdir exception for V4ROOT
Date: Tue,  1 Dec 2009 19:39:40 -0500
Message-ID: <1259714383-32577-5-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Code here is a little ugly; maybe do some cleanup first.
---
 fs/nfsd/nfs4xdr.c |   10 +++++++---
 fs/nfsd/vfs.c     |    2 +-
 fs/nfsd/vfs.h     |    1 +
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index db0fc55..931fa96 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2205,11 +2205,14 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 	 * we will not follow the cross mount and will fill the attribtutes
 	 * directly from the mountpoint dentry.
 	 */
-	if (d_mountpoint(dentry) && !attributes_need_mount(cd->rd_bmval))
-		ignore_crossmnt = 1;
-	else if (d_mountpoint(dentry)) {
+	if (nfsd_mountpoint(dentry, exp)) {
 		int err;
 
+		if (!(exp->ex_flags & NFSEXP_V4ROOT)
+				&& !attributes_need_mount(cd->rd_bmval)) {
+			ignore_crossmnt = 1;
+			goto out_encode;
+		}
 		/*
 		 * Why the heck aren't we just using nfsd_lookup??
 		 * Different "."/".." handling?  Something else?
@@ -2225,6 +2228,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 			goto out_put;
 
 	}
+out_encode:
 	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
 					cd->rd_rqstp, ignore_crossmnt);
 out_put:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5136e61..caf4794 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -188,7 +188,7 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
  * For nfsd purposes, we treat V4ROOT exports as though there was an
  * export at *every* directory.
  */
-static int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
+int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 {
 	if (d_mountpoint(dentry))
 		return 1;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index b8011fd..f4fa6d3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -40,6 +40,7 @@ __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
 				struct svc_export **, struct dentry **);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 				struct iattr *, int, time_t);
+int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
                     struct nfs4_acl *);
-- 
1.6.3.3

