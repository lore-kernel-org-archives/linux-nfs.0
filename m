Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35286 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbCIV1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 17:27:42 -0400
Received: by igqa13 with SMTP id a13so25061325igq.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 14:27:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix free_deveiceid -> free_deviceid
Date: Mon,  9 Mar 2015 17:27:26 -0400
Message-Id: <1425936446-38730-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it easier to grep for these functions by name.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         | 4 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 91e88a7ecef0..5639a2ef671a 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1086,7 +1086,7 @@ filelayout_alloc_deviceid_node(struct nfs_server *server,
 }
 
 static void
-filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
+filelayout_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
 	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
 }
@@ -1137,7 +1137,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 	.alloc_deviceid_node	= filelayout_alloc_deviceid_node,
-	.free_deviceid_node	= filelayout_free_deveiceid_node,
+	.free_deviceid_node	= filelayout_free_deviceid_node,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 315cc68945b9..edfb27ea4ce2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1414,7 +1414,7 @@ ff_layout_get_ds_info(struct inode *inode)
 }
 
 static void
-ff_layout_free_deveiceid_node(struct nfs4_deviceid_node *d)
+ff_layout_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
 	nfs4_ff_layout_free_deviceid(container_of(d, struct nfs4_ff_layout_ds,
 						  id_node));
@@ -1498,7 +1498,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.pg_read_ops		= &ff_layout_pg_read_ops,
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
-	.free_deviceid_node	= ff_layout_free_deveiceid_node,
+	.free_deviceid_node	= ff_layout_free_deviceid_node,
 	.mark_request_commit	= pnfs_layout_mark_request_commit,
 	.clear_request_commit	= pnfs_generic_clear_request_commit,
 	.scan_commit_lists	= pnfs_generic_scan_commit_lists,
-- 
2.1.0

