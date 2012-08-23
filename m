Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43629 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935Ab2HWQ2g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 12:28:36 -0400
Received: by dady13 with SMTP id y13so493174dad.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 09:28:36 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH-resend 2/6] NFS41: fix error of setting blocklayoutdriver
Date: Fri, 24 Aug 2012 00:27:49 +0800
Message-Id: <1345739273-2241-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
References: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit e38eb650 (NFS: set_pnfs_layoutdriver() from
nfs4_proc_fsinfo()), set_pnfs_layoutdriver() is called inside
nfs4_proc_fsinfo(), but pnfs_blksize is not set. It causes setting
blocklayoutdriver failure and pnfsblock mount failure.

Cc: stable <stable@vger.kernel.org> [since v3.5]
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/client.c   |    1 -
 fs/nfs/nfs4proc.c |    5 ++++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9969444..0e7cd89 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -855,7 +855,6 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	server->pnfs_blksize = fsinfo->blksize;
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6352741..1653091 100644
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

