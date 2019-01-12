Return-Path: <SRS0=Ki69=PU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D861C43387
	for <linux-nfs@archiver.kernel.org>; Sat, 12 Jan 2019 00:56:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E544220872
	for <linux-nfs@archiver.kernel.org>; Sat, 12 Jan 2019 00:56:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726387AbfALA4O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Jan 2019 19:56:14 -0500
Received: from fieldses.org ([173.255.197.46]:50462 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725915AbfALA4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Jan 2019 19:56:14 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id B9B091C5A; Fri, 11 Jan 2019 19:56:13 -0500 (EST)
Date:   Fri, 11 Jan 2019 19:56:13 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190112005613.GA29181@fieldses.org>
References: <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
 <20190108150107.GA15921@fieldses.org>
 <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
 <20190109165142.GB32189@fieldses.org>
 <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
 <20190111211235.GA27206@fieldses.org>
 <BB7240BE-3F20-43AD-B709-7F18CC33CC02@oracle.com>
 <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
 <20190111221030.GA28794@fieldses.org>
 <A33F8CE5-3E5D-4359-8061-8DB8214B012B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A33F8CE5-3E5D-4359-8061-8DB8214B012B@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 11, 2019 at 05:27:30PM -0500, Chuck Lever wrote:
> 
> 
> > On Jan 11, 2019, at 5:10 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, Jan 11, 2019 at 04:54:01PM -0500, Chuck Lever wrote:
> >>> On Jan 11, 2019, at 4:52 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>> So, I think we need your patch plus something like this.
> >>>> 
> >>>> Chuck, maybe you could help me with the "XXX: Chuck:" parts?
> >>> 
> >>> I haven't been following. Why do you think those are necessary?
> > 
> > I'm worried something like this could happen:
> > 
> > 	CPU 1				CPU 2
> > 	-----				-----
> > 
> > 	set XPT_DATA			dec xpt_nr_rqsts
> > 
> > 	svc_xprt_enqueue		svc_xprt_enqueue
> > 
> > And both decide nothing should be done if neither sees the change that
> > the other made.
> > 
> > Maybe I'm still missing some reason that couldn't happen.
> > 
> > Even if it can happen, it's an unlikely race that will likely be fixed
> > when another event comes along a little later, which would explain why
> > we've never seen any reports.
> > 
> >>> We've had set_bit and atomic_{inc,dec} in this code for ages,
> >>> and I've never noticed a problem.
> >>> 
> >>> Rather than adding another CPU pipeline bubble in the RDMA code,
> >>> though, could you simply move the set_bit() call site inside the
> >>> critical sections?
> >> 
> >> er, inside the preceding critical section. Just reverse the order
> >> of the spin_unlock and the set_bit.
> > 
> > That'd do it, thanks!
> 
> I can try that here and see if it results in a performance regression.

Thanks, I've got a version with a typo fixed at

	git://linux-nfs.org/~bfields/linux.git nfsd-next

--b.
