Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47783 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab1ADUnm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 15:43:42 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V7 04/12] NFS register and unregister back channel transport
Date: Tue,  4 Jan 2011 15:42:38 -0500
Message-Id: <1294173766-5573-5-git-send-email-andros@netapp.com>
In-Reply-To: <1294173766-5573-4-git-send-email-andros@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
 <1294173766-5573-2-git-send-email-andros@netapp.com>
 <1294173766-5573-3-git-send-email-andros@netapp.com>
 <1294173766-5573-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c              |   20 +++++++++++++++++++-
 fs/nfs/callback.h              |    2 ++
 fs/nfs/inode.c                 |    4 ++++
 include/linux/sunrpc/svcsock.h |    3 ++-
 net/sunrpc/svcsock.c           |   13 +++++++++++++
 5 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 93a8b3b..241ab70 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -221,7 +221,17 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 	if (minorversion)
 		xprt->bc_serv = cb_info->serv;
 }
-#else
+
+void nfs_init_bc_xprt(void)
+{
+	svc_init_bc_xprt_sock();
+}
+
+void nfs_cleanup_bc_xprt(void)
+{
+	svc_cleanup_bc_xprt_sock();
+}
+#else /* CONFIG_NFS_V4_1 */
 static inline int nfs_minorversion_callback_svc_setup(u32 minorversion,
 		struct svc_serv *serv, struct rpc_xprt *xprt,
 		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
@@ -233,6 +243,14 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct nfs_callback_data *cb_info)
 {
 }
+
+void nfs_init_bc_xprt(void)
+{
+}
+
+void nfs_cleanup_bc_xprt(void)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 85a7cfd..9206a2d 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -149,5 +149,7 @@ extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
 extern unsigned int nfs_callback_set_tcpport;
 extern unsigned short nfs_callback_tcpport;
 extern unsigned short nfs_callback_tcpport6;
+extern void nfs_init_bc_xprt(void);
+extern void nfs_cleanup_bc_xprt(void);
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e67e31c..28afea2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1571,6 +1571,9 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
+
+	nfs_init_bc_xprt();
+
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
@@ -1612,6 +1615,7 @@ static void __exit exit_nfs_fs(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
+	nfs_cleanup_bc_xprt();
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 3a45a80..f8755e5 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -45,8 +45,9 @@ int		svc_sock_names(struct svc_serv *serv, char *buf,
 int		svc_addsock(struct svc_serv *serv, const int fd,
 					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
-void		svc_init_bc_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
+void		svc_init_bc_xprt_sock(void);
+void		svc_cleanup_bc_xprt_sock(void);
 struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
 void		svc_sock_destroy(struct svc_xprt *);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d08a0f6..1aa322a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1227,6 +1227,19 @@ static struct svc_xprt_class svc_tcp_bc_class = {
 	.xcl_ops = &svc_tcp_bc_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
+
+void svc_init_bc_xprt_sock(void)
+{
+	svc_reg_xprt_class(&svc_tcp_bc_class);
+}
+EXPORT_SYMBOL_GPL(svc_init_bc_xprt_sock);
+
+void svc_cleanup_bc_xprt_sock(void)
+{
+	svc_unreg_xprt_class(&svc_tcp_bc_class);
+}
+EXPORT_SYMBOL_GPL(svc_cleanup_bc_xprt_sock);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static struct svc_xprt_ops svc_tcp_ops = {
-- 
1.6.6

