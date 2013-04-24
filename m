Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755346Ab3DXPjJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 11:39:09 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UV1mn-0005Wg-H0
	for linux-nfs@vger.kernel.org; Wed, 24 Apr 2013 11:39:09 -0400
Date: Wed, 24 Apr 2013 11:39:09 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix EXDEV checking in rename
Message-ID: <20130424153909.GE20275@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We again check for the EXDEV a little later on, so the first check is
redundant.  This check is also slightly racier, since a badly timed
eviction from the export cache could leave us with the two fh_export
pointers pointing to two different cache entries which each refer to the
same underlying export.

It's better to compare vfsmounts as the later check does, but that
leaves a minor security hole in the case where the two exports refer to
two different directories especially if (for example) they have
different root-squashing options.

So, compare ex_path.dentry too.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Committing for 3.10 if nobody sees a problem with this approach.

--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2b2e239..84ce601 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1758,10 +1758,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	tdentry = tfhp->fh_dentry;
 	tdir = tdentry->d_inode;
 
-	err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
-	if (ffhp->fh_export != tfhp->fh_export)
-		goto out;
-
 	err = nfserr_perm;
 	if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
 		goto out;
@@ -1802,6 +1798,8 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	host_err = -EXDEV;
 	if (ffhp->fh_export->ex_path.mnt != tfhp->fh_export->ex_path.mnt)
 		goto out_dput_new;
+	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
+		goto out_dput_new;
 
 	host_err = nfsd_break_lease(odentry->d_inode);
 	if (host_err)
-- 
1.7.9.5

