From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3/3] nfsd: minor nfsd_vfs_write cleanup
Date: Wed, 17 Jun 2009 12:59:31 -0400
Message-ID: <1245257971-22757-3-git-send-email-bfields@fieldses.org>
References: <20090617165442.GE21311@fieldses.org>
 <1245257971-22757-1-git-send-email-bfields@fieldses.org>
 <1245257971-22757-2-git-send-email-bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Steve Dickson <steved@redhat.com>,
	Tom Talpey <tmtalpey@gmail.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60123 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbZFQQ7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 12:59:31 -0400
In-Reply-To: <1245257971-22757-2-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

There's no need to check host_err >= 0 every time here when we could
check host_err < 0 once, following the usual kernel style.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6ad76a4..1cf7061 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1053,19 +1053,20 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	oldfs = get_fs(); set_fs(KERNEL_DS);
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
-	if (host_err >= 0) {
-		*cnt = host_err;
-		nfsdstats.io_write += host_err;
-		fsnotify_modify(file->f_path.dentry);
-	}
+	if (host_err < 0)
+		goto out_nfserr;
+	*cnt = host_err;
+	nfsdstats.io_write += host_err;
+	fsnotify_modify(file->f_path.dentry);
 
 	/* clear setuid/setgid flag after write */
-	if (host_err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
+	if (inode->i_mode & (S_ISUID | S_ISGID))
 		kill_suid(dentry);
 
-	if (host_err >= 0 && stable && use_wgather)
+	if (stable && use_wgather)
 		host_err = wait_for_concurrent_writes(file);
 
+out_nfserr:
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
 	if (host_err >= 0)
 		err = 0;
-- 
1.6.0.4

