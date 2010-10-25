Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36241 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891Ab0JYOg6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 10:36:58 -0400
Date: Mon, 25 Oct 2010 10:36:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: "xprt" reference count drops to 0
Message-ID: <20101025143656.GA3233@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
 <4CAAE046.5060209@bull.net>
 <20101021203801.GA12038@fieldses.org>
 <4CC1A722.4060907@bull.net>
 <20101022212007.GB22837@fieldses.org>
 <4CC5706F.3020308@bull.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CC5706F.3020308@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 25, 2010 at 01:56:31PM +0200, Menyhart Zoltan wrote:
> We do not really use more advanced kernel than the 2.6.32 in a great number.
> Just some test configurations up to the 2.6.36-rc6...
> I have not seen this problem on recent kernels.
> 
> I'm not sure that I can really follow your explication.

Look at the callers of svc_xprt_put().  You'll see that all of them have
an obvious paired svc_xprt_get():

	- Any svc_xprt_put() that clears a rqstp->rq_xprt is paired with
	  the svc_xprt_get() that originally set rqstp->rq_xprt
	- The svc_xprt_put() in svc_check_conn_limits() is paired with
	  the immediately preceding svc_xprt_get() that took the xprt
	  off the sv_tempsocks list.
	- Etc.

*Except* for the svc_xprt_put() at the end of svc_delete_xprt().  That
one you can think of as paired with the initial reference created by the
kref_init() in svc_xprt_init().

So, each xprt has one special reference which keeps the xprt from being
removed before svc_delete_xprt() is called.

There are only two callers of svc_delete_xprt(): svc_close_xprt(), and
svc_recv().

When we exit svc_xprt_enqueue(), we exit with XPT_BUSY set on the xprt
in question.

That flag will be cleared only by the svc_recv() call that picks up this
xprt (or by svc_close_all() if nfsd shuts down before then).

That prevents svc_close_xprt() from deleting the xprt, since it returns
without doing anything if XPT_BUSY is already set.

So the only code that could normally delete this xprt is the svc_recv()
that processes the xprt.  It takes the xprt off the pool->sp_sockets
list before it does that.

So, returning from svc_xprt_enqueue() with an xprt on ->sp_sockets that
has XPT_BUSY set is safe.

Think of XPT_BUSY as a kind of lock, ownership of which can pass from
the svc_xprt_enqueue() that queues up an xprt to the svc_recv() that
processes it, and note that an xprt can only be deleted under this
XPT_BUSY lock.

--b.
