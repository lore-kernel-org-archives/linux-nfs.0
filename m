From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sunrpc/clnt.c: fix a NULL pointer dereference
Date: Sat, 11 Mar 2006 00:04:14 +0100
Message-ID: <20060310230414.GC21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752248AbWCJXEQ@vger.kernel.org>
To: neilb@cse.unsw.edu.au, trond.myklebust@fys.uio.no
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The Coverity checker spotted this possible NULL pointer dereference in 
rpc_new_client().


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm3-full/net/sunrpc/clnt.c.old	2006-03-10 23:39:20.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/net/sunrpc/clnt.c	2006-03-10 23:40:03.000000000 +0100
@@ -112,7 +112,7 @@ rpc_new_client(struct rpc_xprt *xprt, ch
 
 	err = -EINVAL;
 	if (!xprt)
-		goto out_err;
+		goto out_no_xprt;
 	if (vers >= program->nrvers || !(version = program->version[vers]))
 		goto out_err;
 
@@ -182,6 +182,7 @@ out_no_path:
 	kfree(clnt);
 out_err:
 	xprt_destroy(xprt);
+out_no_xprt:
 	return ERR_PTR(err);
 }
 
