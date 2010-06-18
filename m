From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfsd: just keep single lockd reference for nfsd
Date: Fri, 18 Jun 2010 11:11:32 -0400
Message-ID: <20100618111132.20fb518a@corrin.poochiereds.net>
References: <1276858940-15499-1-git-send-email-jlayton@redhat.com>
	<20100618151808.6e40a0ca@boulder.homenet>
	<20100618103042.080aa597@corrin.poochiereds.net>
	<20100618160411.14d65b2b@boulder.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chris Vine <chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932443Ab0FRPJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 11:09:36 -0400
In-Reply-To: <20100618160411.14d65b2b-PlFwYbz7hoIyinQH9hAyzg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jun 2010 16:04:11 +0100
Chris Vine <chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org> wrote:

> On Fri, 18 Jun 2010 10:30:42 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> [snip]
> > Thanks for testing them. No oops == improvement!
> > 
> > ...but it would still be good to know what's wrong here. It sounds
> > like something is really odd with loopback communications on this
> > box. Is the ipv4 loopback interface up at this time? Do you have any
> > iptables stuff set up that might be filtering out portmap
> > registration requests from the kernel? What happens if you run
> > "rpcinfo"? Does it also hang?
> > 
> > The kernel uses TCP for talking to portmap these days, so it might
> > also be good to see whether you can use rpcinfo to talk to it with
> > TCP too...
> 
> You are right. Although the lo interface is up, localhost is broken in
> 2.6.35-rc3. External networking works OK which is why I hadn't noticed.
> 
> It looks like some other unrelated bug in 2.6.35 is at work. Quite why
> it doesn't strike my Pentium machine I can't say.  The netbook takes its
> network address from DHCP (my Pentium does not) but that shouldn't make
> any difference to localhost.
> 
> I shall do a bit more looking around later today or tomorrow.
> 
> Chris
> 
> 

Ok, good to know. I'll still plan to pursue these fixes. The error
handling in nfsd obviously an area that needs improvement. I think
Bruce's current plan is to take the earlier patches in that stack for
2.6.36. If this one is OK, it's probably reasonable to go in at the
same time.

-- 
Jeff Layton <jlayton@redhat.com>
