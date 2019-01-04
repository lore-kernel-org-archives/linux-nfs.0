Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F560C43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 17:39:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C336218DE
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 17:39:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726135AbfADRjN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Jan 2019 12:39:13 -0500
Received: from fieldses.org ([173.255.197.46]:40656 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725958AbfADRjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Jan 2019 12:39:13 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id DF38C2013; Fri,  4 Jan 2019 12:39:12 -0500 (EST)
Date:   Fri, 4 Jan 2019 12:39:12 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190104173912.GC11787@fieldses.org>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
 <20190103224529.GA6907@fieldses.org>
 <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jan 03, 2019 at 11:40:21PM +0000, Trond Myklebust wrote:
> On Thu, 2019-01-03 at 17:45 -0500, J Bruce Fields wrote:
> > On Thu, Jan 03, 2019 at 09:17:12AM -0500, Trond Myklebust wrote:
> > > Use READ_ONCE() to tell the compiler to not optimse away the read
> > > of
> > > xprt->xpt_flags in svc_xprt_release_slot().
> > 
> > What exactly is the possible race here?  And why is a READ_ONCE()
> > sufficient, as opposed to some memory barriers?
> > 
> > I may need to shut myself in a room with memory-barriers.txt, I'm
> > pretty
> > hazy on these things.
> > 
> 
> It's not about fixing any races. It is about ensuring that the compiler
> does not optimise away the read if the function is ever called from
> inside a loop. Not an important fix, since I'm not aware of any cases
> where this has happened. However strictly speaking, we should use
> READ_ONCE() here because that variable is volatile; it can be changed
> by a background action.

I wonder if there's a race here independent of that change:

svc_xprt_enqueue() callers all do something like:

	1. change some condition
	2. call svc_xprt_enqueue() to check whether the xprt should 
	   now be enqueued.

where the conditions are settings of the xpt_flags, or socket wspace, or
xpt_nr_rqsts.

In theory if we miss some concurrent change we're OK because whoever's
making that change will then also call svc_xprt_enqueue.  But that's not
enough; e.g.:

	task 1				task 2
	------				------
	set XPT_DATA
					atomic_dec(xpt_nr_rqsts)

	check XPT_DATA && check xpt_nr_rqsts

					check XPT_DATA && check xpt_nr_rqsts

If the tasks only see their local changes, then neither see both
conditions true, so the socket doesn't get enqueued.  (And a request
that was ready to be processed will sit around until someone else comes
calls svc_xprt_enqueue() on that xprt.)

The code's more complicated than that and maybe there's some reason that
can't happen.

--b.
