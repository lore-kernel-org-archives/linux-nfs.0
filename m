From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 112/112] NFS: Fix a potential race between umount and
	nfs_access_cache_shrinker()
Date: Fri, 25 Jan 2008 11:38:04 -0500
Message-ID: <20080125163804.31887.66981.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684AbYAYRAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:18 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UM010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:16 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks to Yawei Niu for spotting the race.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ab06b0b..a7df6bb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1681,13 +1681,19 @@ int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 restart:
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry(nfsi, &nfs_access_lru_list, access_cache_inode_lru) {
+		struct rw_semaphore *s_umount;
 		struct inode *inode;
 
 		if (nr_to_scan-- == 0)
 			break;
+		s_umount = &nfsi->vfs_inode.i_sb->s_umount;
+		if (!down_read_trylock(s_umount))
+			continue;
 		inode = igrab(&nfsi->vfs_inode);
-		if (inode == NULL)
+		if (inode == NULL) {
+			up_read(s_umount);
 			continue;
+		}
 		spin_lock(&inode->i_lock);
 		if (list_empty(&nfsi->access_cache_entry_lru))
 			goto remove_lru_entry;
@@ -1706,6 +1712,7 @@ remove_lru_entry:
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&nfs_access_lru_lock);
 		iput(inode);
+		up_read(s_umount);
 		goto restart;
 	}
 	spin_unlock(&nfs_access_lru_lock);
