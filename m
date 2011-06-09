Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60403 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab1FIGie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 02:38:34 -0400
Date: Thu, 9 Jun 2011 16:38:23 +1000
From: NeilBrown <neilb@suse.de>
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Message-ID: <20110609163823.689d6601@notabene.brown>
In-Reply-To: <4DF06430.1040608@candelatech.com>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
	<20110609154719.5be627ca@notabene.brown>
	<4DF06430.1040608@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 08 Jun 2011 23:12:00 -0700 Ben Greear <greearb@candelatech.com> wrote:

> On 06/08/2011 10:47 PM, NeilBrown wrote:
> > On Wed,  8 Jun 2011 10:39:08 -0700 greearb@candelatech.com wrote:
> >
> >> From: Ben Greear<greearb@candelatech.com>
> >>
> >> This lets one specify the source IP address for
> >> sockets, allowing users to leverage routing rules
> >> on multi-homed systems.
> >>
> >
> > I gotta say I think this is rather horrible.....
> 
> And you haven't even seen the kernel side yet ;)
> 
> > As I understand it, the problem is bindresvport.
> > It binds to a port number before making a connection, so the local address
> > that is bound to is the 'default' rather than the best one to reach the given
> > target.  And in some network configs this can be bad, because e.g. the target
> > may not be able to reply to that 'default' address.
> >
> > So you want to be able to specify the local endpoint fully when you bind, so
> > you require/allow the user to specify the local endpoint.
> >
> > Wouldn't it be soooo much nicer if the tools could just figure out the
> > 'correct' local endpoint and just use that?  Obviously "yes" but maybe that
> > isn't straight forward.  Have you looked into that at all?
> 
> Not nicer in all cases.
> 
> Sometimes a user knows best, and may want to use non-obvious
> routing setups, such as rules that send pkts to different gateways
> if they are from different source addresses.

I cannot say that I am convinced.  Such rules sound like they are asking for
trouble and I'm not surprised when they get it.

> >
> > What think you?
> 
> I think I really do want to specify the local IP address.  There
> are lots of other tools that allow this (ping, ssh, cifs, etc),
> and there is a good reason for allowing it, primarily when used
> in conjunction with routing rules that are based on source
> IP.

ping is a debugging tool and clearly a special case.  ssh is a bit of a
special case too.  cifs less so.   But there are far more tools that don't
allow you to specify a local endpoint address and I feel we should be strongly
discouraging configurations which need them.

So while I'm still not convinced your solution is a good idea, I admit I am
somewhat less convinced that it is a bad idea and I won't try to road-block.
But if some day someone points to existing use in nfs-utils as a
justification for adding source-address setting in firefox, I think I might
just scream.

Thanks,
NeilBrown

