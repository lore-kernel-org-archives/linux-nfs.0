From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/46] nfs41: Use mount minorversion option
Date: Wed,  4 Mar 2009 01:52:42 +0200
Message-ID: <1236124362-3141-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17400
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752718AbZCCXwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:52:54 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the mount minorversion option to initialize the nfs_client cl_minorversion
and match it in nfs_match_client() when looking up a nfs_client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2555e48..e9f002f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -101,6 +101,9 @@ struct nfs_client_initdata {
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
+#ifdef CONFIG_NFS_V4
+	u32 minorversion;
+#endif
 };
 
 /*
@@ -149,6 +152,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
 	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
@@ -356,7 +360,11 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
-
+#ifdef CONFIG_NFS_V4
+		/* Match minorversion */
+		if (clp->cl_minorversion != data->minorversion)
+			continue;
+#endif
 		/* Match the full socket address */
 		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
 			continue;
@@ -1045,6 +1053,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.addrlen = addrlen,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
+		.minorversion = minorversion,
 	};
 	struct nfs_client *clp;
 	int error;
-- 
1.6.1.3

