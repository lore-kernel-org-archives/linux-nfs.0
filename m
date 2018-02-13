Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38722 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933793AbeBMQPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 11:15:55 -0500
Date: Tue, 13 Feb 2018 11:15:41 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Cc: trondmy@primarydata.com, luxy.fnst@cn.fujitsu.com,
        linux-nfs@vger.kernel.org
Subject: Re: Questions about pynfs:testLargeData-WRT5
Message-ID: <20180213161540.GA26270@parsley.fieldses.org>
References: <20180209183112.GC30030@parsley.fieldses.org>
 <6c3159af-17c5-5556-d416-574968bb5e14@cn.fujitsu.com>
 <738139ab-6a55-4c93-008d-56a2332774c9@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <738139ab-6a55-4c93-008d-56a2332774c9@jp.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 13, 2018 at 12:19:58PM +0900, Seiichi Ikarashi wrote:
> 
> On Fri, 9 Feb 2018 13:31:12 -0500, J. Bruce Fields wrote:
> 
> >> For NFSv4, you would have the option of returning NFS4ERR_RESOURCE or
> >> possibly NFS4ERR_INVAL (personally, I'd prefer the latter, since
> >> NFS4ERR_RESOURCE is too wooly).
> >>
> >> For NFSv4.1 or above, you probably have a choice of NFS4ERR_REQ_TOO_BIG
> >> (if the size is greater than ca_maxrequestsize) or NFS4ERR_INVAL.
> > 
> > I think this sort of problem is typically found early in the rpc code
> > (probably the check against sv_max_mesg in
> > net/sunrpc/svcsock.c:svc_tcp_recv_record()).  It drops the connection.
> > I'm not sure why.
> 
> It looks implemented long time ago.
> 
> [PATCH] PATCH 11/16: NFSD: TCP: close bad connections
> https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git/commit/?id=84e9f22a623a

Thanks for tracking that down!

If the length is just ridiculous then closing is our best option, but if
it's within a few megabytes (as might happen if the maximum size changes
over reboot), then I think it might still be reasonable to receive the
whole thing, throw away the data, and return an error.

But, I'm not sure whether it's really an improvement.  The spec's
unlikely to provide much guidance, so it'd probably be a question of
figuring out what the likely client behavior is.

So, if somebody wanted to make a case for it I'd look at patches, but I
think it's not a priority.

WRT5 is wrong in any case, I'll fix it.

--b.
