Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38574 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab1FIGMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 02:12:07 -0400
Message-ID: <4DF06430.1040608@candelatech.com>
Date: Wed, 08 Jun 2011 23:12:00 -0700
From: Ben Greear <greearb@candelatech.com>
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <20110609154719.5be627ca@notabene.brown>
In-Reply-To: <20110609154719.5be627ca@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2011 10:47 PM, NeilBrown wrote:
> On Wed,  8 Jun 2011 10:39:08 -0700 greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This lets one specify the source IP address for
>> sockets, allowing users to leverage routing rules
>> on multi-homed systems.
>>
>
> I gotta say I think this is rather horrible.....

And you haven't even seen the kernel side yet ;)

> As I understand it, the problem is bindresvport.
> It binds to a port number before making a connection, so the local address
> that is bound to is the 'default' rather than the best one to reach the given
> target.  And in some network configs this can be bad, because e.g. the target
> may not be able to reply to that 'default' address.
>
> So you want to be able to specify the local endpoint fully when you bind, so
> you require/allow the user to specify the local endpoint.
>
> Wouldn't it be soooo much nicer if the tools could just figure out the
> 'correct' local endpoint and just use that?  Obviously "yes" but maybe that
> isn't straight forward.  Have you looked into that at all?

Not nicer in all cases.

Sometimes a user knows best, and may want to use non-obvious
routing setups, such as rules that send pkts to different gateways
if they are from different source addresses.

> Worst case (which may be so incredibly bad it isn't worth considering) is
> that we could extract the routing table from the kernel and "figure it out".

There are potentially multiple routing tables.

> But I suspect there is an easier way...  What if you create a UDP socket,
> 'connect' to some arbitrary port on the target machine, and then use
> getsockname to get the local endpoint address of that socket.  That wouldn't
> generate any network traffic, but should give you the preferred local
> endpoint for talking to that peer??
>
> For the in-kernel code I wouldn't accept a trick like that, but there is
> presumably some way to find the preferred local endpoint for some address
> more directly ... certainly worth asking on net-dev if we cannot figure one
> out.
>
>
> So I'm thinking:  yes, there is a real need, but I think there must be a
> better solution.
>
> What think you?

I think I really do want to specify the local IP address.  There
are lots of other tools that allow this (ping, ssh, cifs, etc),
and there is a good reason for allowing it, primarily when used
in conjunction with routing rules that are based on source
IP.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
