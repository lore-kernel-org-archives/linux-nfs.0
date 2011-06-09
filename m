Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55506 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab1FIFrj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 01:47:39 -0400
Date: Thu, 9 Jun 2011 15:47:19 +1000
From: NeilBrown <neilb@suse.de>
To: greearb@candelatech.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Message-ID: <20110609154719.5be627ca@notabene.brown>
In-Reply-To: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed,  8 Jun 2011 10:39:08 -0700 greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.
> 

I gotta say I think this is rather horrible.....

As I understand it, the problem is bindresvport.
It binds to a port number before making a connection, so the local address
that is bound to is the 'default' rather than the best one to reach the given
target.  And in some network configs this can be bad, because e.g. the target
may not be able to reply to that 'default' address.

So you want to be able to specify the local endpoint fully when you bind, so
you require/allow the user to specify the local endpoint.

Wouldn't it be soooo much nicer if the tools could just figure out the
'correct' local endpoint and just use that?  Obviously "yes" but maybe that
isn't straight forward.  Have you looked into that at all?

Worst case (which may be so incredibly bad it isn't worth considering) is
that we could extract the routing table from the kernel and "figure it out".

But I suspect there is an easier way...  What if you create a UDP socket,
'connect' to some arbitrary port on the target machine, and then use
getsockname to get the local endpoint address of that socket.  That wouldn't
generate any network traffic, but should give you the preferred local
endpoint for talking to that peer??

For the in-kernel code I wouldn't accept a trick like that, but there is
presumably some way to find the preferred local endpoint for some address
more directly ... certainly worth asking on net-dev if we cannot figure one
out.


So I'm thinking:  yes, there is a real need, but I think there must be a
better solution.

What think you?

Thanks,
NeilBrown
