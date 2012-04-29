Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab2D2Uu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:28 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 05/15] NFS: Optimise away nfs_check_inode_attributes() when holding a delegation
Date: Sun, 29 Apr 2012 16:50:10 -0400
Message-Id: <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already know that the attribute cache is valid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fed27c0..81946e7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -955,6 +955,8 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	unsigned long invalid = 0;
 
 
+	if (nfs_have_delegated_attributes(inode))
+		return 0;
 	/* Has the inode gone and changed behind our back? */
 	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
 		return -EIO;
-- 
1.7.7.6

