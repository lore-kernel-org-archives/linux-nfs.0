From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 22/46] nfs41: sunrpc: use private void pointer in rpc_clnt
Date: Wed,  4 Mar 2009 01:55:53 +0200
Message-ID: <1236124553-3593-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17648
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753902AbZCCX5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:57:31 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the rpc_clnt->cl_private to back point to the struct nfs_client
and use the nfs_client->cl_minorveraion to perform NFSv4.0 vrs NFSv4.1
encoding.

[was nfs41: sunrpc: add private void pointer to rpc_clnt]
    During the review, we thought this could be a struct nfs_server pointer. But
    that makes no sense given that all struct nfs_server's share a struct
    nfs_client->cl_rpcclient.

    NFS uses this as a backpointer to struct nfs_client, and will use the
    cl_minorversion.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c1536d9..ace6e91 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -541,6 +541,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	}
 
 	clp->cl_rpcclient = clnt;
+	clnt->cl_private = clp;
 	return 0;
 }
 
-- 
1.6.1.3

