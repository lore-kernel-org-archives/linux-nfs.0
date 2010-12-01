Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25048 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754511Ab0LADrq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 22:47:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Fix a memory leak in nfs_readdir
Date: Tue, 30 Nov 2010 22:47:14 -0500
Message-Id: <1291175234-23824-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
References: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |    1 +
 include/linux/nfs_fs.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 314f571..0018e07 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -289,6 +289,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		} else if (S_ISDIR(inode->i_mode)) {
 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
 			inode->i_fop = &nfs_dir_operations;
+			inode->i_data.a_ops = &nfs_dir_addr_space_ops;
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c66fdb7..b5d3ab0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -401,6 +401,7 @@ extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
 extern const struct address_space_operations nfs_file_aops;
+extern const struct address_space_operations nfs_dir_addr_space_ops;
 
 static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 {
-- 
1.7.3.2

