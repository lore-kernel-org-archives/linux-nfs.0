Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42428 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758588Ab2HHO5w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 10:57:52 -0400
Received: by pbbrr13 with SMTP id rr13so1581044pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 07:57:52 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2] NFS41: fix error of setting blocklayoutdriver
Date: Wed,  8 Aug 2012 22:57:25 +0800
Message-Id: <1344437845-2356-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit e38eb650 (NFS: set_pnfs_layoutdriver() from
nfs4_proc_fsinfo()), set_pnfs_layoutdriver() is called inside
nfs4_proc_fsinfo(), but pnfs_blksize is not set. It causes setting
blocklayoutdriver failure and pnfsblock mount failure.

Cc: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/client.c   |    1 -
 fs/nfs/nfs4proc.c |    5 ++++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9fc0d9d..a53a538 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -855,7 +855,6 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	server->pnfs_blksize = fsinfo->blksize;
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78b2163..299c311 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3362,8 +3362,11 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
 
 	nfs_fattr_init(fsinfo->fattr);
 	error = nfs4_do_fsinfo(server, fhandle, fsinfo);
-	if (error == 0)
+	if (error == 0) {
+		/* block layout checks this! */
+		server->pnfs_blksize = fsinfo->blksize;
 		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
+	}
 
 	return error;
 }
-- 
1.7.1.262.g5ef3d

