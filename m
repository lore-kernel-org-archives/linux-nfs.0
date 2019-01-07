Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A13FC43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 21:32:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 728462087F
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 21:32:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726934AbfAGVcS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 16:32:18 -0500
Received: from fieldses.org ([173.255.197.46]:44914 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726535AbfAGVcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Jan 2019 16:32:18 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 433BC3F4; Mon,  7 Jan 2019 16:32:18 -0500 (EST)
Date:   Mon, 7 Jan 2019 16:32:18 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190107213218.GD7753@fieldses.org>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
 <20190103224529.GA6907@fieldses.org>
 <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
 <20190104173912.GC11787@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190104173912.GC11787@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 04, 2019 at 12:39:12PM -0500, bfields@fieldses.org wrote:
> I wonder if there's a race here independent of that change:
> 
> svc_xprt_enqueue() callers all do something like:
> 
> 	1. change some condition
> 	2. call svc_xprt_enqueue() to check whether the xprt should 
> 	   now be enqueued.
> 
> where the conditions are settings of the xpt_flags, or socket wspace, or
> xpt_nr_rqsts.
> 
> In theory if we miss some concurrent change we're OK because whoever's
> making that change will then also call svc_xprt_enqueue.  But that's not
> enough; e.g.:
> 
> 	task 1				task 2
> 	------				------
> 	set XPT_DATA
> 					atomic_dec(xpt_nr_rqsts)
> 
> 	check XPT_DATA && check xpt_nr_rqsts
> 
> 					check XPT_DATA && check xpt_nr_rqsts
> 
> If the tasks only see their local changes, then neither see both
> conditions true, so the socket doesn't get enqueued.  (And a request
> that was ready to be processed will sit around until someone else comes
> calls svc_xprt_enqueue() on that xprt.)

So maybe we actually need

 static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
+	mb();
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
 	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {

Then whichever memory barrier executes second guarantees that the
following check sees the result of both the XPT_DATA and xpt_nr_rqsts
changes.  I think....

--b.
