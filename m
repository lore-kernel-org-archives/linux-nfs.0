Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936095Ab3DQBy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 21:54:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: fix EXDEV checking in rename
Date: Tue, 16 Apr 2013 21:54:56 -0400
Message-Id: <1366163696-10700-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1366163696-10700-1-git-send-email-bfields@redhat.com>
References: <1366163696-10700-1-git-send-email-bfields@redhat.com>
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

