Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:9609 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877Ab3DNPyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Apr 2013 11:54:00 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1: Set the RPC_CLNT_CREATE_INFINITE_SLOTS flag for NFSv4.1 transports
Date: Sun, 14 Apr 2013 11:53:55 -0400
Message-Id: <1365954835-35301-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365954835-35301-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1365954835-35301-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365954835-35301-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This ensures that the RPC layer doesn't override the NFS session
negotiation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           | 2 ++
 fs/nfs/nfs4client.c       | 2 ++
 include/linux/nfs_fs_sb.h | 1 +
 3 files changed, 5 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 84d8eae..c513b0c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -593,6 +593,8 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
 	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+	if (test_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags))
+		args.flags |= RPC_CLNT_CREATE_INFINITE_SLOTS;
 
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a4f2100..9b711e4 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -199,6 +199,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	clp->rpc_ops = &nfs_v4_clientops;
 
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
+	if (clp->cl_minorversion != 0)
+		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_NULL);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d8fdfdc..01b3815 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -40,6 +40,7 @@ struct nfs_client {
 #define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
+#define NFS_CS_INFINITE_SLOTS	3		/* - transparent state migr */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-- 
1.8.1.4

