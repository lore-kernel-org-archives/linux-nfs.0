Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vint.altlinux.org ([194.107.17.35]:34628 "EHLO
	vint.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab0K1VKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Nov 2010 16:10:34 -0500
From: Sergey Vlasov <vsu@altlinux.ru>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexander Morozov <amorozov@etersoft.ru>,
        Sergey Vlasov <vsu@altlinux.ru>, <stable@kernel.org>
Subject: [PATCH] NFS: Fix fcntl F_GETLK not reporting some conflicts
Date: Mon, 29 Nov 2010 00:04:05 +0300
Message-Id: <1290978245-14415-1-git-send-email-vsu@altlinux.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The commit 129a84de2347002f09721cda3155ccfd19fade40 (locks: fix F_GETLK
regression (failure to find conflicts)) fixed the posix_test_lock()
function by itself, however, its usage in NFS changed by the commit
9d6a8c5c213e34c475e72b245a8eb709258e968c (locks: give posix_test_lock
same interface as ->lock) remained broken - subsequent NFS-specific
locking code received F_UNLCK instead of the user-specified lock type.
To fix the problem, fl->fl_type needs to be saved before the
posix_test_lock() call and restored if no local conflicts were reported.

Reference: https://bugzilla.kernel.org/show_bug.cgi?id=23892
Tested-by: Alexander Morozov <amorozov@etersoft.ru>
Signed-off-by: Sergey Vlasov <vsu@altlinux.ru>
Cc: <stable@kernel.org>
---
 fs/nfs/file.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

 There seems to be a similar bug in fs/9p/vfs_file.c:v9fs_file_getlock()
 and an even worse confusion in fs/afs/flock.c:afs_do_getlk(), but I
 can't test them.

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 60677f9..7bf029e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -693,6 +693,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int status = 0;
+	unsigned int saved_type = fl->fl_type;
 
 	/* Try local locking first */
 	posix_test_lock(filp, fl);
@@ -700,6 +701,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 		/* found a conflict */
 		goto out;
 	}
+	fl->fl_type = saved_type;
 
 	if (nfs_have_delegation(inode, FMODE_READ))
 		goto out_noconflict;
-- 
1.7.3.2

