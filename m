From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 70/85] nfs41: save svc_serv in nfs_callback_info
Date: Mon, 10 Nov 2008 22:30:43 +0200
Message-ID: <1226349043-9566-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60051 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbYKJUau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:30:50 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to pass the svc_serv* to the xprt when nfs_callback_info.users > 0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index fc30f87..be8ac50 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -30,6 +30,7 @@
 
 struct nfs_callback_data {
 	unsigned int users;
+	struct svc_serv *serv;
 	struct svc_rqst *rqst;
 	struct task_struct *task;
 };
@@ -252,6 +253,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	svc_sock_update_bufs(serv);
 
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
+	nfs_callback_info.serv = serv;
 	nfs_callback_info.rqst = rqst;
 	nfs_callback_info.task = kthread_run(callback_svc,
 					     nfs_callback_info.rqst,
@@ -259,6 +261,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	if (IS_ERR(nfs_callback_info.task)) {
 		ret = PTR_ERR(nfs_callback_info.task);
 		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.serv = NULL;
 		nfs_callback_info.rqst = NULL;
 		nfs_callback_info.task = NULL;
 		goto out_err;
@@ -291,6 +294,7 @@ void nfs_callback_down(void)
 	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL) {
 		kthread_stop(nfs_callback_info.task);
 		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.serv = NULL;
 		nfs_callback_info.rqst = NULL;
 		nfs_callback_info.task = NULL;
 	}
-- 
1.6.0.2

