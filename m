From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 11/12] nfsd41:  modify nfsd4.1 backchannel to use new xprt class
Date: Thu, 10 Sep 2009 12:27:21 +0300
Message-ID: <1252574841-30383-1-git-send-email-bhalevy@panasas.com>
References: <4AA8C597.8080809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:20118 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755270AbZIJJ0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:26:52 -0400
In-Reply-To: <4AA8C597.8080809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Alexandros Batsakis <batsakis@netapp.com>

This patch enables the use of the nfsv4.1 backchannel.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
[initialize rpc_create_args.bc_xprt too]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 30dc375..236e7ee 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -48,6 +48,7 @@
 #include <linux/nfsd/state.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs4.h>
+#include <linux/sunrpc/xprtsock.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -483,7 +484,7 @@ int setup_callback_client(struct nfs4_client *clp)
 		.to_retries	= 0,
 	};
 	struct rpc_create_args args = {
-		.protocol	= IPPROTO_TCP,
+		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *) &cb->cb_addr,
 		.addrsize	= cb->cb_addrlen,
 		.timeout	= &timeparms,
@@ -499,6 +500,11 @@ int setup_callback_client(struct nfs4_client *clp)
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
 
+	if (cb->cb_minorversion) {
+		args.bc_xprt = clp->cl_cb_xprt;
+		args.protocol = XPRT_TRANSPORT_BC_TCP;
+	}
+
 	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
 		__func__, args.program->name, args.prognumber,
 		args.program->nrvers, args.version, cb->cb_minorversion);
-- 
1.6.4

