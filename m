Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33061 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752564AbcHVS7T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2016 14:59:19 -0400
Subject: [PATCH v2 1/6] SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is in
 use
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Aug 2016 14:57:42 -0400
Message-ID: <20160822185742.12076.34446.stgit@klimt.1015granger.net>
In-Reply-To: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
References: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using NFSv4.1 on RDMA should be safe, so broaden the new checks in
rpc_create().

WARN_ON_ONCE is used, matching most other WARN call sites in clnt.c.

Fixes: 39a9beab5acb ("rpc: share one xps between all backchannels")
Fixes: d50039ea5ee6 ("nfsd4/rpc: move backchannel create logic...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7f79fb7..66f23b3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -453,7 +453,7 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 	struct rpc_xprt_switch *xps;
 
 	if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
-		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
+		WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
 		xps = args->bc_xprt->xpt_bc_xps;
 		xprt_switch_get(xps);
 	} else {
@@ -520,7 +520,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	char servername[48];
 
 	if (args->bc_xprt) {
-		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
+		WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
 		xprt = args->bc_xprt->xpt_bc_xprt;
 		if (xprt) {
 			xprt_get(xprt);

