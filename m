Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:54474 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab1G0Sl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:41:29 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 23/25] pnfsblock: use pageio_ops api
Date: Wed, 27 Jul 2011 14:40:46 -0400
Message-Id: <1311792048-12551-24-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

[pnfsblock: use pnfs_generic_pg_init_read/write]
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 22de05c..502d384 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -762,6 +762,18 @@ bl_clear_layoutdriver(struct nfs_server *server)
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
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
@@ -775,6 +787,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.set_layoutdriver		= bl_set_layoutdriver,
 	.clear_layoutdriver		= bl_clear_layoutdriver,
+	.pg_read_ops			= &bl_pg_read_ops,
+	.pg_write_ops			= &bl_pg_write_ops,
 };
 
 static const struct rpc_pipe_ops bl_upcall_ops = {
-- 
1.7.4.1

