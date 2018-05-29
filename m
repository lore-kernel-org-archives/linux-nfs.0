Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46837 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935213AbeE2PtD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:03 -0400
Received: by mail-io0-f193.google.com with SMTP id d22-v6so3577857iof.13
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:02 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.49.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:49:01 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFS: Set the force revalidate flag if the inode is not completely initialised
Date: Tue, 29 May 2018 11:48:35 -0400
Message-Id: <20180529154838.12903-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180529154838.12903-2-trond.myklebust@hammerspace.com>
References: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
 <20180529154838.12903-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that a delegation doesn't cause us to skip initialising the inode
if it was incomplete when we exited nfs_fhget()

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bd15d0b57626..40a6cf6db4e8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -448,6 +448,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		/* We can't support update_atime(), since the server will reset it */
 		inode->i_flags |= S_NOATIME|S_NOCMTIME;
 		inode->i_mode = fattr->mode;
+		nfsi->cache_validity = 0;
 		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
 				&& nfs_server_capable(inode, NFS_CAP_MODE))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_OTHER);
@@ -534,6 +535,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
 		}
 
+		if (nfsi->cache_validity != 0)
+			nfsi->cache_validity |= NFS_INO_REVAL_FORCED;
+
 		nfs_setsecurity(inode, fattr, label);
 
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
-- 
2.17.0

