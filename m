Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab0LWMry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 07:47:54 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/15] pnfs: remove unnecessary field lgp->status
Date: Thu, 23 Dec 2010 07:47:33 -0500
Message-Id: <1293108466-31768-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
References: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    3 +--
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fcf2658..f475516 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5330,7 +5330,6 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			return;
 		}
 	}
-	lgp->status = task->tk_status;
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -5386,7 +5385,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status != 0)
 		goto out;
-	status = lgp->status;
+	status = task->tk_status;
 	if (status != 0)
 		goto out;
 	status = pnfs_layout_process(lgp);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d325def..f923831 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -223,7 +223,6 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
 	struct pnfs_layout_segment **lsegpp;
-	int status;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
1.7.2.1

