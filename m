Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643Ab3IZVpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/7] NFSv4: Ensure that we disable the resend timeout for NFSv4
Date: Thu, 26 Sep 2013 17:45:05 -0400
Message-ID: <1380231907-13733-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-6-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec states that the client should not resend requests because
the server will disconnect if it needs to drop an RPC request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           | 2 ++
 fs/nfs/nfs4client.c       | 1 +
 include/linux/nfs_fs_sb.h | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2dceee4..af03258 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -590,6 +590,8 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 
 	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
+	if (test_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags))
+		args.flags |= RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT;
 	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	if (test_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags))
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a860ab5..511cdce 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -368,6 +368,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	if (clp->cl_minorversion != 0)
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
+	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b8cedce..f9c0a6c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -41,6 +41,7 @@ struct nfs_client {
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
+#define NFS_CS_NO_RETRANS_TIMEOUT	4	/* - Disable retransmit timeouts */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-- 
1.8.3.1

