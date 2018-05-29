Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:41118 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936450AbeE2PtB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:01 -0400
Received: by mail-io0-f194.google.com with SMTP id t5-v6so5550350ioa.8
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:01 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.49.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:49:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFS: Fix up sillyrename()
Date: Tue, 29 May 2018 11:48:34 -0400
Message-Id: <20180529154838.12903-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
References: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that we register the fact that the inode ctime has changed.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/unlink.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index bf54fc9ae135..07f5e29ad7c6 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -448,6 +448,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	unsigned char silly[SILLYNAME_LEN + 1];
 	unsigned long long fileid;
 	struct dentry *sdentry;
+	struct inode *inode = d_inode(dentry);
 	struct rpc_task *task;
 	int            error = -EBUSY;
 
@@ -485,6 +486,8 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 			goto out;
 	} while (d_inode(sdentry) != NULL); /* need negative lookup */
 
+	ihold(inode);
+
 	/* queue unlink first. Can't do this from rpc_release as it
 	 * has to allocate memory
 	 */
@@ -509,6 +512,12 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	case 0:
 		/* The rename succeeded */
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+		spin_lock(&inode->i_lock);
+		NFS_I(inode)->attr_gencount = nfs_inc_attr_generation_counter();
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_CHANGE
+			| NFS_INO_INVALID_CTIME
+			| NFS_INO_REVAL_FORCED;
+		spin_unlock(&inode->i_lock);
 		d_move(dentry, sdentry);
 		break;
 	case -ERESTARTSYS:
@@ -519,6 +528,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	}
 	rpc_put_task(task);
 out_dput:
+	iput(inode);
 	dput(sdentry);
 out:
 	return error;
-- 
2.17.0

