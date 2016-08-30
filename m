Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34935 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757097AbcH3AEj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:39 -0400
Received: by mail-it0-f68.google.com with SMTP id f128so631299ith.2
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] NFSv4.x: Fix up the global tracking of the callback server
Date: Mon, 29 Aug 2016 20:03:50 -0400
Message-Id: <1472515432-54202-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-4-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the nfs_callback_info[] array correctly tracks the
struct svc_serv.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 08e16f9b3333..b125f02ddf8b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -201,7 +201,6 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 
 	svc_sock_update_bufs(serv);
 
-	cb_info->serv = serv;
 	cb_info->rqst = rqstp;
 	cb_info->task = kthread_create(serv->sv_ops->svo_function,
 				    cb_info->rqst,
@@ -300,7 +299,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (cb_info->task) {
+	if (cb_info->serv) {
 		/*
 		 * Note: increase service usage, because later in case of error
 		 * svc_destroy() will be called.
@@ -333,6 +332,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 		printk(KERN_ERR "nfs_callback_create_svc: create service failed\n");
 		return ERR_PTR(-ENOMEM);
 	}
+	cb_info->serv = serv;
 	/* As there is only one thread we need to over-ride the
 	 * default maximum of 80 connections
 	 */
@@ -375,6 +375,8 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 	 * thread exits.
 	 */
 err_net:
+	if (!cb_info->users)
+		cb_info->serv = NULL;
 	svc_destroy(serv);
 err_create:
 	mutex_unlock(&nfs_callback_mutex);
@@ -396,9 +398,11 @@ void nfs_callback_down(int minorversion, struct net *net)
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_down_net(minorversion, cb_info->serv, net);
 	cb_info->users--;
-	if (cb_info->users == 0 && cb_info->task != NULL) {
-		kthread_stop(cb_info->task);
-		dprintk("nfs_callback_down: service stopped\n");
+	if (cb_info->users == 0) {
+		if (cb_info->task != NULL) {
+			kthread_stop(cb_info->task);
+			dprintk("nfs_callback_down: service stopped\n");
+		}
 		svc_exit_thread(cb_info->rqst);
 		dprintk("nfs_callback_down: service destroyed\n");
 		cb_info->serv = NULL;
-- 
2.7.4

