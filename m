From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 06/67] nfs41: Use mount minorversion option
Date: Thu,  2 Apr 2009 16:51:15 +0300
Message-ID: <1238680275-13588-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30449 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754939AbZDBNvX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:23 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the mount minorversion option to initialize the nfs_client cl_minorversion
and match it in nfs_match_client() when looking up a nfs_client.

[nfs41: remove ifdefs around nfs_client_initdata.minorversion]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 25ea8e4..3aabf1b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -102,6 +102,7 @@ struct nfs_client_initdata {
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
+	u32 minorversion;
 };
 
 /*
@@ -150,6 +151,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
 	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
@@ -420,7 +422,9 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
-
+		/* Match nfsv4 minorversion */
+		if (clp->cl_minorversion != data->minorversion)
+			continue;
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
@@ -1110,6 +1114,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.addrlen = addrlen,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
+		.minorversion = minorversion,
 	};
 	struct nfs_client *clp;
 	int error;
-- 
1.6.2.1

