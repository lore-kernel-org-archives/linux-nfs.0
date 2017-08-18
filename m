Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55434 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750729AbdHRHOF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:14:05 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:52 +1000
Subject: [PATCH 5/8] SUNRPC: remove some dead code.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037198.30218.6645228572942182998.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC_TASK_NO_RETRANS_TIMEOUT is set when cl_noretranstimeo
is set, which happens when  RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT is set,
which happens when NFS_CS_NO_RETRANS_TIMEOUT is set.

This flag means "don't resend on a timeout, only resend if the
connection gets broken for some reason".

cl_discrtry is set when RPC_CLNT_CREATE_DISCRTRY is set, which
happens when NFS_CS_DISCRTRY is set.

This flag means "always disconnect before resending".

NFS_CS_NO_RETRANS_TIMEOUT and NFS_CS_DISCRTRY are both only set
in nfs4_init_client(), and it always sets both.

So we will never have a situation where only one of the flags is set.
So this code, which tests if timeout retransmits are allowed, and
disconnection is required, will never run.

So it makes sense to remove this code as it cannot be tested and
could confuse people reading the code (like me).

(alternately we could leave it there with a comment saying
 it is never actually used).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 net/sunrpc/clnt.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 69a9e5953744..2ad827db2704 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2147,10 +2147,6 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
-		if (!(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT)
-		    && task->tk_client->cl_discrtry)
-			xprt_conditional_disconnect(req->rq_xprt,
-					req->rq_connect_cookie);
 		break;
 	case -ECONNREFUSED:
 	case -ECONNRESET:


