Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41138 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277Ab0JMTyg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 15:54:36 -0400
Date: Wed, 13 Oct 2010 15:54:34 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix BUG at fs/nfsd/nfsfh.h:199 on unlink
Message-ID: <20101013195434.GB15816@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

As of commit 43a9aa64a2f4330a9cb59aaf5c5636566bce067c "NFSD:
Fill in WCC data for REMOVE, RMDIR, MKNOD, and MKDIR", we sometimes call
fh_unlock on a filehandle that isn't fully initialized.

We should fix up the callers, but as a quick fix it is also sufficient
just to remove this assertion.

Reported-by: Marius Tolzmann <tolzmann@molgen.mpg.de>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsfh.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

This is a regression from 2.6.35.  Also available from the for-2.6.36
branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.36

 fs/nfsd/nfsfh.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index cdfb8c6..c16f8d8 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -196,8 +196,6 @@ fh_lock(struct svc_fh *fhp)
 static inline void
 fh_unlock(struct svc_fh *fhp)
 {
-	BUG_ON(!fhp->fh_dentry);
-
 	if (fhp->fh_locked) {
 		fill_post_wcc(fhp);
 		mutex_unlock(&fhp->fh_dentry->d_inode->i_mutex);
-- 
1.7.2.3

