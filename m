Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44436 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030329AbbKEIhg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 03:37:36 -0500
Date: Thu, 5 Nov 2015 11:37:08 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Doug Ledford <dledford@redhat.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch 1/2] xprtrdma: clean up some curly braces
Message-ID: <20151105083708.GA19405@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It doesn't matter either way, but the curly braces were clearly intended
here.  It causes a Smatch warning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index eadd1655..2cc1014 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -852,10 +852,11 @@ retry:
 
 		if (extras) {
 			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
-			if (rc)
+			if (rc) {
 				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
 					__func__, rc);
 				rc = 0;
+			}
 		}
 	}
 
