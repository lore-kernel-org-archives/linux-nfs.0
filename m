Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41382 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbbAVLLM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:12 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 02/20] fs: track fl_owner for leases
Date: Thu, 22 Jan 2015 12:09:48 +0100
Message-Id: <1421925006-24231-3-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just like for other lock types we should allow different owners to have
a read lease on a file.  Currently this can't happen, but with the addition
of pNFS layout leases we'll need this feature.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c          | 12 +++++++-----
 fs/nfsd/nfs4state.c |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 2fc36b3..65350a23 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1661,7 +1661,8 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	 */
 	error = -EAGAIN;
 	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
-		if (fl->fl_file == filp) {
+		if (fl->fl_file == filp &&
+		    fl->fl_owner == lease->fl_owner) {
 			my_fl = fl;
 			continue;
 		}
@@ -1721,7 +1722,7 @@ out:
 	return error;
 }
 
-static int generic_delete_lease(struct file *filp)
+static int generic_delete_lease(struct file *filp, void *owner)
 {
 	int error = -EAGAIN;
 	struct file_lock *fl, *victim = NULL;
@@ -1737,7 +1738,8 @@ static int generic_delete_lease(struct file *filp)
 
 	spin_lock(&ctx->flc_lock);
 	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
-		if (fl->fl_file == filp) {
+		if (fl->fl_file == filp &&
+		    fl->fl_owner == owner) {
 			victim = fl;
 			break;
 		}
@@ -1778,7 +1780,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 
 	switch (arg) {
 	case F_UNLCK:
-		return generic_delete_lease(filp);
+		return generic_delete_lease(filp, *priv);
 	case F_RDLCK:
 	case F_WRLCK:
 		if (!(*flp)->fl_lmops->lm_break) {
@@ -1857,7 +1859,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 {
 	if (arg == F_UNLCK)
-		return vfs_setlease(filp, F_UNLCK, NULL, NULL);
+		return vfs_setlease(filp, F_UNLCK, NULL, (void **)&filp);
 	return do_fcntl_add_lease(fd, filp, arg);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 532a60c..30ff0d4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -693,7 +693,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	spin_unlock(&fp->fi_lock);
 
 	if (filp) {
-		vfs_setlease(filp, F_UNLCK, NULL, NULL);
+		vfs_setlease(filp, F_UNLCK, NULL, (void **)&fp);
 		fput(filp);
 	}
 }
-- 
1.9.1

