From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/30] NFS: Fix up nfs_setattr_update_inode()
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.5589.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0h025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that it sets the inode metadata under the correct spinlock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a2f5415..f3b8ed9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -453,6 +453,7 @@ out_big:
 void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 {
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0) {
+		spin_lock(&inode->i_lock);
 		if ((attr->ia_valid & ATTR_MODE) != 0) {
 			int mode = attr->ia_mode & S_IALLUGO;
 			mode |= inode->i_mode & ~S_IALLUGO;
@@ -462,7 +463,6 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 			inode->i_uid = attr->ia_uid;
 		if ((attr->ia_valid & ATTR_GID) != 0)
 			inode->i_gid = attr->ia_gid;
-		spin_lock(&inode->i_lock);
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 		spin_unlock(&inode->i_lock);
 	}

