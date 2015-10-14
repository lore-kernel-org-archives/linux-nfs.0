Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753483AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 09/10] locks: Use more file_inode and fix a comment
Date: Wed, 14 Oct 2015 14:23:36 -0400
Message-Id: <85b4a24e1b76fe40a42d1905f267b19b9e27acc6.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 2a54c80..8efd9f8 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1711,8 +1711,7 @@ static int generic_delete_lease(struct file *filp, void *owner)
 {
 	int error = -EAGAIN;
 	struct file_lock *fl, *victim = NULL;
-	struct dentry *dentry = filp->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode = file_inode(filp);
 	struct file_lock_context *ctx = inode->i_flctx;
 	LIST_HEAD(dispose);
 
@@ -1751,8 +1750,7 @@ static int generic_delete_lease(struct file *filp, void *owner)
 int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 			void **priv)
 {
-	struct dentry *dentry = filp->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode = file_inode(filp);
 	int error;
 
 	if ((!uid_eq(current_fsuid(), inode->i_uid)) && !capable(CAP_LEASE))
@@ -2107,7 +2105,7 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
 	return error;
 }
 
-/* Ensure that fl->fl_filp has compatible f_mode for F_SETLK calls */
+/* Ensure that fl->fl_file has compatible f_mode for F_SETLK calls */
 static int
 check_fmode_for_setlk(struct file_lock *fl)
 {
-- 
1.7.1

