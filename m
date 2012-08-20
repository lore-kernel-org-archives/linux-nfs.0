Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25616 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754518Ab2HTOCR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 10:02:17 -0400
Subject: [PATCH v4 01/10] NFS: pass net to nfs_callback_down()
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 20 Aug 2012 18:00:06 +0400
Message-ID: <20120820140006.17404.54487.stgit@localhost.localdomain>
In-Reply-To: <20120820134734.17404.53946.stgit@localhost.localdomain>
References: <20120820134734.17404.53946.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.c   |    4 ++--
 fs/nfs/callback.h   |    2 +-
 fs/nfs/nfs4client.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 4c8459e..51297b2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -301,7 +301,7 @@ out_err:
 /*
  * Kill the callback thread if it's no longer being used.
  */
-void nfs_callback_down(int minorversion)
+void nfs_callback_down(int minorversion, struct net *net)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 
@@ -309,7 +309,7 @@ void nfs_callback_down(int minorversion)
 	cb_info->users--;
 	if (cb_info->users == 0 && cb_info->task != NULL) {
 		kthread_stop(cb_info->task);
-		svc_shutdown_net(cb_info->serv, &init_net);
+		svc_shutdown_net(cb_info->serv, net);
 		svc_exit_thread(cb_info->rqst);
 		cb_info->serv = NULL;
 		cb_info->rqst = NULL;
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b44d7b1..3094044 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -194,7 +194,7 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
 #if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
-extern void nfs_callback_down(int minorversion);
+extern void nfs_callback_down(int minorversion, struct net *net);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
 					    const nfs4_stateid *stateid);
 extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b895629..1dfaa13 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -85,7 +85,7 @@ error:
 static void nfs4_destroy_callback(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_mvops->minor_version);
+		nfs_callback_down(clp->cl_mvops->minor_version, &init_net);
 }
 
 static void nfs4_shutdown_client(struct nfs_client *clp)

