Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756618Ab2EJUr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 16:47:26 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 2/3] NFS: Make v2 configurable
Date: Thu, 10 May 2012 16:47:19 -0400
Message-Id: <1336682840-10799-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
References: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

With this patch NFS v2 can be disabled during Kconfig.  I default the
option to "y" to match the current behavior.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig  |   10 ++++++++++
 fs/nfs/Makefile |    5 +++--
 fs/nfs/client.c |   16 ++++++++++++++--
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 2a0e6c5..66b0f4c 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -29,6 +29,16 @@ config NFS_FS
 
 	  If unsure, say N.
 
+config NFS_V2
+	bool "NFS client support for NFS version 2"
+	depends on NFS_FS
+	default y
+	help
+	  This option enables support for version 2 of the NFS protocol
+	  (RFC 1094) in the kernel's NFS client.
+
+	  If unsure, say Y.
+
 config NFS_V3
 	bool "NFS client support for NFS version 3"
 	depends on NFS_FS
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index b58613d..7ddd45d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -4,11 +4,12 @@
 
 obj-$(CONFIG_NFS_FS) += nfs.o
 
-nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
-			   direct.o pagelist.o proc.o read.o symlink.o unlink.o \
+nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
+			   direct.o pagelist.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
+nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a8f8de6..8f1c652 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -90,7 +90,9 @@ static bool nfs4_disable_idmapping = true;
  * RPC cruft for NFS
  */
 static const struct rpc_version *nfs_version[5] = {
+#ifdef CONFIG_NFS_V2
 	[2]			= &nfs_version2,
+#endif
 #ifdef CONFIG_NFS_V3
 	[3]			= &nfs_version3,
 #endif
@@ -847,7 +849,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
-		.rpc_ops = &nfs_v2_clientops,
+		.rpc_ops = NULL,
 		.proto = data->nfs_server.protocol,
 		.net = data->net,
 	};
@@ -857,10 +859,20 @@ static int nfs_init_server(struct nfs_server *server,
 
 	dprintk("--> nfs_init_server()\n");
 
+	switch (data->version) {
+#ifdef CONFIG_NFS_V2
+	case 2:
+		cl_init.rpc_ops = &nfs_v2_clientops;
+		break;
+#endif
 #ifdef CONFIG_NFS_V3
-	if (data->version == 3)
+	case 3:
 		cl_init.rpc_ops = &nfs_v3_clientops;
+		break;
 #endif
+	default:
+		return -EPROTONOSUPPORT;
+	}
 
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
-- 
1.7.10.1

