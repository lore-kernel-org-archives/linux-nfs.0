From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Tue, 16 Dec 2008 12:55:03 -0500
Message-ID: <20081216175503.GG16388@fieldses.org>
References: <1227596962.16868.22.camel@localhost.localdomain> <1227619696.7057.19.camel@heimdal.trondhjem.org> <1227620339.9425.99.camel@zakaz.uk.xensource.com> <1227621434.7057.33.camel@heimdal.trondhjem.org> <1227621877.9425.102.camel@zakaz.uk.xensource.com> <1227737539.31008.2.camel@localhost.localdomain> <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228169383.20370.3.camel@localhost.localdomain> <1228565812.10856.30.camel@localhost.localdomain> <1229279045.3721.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbYLPRzP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 12:55:15 -0500
In-Reply-To: <1229279045.3721.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 14, 2008 at 06:24:05PM +0000, Ian Campbell wrote:
> On Sat, 2008-12-06 at 12:16 +0000, Ian Campbell wrote:
> > On Mon, 2008-12-01 at 22:09 +0000, Ian Campbell wrote:
> > > On Sun, 2008-11-30 at 19:17 -0500, Trond Myklebust wrote: 
> > > > Can you see if the following 3 patches help? They're against 2.6.28-rc6,
> > > > but afaics the problems are pretty much the same on 2.6.26.
> > > 
> > > Thanks.
> > > 
> > > The server was actually running 2.6.25.7 but the matching sources have
> > > since been removed the backports.org so I've reproduce with 2.6.26 and
> > > now I'll add the patches.
> > 
> > Just a small progress report. Anecdotally I thought that unpatched
> > 2.6.26.7 was worse than 2.6.25.7, mostly because it hung twice in the ~1
> > day I was running it where previously it was less frequent than once per
> > day.
> > 
> > With the patched server the client ran OK for 2.5 days then mysteriously
> > hung, the logs show none of the normal symptoms and my wife reset it
> > before I got home so I've no real clue what happened but I'm inclined to
> > think it was unrelated for now. I'll get back to you in a week or so if
> > the problem hasn't reoccurred.
> 
> $ uptime 
>  18:15:29 up 9 days, 22 min,  1 user,  load average: 0.74, 0.64, 0.46
> 
> This is on the problematic client, so it looks like the server side fix
> has sorted it. Thanks very much Trond.

Thanks for the testing!  So this was with the following three patches
applied on the server on top of 2.6.26?

	[PATCH 1/3] SUNRPC: Ensure the server closes sockets in a timely fashion
	[PATCH 2/3] SUNRPC: We only need to call svc_delete_xprt() once...
	[PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to enqueue 'XPT_DEAD' transports

I'll try to take a look at these before I leave for the holidays,
assuming the versions Trond posted on Nov. 30 are the latest.

--b.
