From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/17] NSM: convert printk(KERN_DEBUG) to a dprintk()
Date: Thu, 04 Dec 2008 14:20:31 -0500
Message-ID: <20081204192030.8039.43827.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:21684 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbYLDTVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:24 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: make the printk(KERN_DEBUG) in nsm_mon_unmon() a dprintk,
and add another dprintk to note if creating an RPC client for the
upcall failed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 65b4e60..2694a49 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -52,6 +52,8 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	clnt = nsm_create();
 	if (IS_ERR(clnt)) {
 		status = PTR_ERR(clnt);
+		dprintk("lockd: failed to create NSM upcall transport, "
+				"status=%d\n", status);
 		goto out;
 	}
 
@@ -60,8 +62,8 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 	status = rpc_call_sync(clnt, &msg, 0);
 	if (status < 0)
-		printk(KERN_DEBUG "nsm_mon_unmon: rpc failed, status=%d\n",
-			status);
+		dprintk("lockd: NSM upcall RPC failed, status=%d\n",
+				status);
 	else
 		status = 0;
 	rpc_shutdown_client(clnt);

