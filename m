Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55510 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932206AbcLGNhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 08:37:04 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Serialize nfs_readdir()
Date: Wed,  7 Dec 2016 08:37:02 -0500
Message-Id: <a87df5d5ada87834a1cb9f1ab12ed5113d80eda7.1481117708.git.bcodding@redhat.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
In-Reply-To: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Optimizations to NFS to choose between READDIR and READDIRPLUS don't expect
concurrent users of nfs_readdir(), and can cause the pagecache to
repeatedly be invalidated unnecessarily for this case.  Fix this by
serializing nfs_readdir() on the directory's rwsem.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 53e6d6a4bc9c..8321252a4c8d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -900,6 +900,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 {
 	struct dentry	*dentry = file_dentry(file);
 	struct inode	*inode = d_inode(dentry);
+	struct nfs_inode *nfsi = NFS_I(inode);
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_open_dir_context *dir_ctx = file->private_data;
@@ -917,6 +918,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	 */
 	memset(desc, 0, sizeof(*desc));
 
+	down_write(&nfsi->rwsem);
 	desc->file = file;
 	desc->ctx = ctx;
 	desc->dir_cookie = &dir_ctx->dir_cookie;
@@ -958,6 +960,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 			break;
 	} while (!desc->eof);
 out:
+	up_write(&nfsi->rwsem);
 	if (res > 0)
 		res = 0;
 	dfprintk(FILE, "NFS: readdir(%pD2) returns %d\n", file, res);
-- 
2.5.5

