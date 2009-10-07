From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] SUNRPC: Use soft connect semantics when performing RPC
	ping
Date: Wed, 07 Oct 2009 18:03:10 -0400
Message-ID: <20091007220310.1844.39266.stgit@matisse.1015granger.net>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52173
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754804AbZJGWDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:03:47 -0400
Received: from matisse.1015granger.net (matisse.1015granger.net [127.0.0.1])
	by matisse.1015granger.net (8.14.3/8.14.3) with ESMTP id n97M3AcH002025
	for <linux-nfs@vger.kernel.org>; Wed, 7 Oct 2009 18:03:10 -0400
In-Reply-To: <20091007215019.1844.17414.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if a remote RPC service is unreachable, an RPC ping will
hang until the underlying transport connect attempt times out.  A more
desirable behavior might be to have the ping fail immediately so upper
layers can recover appropriately.

In the case of an NFS mount, for instance, this would mean the
mount(2) system call could fail immediately if the server isn't
listening, rather than hanging uninterruptibly for more than 3
minutes.

With the new soft connect flag, we can get this behavior.  After
this patch, rpc_create() with TCP will fail immediately if an RPC ping
was requested and the server is not reachable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index dc75289..ba52326 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1703,7 +1703,7 @@ static int rpc_ping(struct rpc_clnt *clnt, int flags)
 	};
 	int err;
 	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	err = rpc_call_sync(clnt, &msg, flags);
+	err = rpc_call_sync(clnt, &msg, flags | RPC_TASK_SOFTCONN);
 	put_rpccred(msg.rpc_cred);
 	return err;
 }

