Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:33717 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab1INBzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 21:55:10 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8E0YcQ9022128
	for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 20:34:38 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8E1t9vT240148
	for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 21:55:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8E1t97n015984
	for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 21:55:09 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Date: Tue, 13 Sep 2011 18:55:05 -0700
Message-Id: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

As soon as the nfs_client gets created, its cl_rpcclient is set to
ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
for the validity of cl_rpcclient before using it.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5833fbb..ff79e72 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
+	/* Check if the rpc client is initialized */
+	if (IS_ERR(clp->cl_rpcclient))
+		return 0;
+
 	seq_printf(m, "v%u %s %s %3d %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
-- 
1.7.0.4

