From: Jim Rees <rees@umich.edu>
Subject: [PATCH v1 24/25] pnfsblock: use pageio_ops api
Date: Sun, 17 Jul 2011 19:59:11 -0400
Message-ID: <1310947152-12255-25-git-send-email-rees@umich.edu>
References: <1310947152-12255-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37649 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426Ab1GQX7w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 19:59:52 -0400
In-Reply-To: <1310947152-12255-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

[pnfsblock: use pnfs_generic_pg_init_read/write]
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f2ec40e..47be8da 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -786,6 +786,18 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+static const struct nfs_pageio_ops bl_pg_read_ops = {
+	.pg_init = pnfs_generic_pg_init_read,
+	.pg_test = pnfs_generic_pg_test,
+	.pg_doio = pnfs_generic_pg_readpages,
+};
+
+static const struct nfs_pageio_ops bl_pg_write_ops = {
+	.pg_init = pnfs_generic_pg_init_write,
+	.pg_test = pnfs_generic_pg_test,
+	.pg_doio = pnfs_generic_pg_writepages,
+};
+
 static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id = LAYOUT_BLOCK_VOLUME,
 	.name = "LAYOUT_BLOCK_VOLUME",
@@ -799,6 +811,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.set_layoutdriver		= bl_set_layoutdriver,
 	.clear_layoutdriver		= bl_clear_layoutdriver,
+	.pg_read_ops			= &bl_pg_read_ops,
+	.pg_write_ops			= &bl_pg_write_ops,
 };
 
 static const struct rpc_pipe_ops bl_upcall_ops = {
-- 
1.7.4.1

