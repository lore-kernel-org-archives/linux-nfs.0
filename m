Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52449 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755985Ab1FGRfK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:10 -0400
Date: Tue, 7 Jun 2011 13:35:08 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 78/88] SQUASHME: pnfs-block: use {set,clear}_layoutdriver
Message-ID: <e59207ae01fc605beea5e31953ce7dc2687d01fa.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Methods renamed by Trond as of 2.6.37

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 57a7f04..5be912e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -752,7 +752,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
  * Retrieve the list of available devices for the mountpoint.
  */
 static int
-bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
+bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 {
 	struct block_mount_id *b_mt_id = NULL;
 	struct pnfs_mount_type *mtype = NULL;
@@ -817,7 +817,7 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 }
 
 static int
-bl_uninitialize_mountpoint(struct nfs_server *server)
+bl_clear_layoutdriver(struct nfs_server *server)
 {
 	struct block_mount_id *b_mt_id = server->pnfs_ld_data;
 
@@ -1114,8 +1114,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.setup_layoutcommit		= bl_setup_layoutcommit,
 	.encode_layoutcommit		= bl_encode_layoutcommit,
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
-	.initialize_mountpoint		= bl_initialize_mountpoint,
-	.uninitialize_mountpoint	= bl_uninitialize_mountpoint,
+	.set_layoutdriver		= bl_set_layoutdriver,
+	.clear_layoutdriver		= bl_clear_layoutdriver,
 	.pg_test			= bl_pg_test,
 };
 
-- 
1.7.4.1

