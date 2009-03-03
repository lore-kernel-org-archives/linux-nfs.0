From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/17] NFS: Start PF_INET6 callback listener only if IPv6
	support is available
Date: Tue, 03 Mar 2009 17:34:18 -0500
Message-ID: <20090303223417.2933.29513.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:52509 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbZCCWfI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:35:08 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apparently a lot of people need to disable IPv6 completely on their
distributor-built systems, which have CONFIG_IPV6_MODULE enabled.

They do this by blacklisting the ipv6.ko module.  This causes the
creation of the NFSv4 callback service listener to fail if
CONFIG_IPV6_MODULE is set, but the module cannot be loaded.

Now that the kernel's PF_INET6 RPC listeners are completely separate
from PF_INET listeners, we can always start PF_INET.  Then the NFS
client can try to start a PF_INET6 listener, but it isn't required
to be available.

Note this has the added benefit that NFS callbacks from AF_INET6
servers will never come from AF_INET remotes.  We no longer have to
worry about matching mapped IPv4 addresses to AF_INET when comparing
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback.c  |   12 ++++++++++++
 fs/nfs/callback.h  |    1 +
 fs/nfs/nfs4state.c |   10 ++++++++--
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 0ef47df..a886e69 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -38,6 +38,7 @@ static struct svc_program nfs4_callback_program;
 
 unsigned int nfs_callback_set_tcpport;
 unsigned short nfs_callback_tcpport;
+unsigned short nfs_callback_tcpport6;
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
 
@@ -119,6 +120,17 @@ int nfs_callback_up(void)
 	dprintk("NFS: Callback listener port = %u (af %u)\n",
 			nfs_callback_tcpport, PF_INET);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	ret = svc_create_xprt(serv, "tcp", PF_INET6,
+				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
+	if (ret > 0) {
+		nfs_callback_tcpport6 = ret;
+		dprintk("NFS: Callback listener port = %u (af %u)\n",
+				nfs_callback_tcpport6, PF_INET6);
+	} else if (ret != -EAFNOSUPPORT)
+		goto out_err;
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+
 	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(nfs_callback_info.rqst)) {
 		ret = PTR_ERR(nfs_callback_info.rqst);
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index bb25d21..e110e28 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -72,5 +72,6 @@ extern void nfs_callback_down(void);
 
 extern unsigned int nfs_callback_set_tcpport;
 extern unsigned short nfs_callback_tcpport;
+extern unsigned short nfs_callback_tcpport6;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2022fe4..0298e90 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -62,8 +62,14 @@ static LIST_HEAD(nfs4_clientid_list);
 
 static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
 {
-	int status = nfs4_proc_setclientid(clp, NFS4_CALLBACK,
-			nfs_callback_tcpport, cred);
+	unsigned short port;
+	int status;
+
+	port = nfs_callback_tcpport;
+	if (clp->cl_addr.ss_family == AF_INET6)
+		port = nfs_callback_tcpport6;
+
+	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred);
 	if (status == 0)
 		status = nfs4_proc_setclientid_confirm(clp, cred);
 	if (status == 0)

