Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755705Ab0KLItX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:23 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fC025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:08 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/22] pnfs-submit: remove unnecessary field lgp->status
Date: Fri, 12 Nov 2010 03:48:24 -0500
Message-Id: <1289551724-18575-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    3 +--
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ce322e5..d01068c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5395,7 +5395,6 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			return;
 		}
 	}
-	lgp->status = task->tk_status;
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -5451,7 +5450,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status != 0)
 		goto out;
-	status = lgp->status;
+	status = task->tk_status;
 	if (status != 0)
 		goto out;
 	status = pnfs_layout_process(lgp);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1ff6cb0..53a4d2f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -223,7 +223,6 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
 	struct pnfs_layout_segment **lsegpp;
-	int status;
 };
 
 struct nfs4_layoutcommit_args {
-- 
1.7.2.1

