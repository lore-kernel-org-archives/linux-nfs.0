Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:60283 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894AbaJXRIb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 13:08:31 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so1226816qaq.24
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 10:08:30 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 24 Oct 2014 13:08:28 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection
 when dropping a request
Message-ID: <20141024130828.1304aa8f@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtTt23DBM3YH295T_eUvq6ymNere7OfDR9VNFyB3Xsfcsw@mail.gmail.com>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	<1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
	<20141024072644.6643f9ed@tlielax.poochiereds.net>
	<20141024093459.70a29d80@tlielax.poochiereds.net>
	<1414161055.21776.2.camel@leira.trondhjem.org>
	<20141024105758.064f2e14@tlielax.poochiereds.net>
	<CAHQdGtTt23DBM3YH295T_eUvq6ymNere7OfDR9VNFyB3Xsfcsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Oct 2014 18:59:47 +0300
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Oct 24, 2014 at 5:57 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> >> @@ -1228,6 +1231,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> >>   dropit:
> >>       svc_authorise(rqstp);   /* doesn't hurt to call this twice */
> >>       dprintk("svc: svc_process dropit\n");
> >
> > I don't think this will fix it either. I turned the above dprintk into
> > a normal printk and it never fired during the test. As best I can tell,
> > svc_process_common is not returning 0 when this occurs.
> 
> OK. Is perhaps the "revisit canceled" triggering in svc_revisit()? I'm
> having trouble understanding the call chain for that stuff, but it too
> looks as if it can trigger some strange behaviour.
> 

I don't think that's it either. I turned the dprintks in svc_revisit
into a printks just to be sure, and they didn't fire either.

Basically, I don't think we ever do anything in svc_defer for v4.1
requests, due to this at the top of it:

        if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
                return NULL; /* if more than a page, give up FIXME */

...basically rq_usedeferral should be set in most cases for v4.1
requests. It gets set when processing the compound and then unset
afterward.

That said, I suppose you could end up deferring the request if it
occurs before the pc_func gets called, but I haven't seen any evidence
of that happening so far with this test.

I do concur with Christoph that I've only been able to reproduce this
while running on the loopback interface. If I have server and client in
different VMs, then this test runs just fine. Could this be related to
the changes that Neil sent in recently to make loopback mounts work
better?

One idea might be reasonable to backport 2aca5b869ace67 to something
v3.17-ish and see whether it's still reproducible?

-- 
Jeff Layton <jlayton@primarydata.com>
