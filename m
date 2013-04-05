Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162690Ab3DEVQk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/3] NFSv4: Fix the fallback to AUTH_NULL if krb5i is not available
Date: Fri,  5 Apr 2013 17:16:34 -0400
Message-Id: <1365196596-25439-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365196596-25439-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196596-25439-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the rpcsec_gss_krb5 module cannot be loaded, the attempt to create
an rpc_client in nfs4_init_client will currently fail with an EINVAL.
Fix is to retry with AUTH_NULL.

Regression introduced by the commit "NFS: Use "krb5i" to establish NFSv4
state whenever possible"

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4client.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index bb9789e..a4f2100 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -200,6 +200,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
+	if (error == -EINVAL)
+		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_NULL);
 	if (error < 0)
 		goto error;
 
-- 
1.8.1.4

