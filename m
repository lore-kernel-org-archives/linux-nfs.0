Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162478Ab3DEVQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFSv4: Fix a memory leak in nfs4_discover_server_trunking
Date: Fri,  5 Apr 2013 17:16:27 -0400
Message-Id: <1365196588-25403-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we assign a new rpc_client to clp->cl_rpcclient, we need to destroy
the old one.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org [>=3.7]
---
 fs/nfs/nfs4state.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6ace365..d41a351 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1886,7 +1886,13 @@ again:
 			status = PTR_ERR(clnt);
 			break;
 		}
-		clp->cl_rpcclient = clnt;
+		/* Note: this is safe because we haven't yet marked the
+		 * client as ready, so we are the only user of
+		 * clp->cl_rpcclient
+		 */
+		clnt = xchg(&clp->cl_rpcclient, clnt);
+		rpc_shutdown_client(clnt);
+		clnt = clp->cl_rpcclient;
 		goto again;
 
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
-- 
1.8.1.4

