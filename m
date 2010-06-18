From: Chris Vine <chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org>
Subject: Re: [PATCH] nfsd: just keep single lockd reference for nfsd
Date: Fri, 18 Jun 2010 16:04:11 +0100
Message-ID: <20100618160411.14d65b2b@boulder.homenet>
References: <1276858940-15499-1-git-send-email-jlayton@redhat.com>
	<20100618151808.6e40a0ca@boulder.homenet>
	<20100618103042.080aa597@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp5.freeserve.com ([193.252.22.128]:5525 "EHLO
	smtp5.freeserve.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933607Ab0FRPEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 11:04:07 -0400
In-Reply-To: <20100618103042.080aa597-4QP7MXygkU+dMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jun 2010 10:30:42 -0400
Jeff Layton <jlayton@redhat.com> wrote:
[snip]
> Thanks for testing them. No oops == improvement!
> 
> ...but it would still be good to know what's wrong here. It sounds
> like something is really odd with loopback communications on this
> box. Is the ipv4 loopback interface up at this time? Do you have any
> iptables stuff set up that might be filtering out portmap
> registration requests from the kernel? What happens if you run
> "rpcinfo"? Does it also hang?
> 
> The kernel uses TCP for talking to portmap these days, so it might
> also be good to see whether you can use rpcinfo to talk to it with
> TCP too...

You are right. Although the lo interface is up, localhost is broken in
2.6.35-rc3. External networking works OK which is why I hadn't noticed.

It looks like some other unrelated bug in 2.6.35 is at work. Quite why
it doesn't strike my Pentium machine I can't say.  The netbook takes its
network address from DHCP (my Pentium does not) but that shouldn't make
any difference to localhost.

I shall do a bit more looking around later today or tomorrow.

Chris


