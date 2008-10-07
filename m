From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/30] NFS: Fix nfs_file_llseek()
Date: Tue, 07 Oct 2008 18:19:52 -0400
Message-ID: <20081007221952.20945.46579.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756139AbYJGWct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:49 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0X025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:47 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After the BKL removal patches were applied to the rest of the NFS code, the
BKL protection in nfs_file_llseek() is no longer sufficient to ensure that
inode->i_size is read safely in generic_file_llseek_unlocked().

In order to fix the situation, we either have to replace the naked read of
inode->i_size in generic_file_llseek_unlocked() with i_size_read(), or the
whole thing needs to be executed under the inode->i_lock;
In order to avoid disrupting other filesystems, avoid touching
generic_file_llseek_unlocked() for now...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7846065..3ddb004 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -188,13 +188,16 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 	/* origin == SEEK_END => we must revalidate the cached file length */
 	if (origin == SEEK_END) {
 		struct inode *inode = filp->f_mapping->host;
+
 		int retval = nfs_revalidate_file_size(inode, filp);
 		if (retval < 0)
 			return (loff_t)retval;
-	}
-	lock_kernel();	/* BKL needed? */
-	loff = generic_file_llseek_unlocked(filp, offset, origin);
-	unlock_kernel();
+
+		spin_lock(&inode->i_lock);
+		loff = generic_file_llseek_unlocked(filp, offset, origin);
+		spin_unlock(&inode->i_lock);
+	} else
+		loff = generic_file_llseek_unlocked(filp, offset, origin);
 	return loff;
 }
 

