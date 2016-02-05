Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25302 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbcBEVIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:47 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 2/6] SUNRPC fix rpc_clnt_xprt_iter_init infinite loop
Date: Fri, 5 Feb 2016 16:08:34 -0500
Message-ID: <1454706518-4641-3-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

xprt_iter_get_next() will restart at top of list and never stop.
Only process xps_nxprts xprts.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c0469d1..a56a44c8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -740,6 +740,7 @@ static
 int rpc_clnt_xprt_iter_init(struct rpc_clnt *clnt, struct rpc_xprt_iter *xpi)
 {
 	struct rpc_xprt_switch *xps;
+	int nxprt;
 
 	rcu_read_lock();
 	xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
@@ -747,8 +748,9 @@ int rpc_clnt_xprt_iter_init(struct rpc_clnt *clnt, struct rpc_xprt_iter *xpi)
 	if (xps == NULL)
 		return -EAGAIN;
 	xprt_iter_init_listall(xpi, xps);
+	nxprt = xps->xps_nxprts;
 	xprt_switch_put(xps);
-	return 0;
+	return nxprt;
 }
 
 /**
@@ -767,10 +769,11 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 		void *data)
 {
 	struct rpc_xprt_iter xpi;
-	int ret;
+	int ret = 0, nxprts, i;
 
-	ret = rpc_clnt_xprt_iter_init(clnt, &xpi);
-	for (;;) {
+	nxprts = rpc_clnt_xprt_iter_init(clnt, &xpi);
+	dprintk("RPC:   processing nxprts %d\n", nxprts);
+	for (i = 0; i < nxprts; i++) {
 		struct rpc_xprt *xprt = xprt_iter_get_next(&xpi);
 
 		if (!xprt)
-- 
1.8.3.1

