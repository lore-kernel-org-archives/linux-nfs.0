Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:63099 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbaBKOdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 09:33:33 -0500
Received: by mail-ig0-f178.google.com with SMTP id uq10so8863433igb.5
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 06:33:33 -0800 (PST)
Message-ID: <1392129211.5763.5.camel@leira.trondhjem.org>
Subject: Re: xprt_wait_for_buffer_space changes causes a hang.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Date: Tue, 11 Feb 2014 09:33:31 -0500
In-Reply-To: <20140210170315.33dfc621@notabene.brown>
References: <20140210170315.33dfc621@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-02-10 at 17:03 +1100, NeilBrown wrote:
> Hi,
>  We have a customer who reports occasional but reproducible hangs on our 3.0
>  based kernel.
>  I managed to deduce that 
> 
> commit a9a6b52ee1baa865283a91eb8d443ee91adfca56
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Feb 22 14:57:57 2013 -0500
> 
>     SUNRPC: Don't start the retransmission timer when out of socket space
>  
> was to blame (it got into our kernel through -stable ... not sure why it
> deserved to be in -stable). Reverting that patch fixes the problem.  However I
> don't fully understand why.
> 

The reason why that patch was put into stable was that the connection
breakage triggered by the timeouts was causing nasty behaviour when
servers (or the network) are heavily loaded. Instead of clearing the
logjam, breaking the connection and then reconnecting would aggravate
it, causing hangs.

Anyhow, does the following patch help to break the race?
8<------------------------------------------------------------------
>From e4c0373be4b8deae2667a7478d34415b99924abc Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Tue, 11 Feb 2014 09:15:54 -0500
Subject: [PATCH] SUNRPC: Fix races in xs_nospace()

When a send failure occurs due to the socket being out of buffer space,
we call xs_nospace() in order to have the RPC task wait until the
socket has drained enough to make it worth while trying again.
The current patch fixes a race in which the socket is drained before
we get round to setting up the machinery in xs_nospace(), and which
is reported to cause hangs.

Link: http://lkml.kernel.org/r/20140210170315.33dfc621@notabene.brown
Fixes: a9a6b52ee1ba (SUNRPC: Don't start the retransmission timer...)
Reported-by: Neil Brown <neilb@suse.com>
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6497c221612c..966763d735e9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -510,6 +510,7 @@ static int xs_nospace(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct sock *sk = transport->inet;
 	int ret = -EAGAIN;
 
 	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
@@ -527,7 +528,7 @@ static int xs_nospace(struct rpc_task *task)
 			 * window size
 			 */
 			set_bit(SOCK_NOSPACE, &transport->sock->flags);
-			transport->inet->sk_write_pending++;
+			sk->sk_write_pending++;
 			/* ...and wait for more buffer space */
 			xprt_wait_for_buffer_space(task, xs_nospace_callback);
 		}
@@ -537,6 +538,9 @@ static int xs_nospace(struct rpc_task *task)
 	}
 
 	spin_unlock_bh(&xprt->transport_lock);
+
+	/* Race breaker in case memory is freed before above code is called */
+	sk->sk_write_space(sk);
 	return ret;
 }
 
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


