Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934Ab2HQWc4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 18:32:56 -0400
Date: Fri, 17 Aug 2012 18:32:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
Message-ID: <20120817223253.GA15659@fieldses.org>
References: <20120712125303.GC16822@fieldses.org>
 <502DA4E8.9050800@msgid.tls.msk.ru>
 <20120817145616.GC11172@fieldses.org>
 <20120817160057.GE11172@fieldses.org>
 <502E7B86.3060702@msgid.tls.msk.ru>
 <20120817171854.GA14015@fieldses.org>
 <502E7EC3.5030006@msgid.tls.msk.ru>
 <502E7F84.3060003@msgid.tls.msk.ru>
 <20120817191800.GA14620@fieldses.org>
 <20120817200807.GB14620@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120817200807.GB14620@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 17, 2012 at 04:08:07PM -0400, J. Bruce Fields wrote:
> Wait a minute, that assumption's a problem because that calculation
> depends in part on xpt_reserved, which is changed here....
> 
> In particular, svc_xprt_release() calls svc_reserve(rqstp, 0), which
> subtracts rqstp->rq_reserved and then calls svc_xprt_enqueue, now with a
> lower xpt_reserved value.  That could well explain this.

So, maybe something like this?

--b.

commit c8136c319ad85d0db870021fc3f9074d37f26d4a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 17 17:31:53 2012 -0400

    svcrpc: don't add to xpt_reserved till we receive
    
    The rpc server tries to ensure that there will be room to send a reply
    before it receives a request.
    
    It does this by tracking, in xpt_reserved, an upper bound on the total
    size of the replies that is has already committed to for the socket.
    
    Currently it is adding in the estimate for a new reply *before* it
    checks whether there is space available.  If it finds that there is not
    space, it then subtracts the estimate back out.
    
    This may lead the subsequent svc_xprt_enqueue to decide that there is
    space after all.
    
    The results is a svc_recv() that will repeatedly return -EAGAIN, causing
    server threads to loop without doing any actual work.
    
    Reported-by: Michael Tokarev <mjt@tls.msk.ru>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ec99849a..59ff3a3 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -366,8 +366,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 				rqstp, rqstp->rq_xprt);
 		rqstp->rq_xprt = xprt;
 		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		pool->sp_stats.threads_woken++;
 		wake_up(&rqstp->rq_wait);
 	} else {
@@ -644,8 +642,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (xprt) {
 		rqstp->rq_xprt = xprt;
 		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 
 		/* As there is a shortage of threads and this request
 		 * had to be queued, don't allow the thread to wait so
@@ -743,6 +739,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
+	if (len > 0) {
+		rqstp->rq_reserved = serv->sv_max_mesg;
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+	}
 	svc_xprt_received(xprt);
 
 	/* No data, incomplete (TCP) read, or accept() */
