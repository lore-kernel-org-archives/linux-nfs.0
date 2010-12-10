Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab0LJGIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:47 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLl023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:47 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/22] pnfs-submit: wave4: fix bug dealing with commit split between DS and MDS
Date: Thu,  9 Dec 2010 20:22:45 -0500
Message-Id: <1291944177-7819-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The file layout driver could send the wrong data structure to the MDS
on a commit split between DS and MDS.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 055816a..fb0efda 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -497,6 +497,7 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 	struct list_head **ds_page_list = NULL;
 	u16 *indices_used;
 	int num_indices_seen = 0;
+	bool used_mds = false;
 	const struct rpc_call_ops *call_ops;
 	struct rpc_clnt *clnt;
 	struct nfs_write_data **clone_list = NULL;
@@ -546,11 +547,21 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 	if (!clone_list)
 		goto mem_error;
 	for (i = 0; i < num_indices_seen - 1; i++) {
+		if (indices_used[i] == NFS4_PNFS_MAX_MULTI_CNT) {
+			used_mds = true;
+			clone_list[i] = data;
+		} else {
+			clone_list[i] = filelayout_clone_write_data(data);
+			if (!clone_list[i])
+				goto mem_error;
+		}
+	}
+	if (used_mds) {
 		clone_list[i] = filelayout_clone_write_data(data);
 		if (!clone_list[i])
 			goto mem_error;
-	}
-	clone_list[i] = data;
+	} else
+		clone_list[i] = data;
 	/*
 	 * Now send off the RPCs to each ds.  Note that it is important
 	 * that any RPC to the MDS be sent last (or at least after all
-- 
1.7.2.1

