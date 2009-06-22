From: Simon Kirby <sim@hostway.ca>
Subject: Re: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Mon, 22 Jun 2009 14:11:26 -0700
Message-ID: <20090622211126.GA564@hostway.ca>
References: <20090619225437.GA8472@hostway.ca> <1245527855.5182.33.camel@heimdal.trondhjem.org> <20090621050941.GA17059@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:41507 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752714AbZFVVLY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 17:11:24 -0400
In-Reply-To: <20090621050941.GA17059@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 20, 2009 at 10:09:41PM -0700, Simon Kirby wrote:

> Actually, we just saw another similar crash on another machine which is
> an NFS client from this server (no nfsd running).  Same backtrace, but
> this time RAX was "32322e32352e3031", which is obviously ASCII
> ("22.25.01"), so memory scribbling seems to definitely be happening...

Good news: 2.6.30 seems to have fixed whatever the original scribbling
source was.  I see at least a couple of suspect commits in the log, but
I'm not sure which yet.

However, with 2.6.30, it seems 59a252ff8c0f2fa32c896f69d56ae33e641ce7ad
is causing us a large performance regression.  The server's response
latency is huge compared to normal.  I suspected this patch was the
culprit, so I wrote over the instruction that loads SVC_MAX_WAKING before
this comparison:

+	if (pool->sp_nwaking >= SVC_MAX_WAKING) {
+		/* too many threads are runnable and trying to wake up */
+		thread_avail = 0;
+	}

...when I raised SVC_MAX_WAKING to 40ish, the problem for us disappears. 

The problem is that with just 72 nfsd processes running, the NFS socket
has a ~1 MB backlog of packets on it, even though "ps" shows most of the
nfsd threads are not blocked.  This is on an 8 core system, with high NFS
packet rates.  More NFS threads (300) made no difference.

As soon as I raised SVC_MAX_WAKING, the load average went up again to
what it normally was before with 2.6.29, but the socket's receive backlog
went down to nearly 0 again, and the request latency is now back to
normal.

I think the issue here is that whatever calls svc_xprt_enqueue() isn't
doing it again as soon as the threads sleep again, but only when the next
packet comes in, or something...

Simon-
