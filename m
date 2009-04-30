From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 18/39] nfs41: save svc_serv in nfs_callback_info
Date: Fri,  1 May 2009 02:22:12 +0300
Message-ID: <1241133732-890-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29487 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757201AbZD3XWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:20 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to pass the svc_serv* to the xprt when nfs_callback_info.users > 0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 8d7c142..4bf60b2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -31,6 +31,7 @@
 
 struct nfs_callback_data {
 	unsigned int users;
+	struct svc_serv *serv;
 	struct svc_rqst *rqst;
 	struct task_struct *task;
 };
@@ -262,6 +263,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	svc_sock_update_bufs(serv);
 
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
+	nfs_callback_info.serv = serv;
 	nfs_callback_info.rqst = rqstp;
 	nfs_callback_info.task = kthread_run(callback_svc,
 					     nfs_callback_info.rqst,
@@ -269,6 +271,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	if (IS_ERR(nfs_callback_info.task)) {
 		ret = PTR_ERR(nfs_callback_info.task);
 		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.serv = NULL;
 		nfs_callback_info.rqst = NULL;
 		nfs_callback_info.task = NULL;
 		goto out_err;
@@ -301,6 +304,7 @@ void nfs_callback_down(void)
 	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL) {
 		kthread_stop(nfs_callback_info.task);
 		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.serv = NULL;
 		nfs_callback_info.rqst = NULL;
 		nfs_callback_info.task = NULL;
 	}
-- 
1.6.2.1

