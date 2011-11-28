Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17154 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325Ab1K1NgO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Nov 2011 08:36:14 -0500
Subject: [PATCH 4/6] NFS: create callback transports in parent transport
	network namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 28 Nov 2011 17:33:54 +0300
Message-ID: <20111128133354.4251.33201.stgit@localhost6.localdomain6>
In-Reply-To: <20111128132805.4251.15252.stgit@localhost6.localdomain6>
References: <20111128132805.4251.15252.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces static "init_net" references with parent transport xprt_net
reference. Thus callback transports will be created in the same network
namespace as respective NFS mount point was created.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..1d04f9d 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -102,11 +102,11 @@ nfs4_callback_svc(void *vrqstp)
  * Prepare to bring up the NFSv4 callback service
  */
 struct svc_rqst *
-nfs4_callback_up(struct svc_serv *serv)
+nfs4_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 {
 	int ret;
 
-	ret = svc_create_xprt(serv, "tcp", &init_net, PF_INET,
+	ret = svc_create_xprt(serv, "tcp", xprt->xprt_net, PF_INET,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_err;
@@ -114,7 +114,7 @@ nfs4_callback_up(struct svc_serv *serv)
 	dprintk("NFS: Callback listener port = %u (af %u)\n",
 			nfs_callback_tcpport, PF_INET);
 
-	ret = svc_create_xprt(serv, "tcp", &init_net, PF_INET6,
+	ret = svc_create_xprt(serv, "tcp", xprt->xprt_net, PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
 		nfs_callback_tcpport6 = ret;
@@ -183,7 +183,7 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 	 * fore channel connection.
 	 * Returns the input port (0) and sets the svc_serv bc_xprt on success
 	 */
-	ret = svc_create_xprt(serv, "tcp-bc", &init_net, PF_INET, 0,
+	ret = svc_create_xprt(serv, "tcp-bc", xprt->xprt_net, PF_INET, 0,
 			      SVC_SOCK_ANONYMOUS);
 	if (ret < 0) {
 		rqstp = ERR_PTR(ret);
@@ -269,7 +269,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 					serv, xprt, &rqstp, &callback_svc);
 	if (!minorversion_setup) {
 		/* v4.0 callback setup */
-		rqstp = nfs4_callback_up(serv);
+		rqstp = nfs4_callback_up(serv, xprt);
 		callback_svc = nfs4_callback_svc;
 	}
 

