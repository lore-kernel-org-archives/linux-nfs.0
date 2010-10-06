Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756894Ab0JFQJY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Oct 2010 12:09:24 -0400
Received: from localhost.localdomain (sanjayk3-lxp.hq.netapp.com [10.58.62.92] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o96G9NZs013981
	for <linux-nfs@vger.kernel.org>; Wed, 6 Oct 2010 09:09:24 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] Don't check exchange flags unless using v4.1 try 2
Date: Wed,  6 Oct 2010 12:09:22 -0400
Message-Id: <1286381362-5639-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7013916..4b33cde 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -141,6 +141,9 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 
 	if (id == 0)
 		goto out_no_driver;
+	if ((server->nfs_client->rpc_ops->version != 4) ||
+	    (server->nfs_client->cl_minorversion != 1))
+		goto out_no_driver;
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
 		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
-- 
1.7.2.1

