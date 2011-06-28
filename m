Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:54634 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab1F1VTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2011 17:19:20 -0400
From: Arnaud Giersch <arnaud.giersch@free.fr>
To: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH][Resend] coredump: call vfs_getattr() to get inode attributes
Date: Tue, 28 Jun 2011 23:19:10 +0200
Message-ID: <87tyb9r6wh.fsf@free.fr>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Arnaud Giersch <arnaud.giersch@free.fr>

In do_coredump(), call vfs_getattr() to get inode attributes, and do not
get them directly from the fields of the inode struct.

Without this patch, when dumping core on an NFSv4 mount, and the i_uid
field is not correctly filled at open time, the uid check fails, and an
empty core dump is produced.

This apparently only happens when there was no "core" file before the
dump.  If a "core" file owned by the current user is already present, it
is correctly filled.

The reason is that decode_attr_owner() in fs/nfs/nfs4xdr.c is not
allowed to call the idmapper when it receives may_sleep = 0 (see commit
80e52aced138bb41b045a8595a87510f27d8d8c5, and some explanations in
http://article.gmane.org/gmane.linux.nfs/33391).

Signed-off-by: Arnaud Giersch <arnaud.giersch@free.fr>
---
 fs/exec.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 6075a1e..a016756 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -2147,7 +2147,7 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
 			goto close_fail;
  		}
 	} else {
-		struct inode *inode;
+		struct kstat stat;
 
 		if (cprm.limit < binfmt->min_coredump)
 			goto fail_unlock;
@@ -2158,8 +2158,10 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
 		if (IS_ERR(cprm.file))
 			goto fail_unlock;
 
-		inode = cprm.file->f_path.dentry->d_inode;
-		if (inode->i_nlink > 1)
+		if (vfs_getattr(cprm.file->f_path.mnt, cprm.file->f_path.dentry,
+				&stat))
+			goto close_fail;
+		if (stat.nlink > 1)
 			goto close_fail;
 		if (d_unhashed(cprm.file->f_path.dentry))
 			goto close_fail;
@@ -2167,13 +2169,13 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
 		 * AK: actually i see no reason to not allow this for named
 		 * pipes etc, but keep the previous behaviour for now.
 		 */
-		if (!S_ISREG(inode->i_mode))
+		if (!S_ISREG(stat.mode))
 			goto close_fail;
 		/*
 		 * Dont allow local users get cute and trick others to coredump
 		 * into their pre-created files.
 		 */
-		if (inode->i_uid != current_fsuid())
+		if (stat.uid != current_fsuid())
 			goto close_fail;
 		if (!cprm.file->f_op || !cprm.file->f_op->write)
 			goto close_fail;
