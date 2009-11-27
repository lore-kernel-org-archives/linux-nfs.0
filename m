From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Fri, 27 Nov 2009 16:23:56 -0500
Message-ID: <1259357036.3486.38.camel@localhost>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
	 <1259248859.6715.50.camel@localhost>
	 <64b4daae0911261607m10d1ba3al8c067f85249c198f@mail.gmail.com>
	 <64b4daae0911261614l471fb74fx79db2988f0c65738@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48289 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbZK0VYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Nov 2009 16:24:00 -0500
In-Reply-To: <64b4daae0911261614l471fb74fx79db2988f0c65738-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-11-27 at 01:14 +0100, Stephen R. van den Berg wrote: 
> On Fri, Nov 27, 2009 at 01:07, Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org> wrote:
> > RPC:       worker connecting xprt cfa94400 to address: addr=1.2.3.151
> > port=2049 proto=tcp
> > RPC:       cfa94400 connect status 99 connected 0 sock state 7
> 
> errno 99 means EADDRNOTAVAIL.  In userspace this normally is solved by
> using the REUSEADDR sockopt.  In xprtsock.c we try something like:
> 
>                 /* We're probably in TIME_WAIT. Get rid of existing socket,
>                  * and retry
>                  */
>                 set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
>                 xprt_force_disconnect(xprt);
> 
> I'd guess that this needs to be fixed, or the REUSEADDR sockopt needs to be set.

Does the following patch fix matters?

Trond

--------------------------------------------------------------------------------------------------------- 
SUNRPC: Ensure that we honour autoclose before attempting to reconnect

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If the XPRT_CLOSE_WAIT flag is set, we need to ensure that we call
xprt->ops->close() while holding xprt_lock_write() before we can
start reconnecting.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index fd46d42..469de29 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -700,6 +700,10 @@ void xprt_connect(struct rpc_task *task)
 	}
 	if (!xprt_lock_write(xprt, task))
 		return;
+
+	if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state))
+		xprt->ops->close(xprt);
+
 	if (xprt_connected(xprt))
 		xprt_release_write(xprt, task);
 	else {


