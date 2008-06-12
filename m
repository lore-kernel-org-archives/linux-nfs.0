From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/15] NFS: Remove BKL from the readdir code
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.41271.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375AbYFLTtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:25 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnOll008577
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:24 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Page accesses are serialised using the page locks, whereas all attribute
updates are serialised using the inode->i_lock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2be85da..9c75ec4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -534,8 +534,6 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			(long long)filp->f_pos);
 	nfs_inc_stats(inode, NFSIOS_VFSGETDENTS);
 
-	lock_kernel();
-
 	/*
 	 * filp->f_pos points to the dirent entry number.
 	 * *desc->dir_cookie has the cookie for the next entry. We have
@@ -593,7 +591,6 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	}
 out:
 	nfs_unblock_sillyrename(dentry);
-	unlock_kernel();
 	if (res > 0)
 		res = 0;
 	dfprintk(FILE, "NFS: readdir(%s/%s) returns %ld\n",

