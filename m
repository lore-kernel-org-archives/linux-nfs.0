Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51453 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRcY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:24 -0400
Date: Tue, 7 Jun 2011 13:32:22 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 53/88] SQUASHME: pnfsblock: set pnfs_blksize before calling
 set_pnfs_layoutdriver
Message-ID: <42fb2e3c62b48871bbc27b72dc98f49ee49a412f.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

For block/volume layout driver, set_pnfs_layoutdriver will call
initialize_mountpoint() which will check the value of pnfs_blksize.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6c6236b..b2c6920 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -937,8 +937,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fh *mntf
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 	server->pnfs_blksize = fsinfo->blksize;
+	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
-- 
1.7.4.1

