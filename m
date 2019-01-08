Return-Path: <SRS0=4uXo=PQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF5BDC43387
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 15:01:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A97D120827
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 15:01:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728439AbfAHPBJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jan 2019 10:01:09 -0500
Received: from fieldses.org ([173.255.197.46]:45824 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728159AbfAHPBI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Jan 2019 10:01:08 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C79593F4; Tue,  8 Jan 2019 10:01:07 -0500 (EST)
Date:   Tue, 8 Jan 2019 10:01:07 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190108150107.GA15921@fieldses.org>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
 <20190103224529.GA6907@fieldses.org>
 <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
 <20190104173912.GC11787@fieldses.org>
 <20190107213218.GD7753@fieldses.org>
 <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jan 07, 2019 at 10:06:19PM +0000, Trond Myklebust wrote:
> On Mon, 2019-01-07 at 16:32 -0500, bfields@fieldses.org wrote:
> > So maybe we actually need
> > 
> >  static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
> >  {
> > +	mb();
> 
> You would at best need a 'smp_rmb()'. There is nothing to gain from
> adding a write barrier here,

That's not my understanding.

What we have is basically:

	1			2
	----			----
	WRITE to A		WRITE to B

	READ from A and B	READ from A and B

and we want to guarantee that at least one of those two reads will see
both of the writes.

A read barrier only orders reads with respect to the barrier, it doesn't
do anything about writes, so doesn't guarantee anything here.

--b.



> and you don't even need a read barrier in
> the non-smp case.
> 
> >  	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
> >  		return true;
> >  	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
> > 
> > Then whichever memory barrier executes second guarantees that the
> > following check sees the result of both the XPT_DATA and xpt_nr_rqsts
> > changes.  I think....
> 
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 
