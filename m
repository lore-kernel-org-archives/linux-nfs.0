Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25302 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbcBEVIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:48 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 4/6] NFS session trunking support: add trunk xprt to nfs4.1 mount
Date: Fri, 5 Feb 2016 16:08:36 -0500
Message-ID: <1454706518-4641-5-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c        | 16 +++++++++++++++-
 net/sunrpc/xprtmultipath.c |  2 ++
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 5f20acf..6736805 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -412,8 +412,22 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	if (error < 0)
 		goto error;
 
-	if (clp != old)
+	if (clp != old) {
+		if (clp->cl_minorversion != 0) {
+			struct rpc_xprt *add = clp->cl_rpcclient->cl_xprt;
+			struct xprt_create xprt_args = {
+				.ident = XPRT_TRANSPORT_TCP,
+				.net = old->cl_net, /* clp->cl_net ??*/
+				.dstaddr = (struct sockaddr *)&add->addr,
+				.addrlen = add->addrlen,
+				.servername = clp->cl_hostname,
+			};
+			/* Add this address as an alias */
+			rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
+					rpc_clnt_test_and_add_xprt, NULL);
+		}
 		clp->cl_preserve_clid = true;
+	}
 	nfs_put_client(clp);
 	return old;
 
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 7be5bd2..f13419e 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -35,6 +35,8 @@ static void xprt_switch_add_xprt_locked(struct rpc_xprt_switch *xps,
 	if (xps->xps_nxprts == 0)
 		xps->xps_net = xprt->xprt_net;
 	xps->xps_nxprts++;
+	pr_info("RPC:  ADDED %s to xps %p xps_nxprts %d\n",
+		xprt->servername, xps, xps->xps_nxprts);
 }
 
 /**
-- 
1.8.3.1

