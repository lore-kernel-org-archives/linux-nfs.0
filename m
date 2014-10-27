Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:40504 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbaJ0TAl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2014 15:00:41 -0400
Received: by mail-qa0-f50.google.com with SMTP id cs9so4219300qab.23
        for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2014 12:00:40 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 27 Oct 2014 15:00:37 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection
 when dropping a request
Message-ID: <20141027150037.65bd3080@tlielax.poochiereds.net>
In-Reply-To: <20141024130828.1304aa8f@tlielax.poochiereds.net>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	<1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
	<20141024072644.6643f9ed@tlielax.poochiereds.net>
	<20141024093459.70a29d80@tlielax.poochiereds.net>
	<1414161055.21776.2.camel@leira.trondhjem.org>
	<20141024105758.064f2e14@tlielax.poochiereds.net>
	<CAHQdGtTt23DBM3YH295T_eUvq6ymNere7OfDR9VNFyB3Xsfcsw@mail.gmail.com>
	<20141024130828.1304aa8f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Oct 2014 13:08:28 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> On Fri, 24 Oct 2014 18:59:47 +0300
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > On Fri, Oct 24, 2014 at 5:57 PM, Jeff Layton
> > <jeff.layton@primarydata.com> wrote:
> > >> @@ -1228,6 +1231,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> > >>   dropit:
> > >>       svc_authorise(rqstp);   /* doesn't hurt to call this twice */
> > >>       dprintk("svc: svc_process dropit\n");
> > >
> > > I don't think this will fix it either. I turned the above dprintk into
> > > a normal printk and it never fired during the test. As best I can tell,
> > > svc_process_common is not returning 0 when this occurs.
> > 
> > OK. Is perhaps the "revisit canceled" triggering in svc_revisit()? I'm
> > having trouble understanding the call chain for that stuff, but it too
> > looks as if it can trigger some strange behaviour.
> > 
> 
> I don't think that's it either. I turned the dprintks in svc_revisit
> into a printks just to be sure, and they didn't fire either.
> 
> Basically, I don't think we ever do anything in svc_defer for v4.1
> requests, due to this at the top of it:
> 
>         if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
>                 return NULL; /* if more than a page, give up FIXME */
> 
> ...basically rq_usedeferral should be set in most cases for v4.1
> requests. It gets set when processing the compound and then unset
> afterward.
> 
> That said, I suppose you could end up deferring the request if it
> occurs before the pc_func gets called, but I haven't seen any evidence
> of that happening so far with this test.
> 
> I do concur with Christoph that I've only been able to reproduce this
> while running on the loopback interface. If I have server and client in
> different VMs, then this test runs just fine. Could this be related to
> the changes that Neil sent in recently to make loopback mounts work
> better?
> 
> One idea might be reasonable to backport 2aca5b869ace67 to something
> v3.17-ish and see whether it's still reproducible?
> 

Ok, I've made a bit more progress on this, mostly by adding a fair
number of tracepoints into the client and server request dispatching
code. I'll be posting patches to add those for eventually, but they
need a little cleanup first.

In any case, here's a typical request as it's supposed to work:

       mount.nfs-906   [002] ...1 22711.996969: xprt_transmit: xprt=0xffff8800ce961000 xid=0xa8a34513 status=0
            nfsd-678   [000] ...1 22711.997082: svc_recv: rq_xid=0xa8a34513 status=164
            nfsd-678   [000] ..s8 22711.997185: xprt_lookup_rqst: xprt=0xffff8800ce961000 xid=0xa8a34513 status=0
            nfsd-678   [000] ..s8 22711.997186: xprt_complete_rqst: xprt=0xffff8800ce961000 xid=0xa8a34513 status=140
            nfsd-678   [000] ...1 22711.997236: svc_send: rq_xid=0xa8a34513 dropme=0 status=144
            nfsd-678   [000] ...1 22711.997236: svc_process: rq_xid=0xa8a34513 dropme=0 status=144

...and here's what we see when things start hanging:

     kworker/2:2-107   [002] ...1 22741.696070: xprt_transmit: xprt=0xffff8800ce961000 xid=0xc3a84513 status=0
            nfsd-678   [002] .N.1 22741.696917: svc_recv: rq_xid=0xc3a84513 status=208
            nfsd-678   [002] ...1 22741.699890: svc_send: rq_xid=0xc3a84513 dropme=0 status=262252
            nfsd-678   [002] ...1 22741.699891: svc_process: rq_xid=0xc3a84513 dropme=0 status=262252

What's happening is that xprt_transmit is called to send the request
to the server. The server then gets it, and immediately processes it
(in less than a second) and sends the reply.

The problem is that at some point, we stop getting sk_data_ready
events on the socket, even when the server has clearly sent something
to the client. I'm unclear on why that is, but I suspect that something
is broken in the lower level socket code, possibly just in the loopback
code?

At this point, I think I'm pretty close to ready to call in the netdev
cavalry. I'll write up a synopsis of what we know so far, and send it
there (and cc it here) in the hopes that someone will have some insight.

-- 
Jeff Layton <jlayton@primarydata.com>
