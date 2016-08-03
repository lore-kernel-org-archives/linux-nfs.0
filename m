Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36663 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbcHCP2B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2016 11:28:01 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: WARN_ON added to rpc_create()
Date: Wed, 3 Aug 2016 11:27:47 -0400
Message-Id: <42D0C152-58F9-4467-B86D-2A7A25544CE4@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I see that commit 39a9beab5acb83176e8b9a4f0778749a09341f1f
Author:     J. Bruce Fields <bfields@redhat.com>
AuthorDate: Tue May 17 12:38:21 2016 -0400

    rpc: share one xps between all backchannels

has added this piece of code:

@@ -452,10 +452,20 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
        struct rpc_clnt *clnt = NULL;
        struct rpc_xprt_switch *xps;
 
-       xps = xprt_switch_alloc(xprt, GFP_KERNEL);
-       if (xps == NULL) {
-               xprt_put(xprt);
-               return ERR_PTR(-ENOMEM);
+       if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
+               WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
+               xps = args->bc_xprt->xpt_bc_xps;
+               xprt_switch_get(xps);
+       } else {


the WARN_ON here fires on the server whenever I use NFSv4.1 on RDMA.

Can you say why it was added? Is there something RPC/RDMA needs to
do to make the code safe?


--
Chuck Lever



