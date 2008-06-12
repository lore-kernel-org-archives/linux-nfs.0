From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/15] NFS: Remove the BKL from the permission checking code
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.55216.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbYFLTtW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:22 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnK1k008536
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:21 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3af2760..a42ed8f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1982,8 +1982,6 @@ int nfs_permission(struct inode *inode, int mask, struct nameidata *nd)
 	}
 
 force_lookup:
-	lock_kernel();
-
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
@@ -1993,7 +1991,6 @@ force_lookup:
 		put_rpccred(cred);
 	} else
 		res = PTR_ERR(cred);
-	unlock_kernel();
 out:
 	dfprintk(VFS, "NFS: permission(%s/%ld), mask=0x%x, res=%d\n",
 		inode->i_sb->s_id, inode->i_ino, mask, res);
@@ -2002,7 +1999,6 @@ out_notsup:
 	res = nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (res == 0)
 		res = generic_permission(inode, mask, NULL);
-	unlock_kernel();
 	goto out;
 }
 

