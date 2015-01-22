Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:12592 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753123AbbAVO2G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:28:06 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 12/13] locks: consolidate NULL i_flctx checks in locks_remove_file
Date: Thu, 22 Jan 2015 09:27:56 -0500
Message-Id: <1421936877-27529-13-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have each of the locks_remove_* variants doing this individually.
Have the caller do it instead, and have locks_remove_flock and
locks_remove_lease just assume that it's a valid pointer.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index bd578700342d..2fc36b3772a0 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2400,6 +2400,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 EXPORT_SYMBOL(locks_remove_posix);
 
+/* The i_flctx must be valid when calling into here */
 static void
 locks_remove_flock(struct file *filp)
 {
@@ -2413,7 +2414,7 @@ locks_remove_flock(struct file *filp)
 	};
 	struct file_lock_context *flctx = file_inode(filp)->i_flctx;
 
-	if (!flctx || list_empty(&flctx->flc_flock))
+	if (list_empty(&flctx->flc_flock))
 		return;
 
 	if (filp->f_op->flock)
@@ -2425,6 +2426,7 @@ locks_remove_flock(struct file *filp)
 		fl.fl_ops->fl_release_private(&fl);
 }
 
+/* The i_flctx must be valid when calling into here */
 static void
 locks_remove_lease(struct file *filp)
 {
@@ -2433,7 +2435,7 @@ locks_remove_lease(struct file *filp)
 	struct file_lock *fl, *tmp;
 	LIST_HEAD(dispose);
 
-	if (!ctx || list_empty(&ctx->flc_lease))
+	if (list_empty(&ctx->flc_lease))
 		return;
 
 	spin_lock(&ctx->flc_lock);
@@ -2448,6 +2450,9 @@ locks_remove_lease(struct file *filp)
  */
 void locks_remove_file(struct file *filp)
 {
+	if (!file_inode(filp)->i_flctx)
+		return;
+
 	/* remove any OFD locks */
 	locks_remove_posix(filp, filp);
 
-- 
2.1.0

