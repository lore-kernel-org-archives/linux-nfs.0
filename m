Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:43391 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1G2PzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:55:04 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v5 11/27] pnfsblock: use pageio_ops api
Date: Fri, 29 Jul 2011 11:54:36 -0400
Message-Id: <1311954892-22038-12-git-send-email-rees@umich.edu>
In-Reply-To: <1311954892-22038-1-git-send-email-rees@umich.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
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
index 55a2a95..e341c62 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -136,6 +136,18 @@ bl_clear_layoutdriver(struct nfs_server *server)
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
@@ -149,6 +161,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.set_layoutdriver		= bl_set_layoutdriver,
 	.clear_layoutdriver		= bl_clear_layoutdriver,
+	.pg_read_ops			= &bl_pg_read_ops,
+	.pg_write_ops			= &bl_pg_write_ops,
 };
 
 static int __init nfs4blocklayout_init(void)
-- 
1.7.4.1

