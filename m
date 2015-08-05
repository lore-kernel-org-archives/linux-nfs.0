Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33941 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHEVNy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:54 -0400
Received: by ykax123 with SMTP id x123so46813090yka.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:53 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/18] nfsd: have _fh_update take a knfsd_fh instead of a svc_fh
Date: Wed,  5 Aug 2015 17:13:32 -0400
Message-Id: <1438809216-4846-15-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also mandates that we pass in the fh_maxsize parm as a separate
value.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsfh.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 350041a40fe5..a945500db17c 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -388,20 +388,20 @@ out:
  * an inode.  In this case a call to fh_update should be made
  * before the fh goes out on the wire ...
  */
-static void _fh_update(struct svc_fh *fhp, struct svc_export *exp,
-		struct dentry *dentry)
+static void _fh_update(struct knfsd_fh *kfh, int fh_maxsize,
+		struct svc_export *exp, struct dentry *dentry)
 {
 	if (dentry != exp->ex_path.dentry) {
-		struct fid *fid = (struct fid *)
-			(fhp->fh_handle.fh_fsid + fhp->fh_handle.fh_size/4 - 1);
-		int maxsize = (fhp->fh_maxsize - fhp->fh_handle.fh_size)/4;
+		struct fid *fid =
+			(struct fid *)(kfh->fh_fsid + kfh->fh_size/4 - 1);
+		int maxsize = (fh_maxsize - kfh->fh_size)/4;
 		int subtreecheck = !(exp->ex_flags & NFSEXP_NOSUBTREECHECK);
 
-		fhp->fh_handle.fh_fileid_type =
+		kfh->fh_fileid_type =
 			exportfs_encode_fh(dentry, fid, &maxsize, subtreecheck);
-		fhp->fh_handle.fh_size += maxsize * 4;
+		kfh->fh_size += maxsize * 4;
 	} else {
-		fhp->fh_handle.fh_fileid_type = FILEID_ROOT;
+		kfh->fh_fileid_type = FILEID_ROOT;
 	}
 }
 
@@ -574,7 +574,8 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 			exp->ex_fsid, exp->ex_uuid);
 
 		if (inode)
-			_fh_update(fhp, exp, dentry);
+			_fh_update(&fhp->fh_handle, fhp->fh_maxsize,
+					exp, dentry);
 		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID) {
 			fh_put(fhp);
 			return nfserr_opnotsupp;
@@ -605,7 +606,8 @@ fh_update(struct svc_fh *fhp)
 		if (fhp->fh_handle.fh_fileid_type != FILEID_ROOT)
 			return 0;
 
-		_fh_update(fhp, fhp->fh_export, dentry);
+		_fh_update(&fhp->fh_handle, fhp->fh_maxsize,
+				fhp->fh_export, dentry);
 		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID)
 			return nfserr_opnotsupp;
 	}
-- 
2.4.3

