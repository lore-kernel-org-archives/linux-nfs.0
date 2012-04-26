Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9665 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757848Ab2DZPzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 11:55:11 -0400
Subject: [PATCH 01/10] NFS: pass net to nfs_callback_down()
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 26 Apr 2012 19:54:59 +0400
Message-ID: <20120426155459.3763.16742.stgit@localhost6.localdomain6>
In-Reply-To: <20120426155250.3763.98748.stgit@localhost6.localdomain6>
References: <20120426155250.3763.98748.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c |    4 ++--
 fs/nfs/callback.h |    2 +-
 fs/nfs/client.c   |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index cff3940..d5bb1ae 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -322,7 +322,7 @@ out_err:
 /*
  * Kill the callback thread if it's no longer being used.
  */
-void nfs_callback_down(int minorversion)
+void nfs_callback_down(int minorversion, struct net *net)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 
@@ -330,7 +330,7 @@ void nfs_callback_down(int minorversion)
 	cb_info->users--;
 	if (cb_info->users == 0 && cb_info->task != NULL) {
 		kthread_stop(cb_info->task);
-		svc_shutdown_net(cb_info->serv, current->nsproxy->net_ns);
+		svc_shutdown_net(cb_info->serv, net);
 		svc_exit_thread(cb_info->rqst);
 		cb_info->serv = NULL;
 		cb_info->rqst = NULL;
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index a5527c9..6d900cf 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -194,7 +194,7 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
-extern void nfs_callback_down(int minorversion);
+extern void nfs_callback_down(int minorversion, struct net *net);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
 					    const nfs4_stateid *stateid);
 extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index da7b5e4..44cd70f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -222,7 +222,7 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 static void nfs4_destroy_callback(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_mvops->minor_version);
+		nfs_callback_down(clp->cl_mvops->minor_version, clp->net);
 }
 
 static void nfs4_shutdown_client(struct nfs_client *clp)

