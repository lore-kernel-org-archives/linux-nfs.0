From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sun, 22 Feb 2009 15:17:56 -0800
Message-ID: <49A1DD24.9060801@candelatech.com>
References: <4977C580.4040805@candelatech.com>	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>	 <497805A7.4070205@candelatech.com>	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>	 <4978AD75.9090900@candelatech.com>	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>	 <499FB08B.1070200@candelatech.com>	 <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>	 <49A0E802.9000209@candelatech.com> <1235329791.7331.75.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55585 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551AbZBVXSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 18:18:16 -0500
In-Reply-To: <1235329791.7331.75.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
>> I want to have a unique mount per local IP, so if I mount the same 
>> server from 1.1.1.1 and from 1.1.1.2, I
>> want two unique mounts.  I believe the way to do this is to 
>> differentiate based on the IP addr,
>> which is what this code is supposed to be doing.
>>     
>
> You can already do that using the -onosharecache option.
>   
I wasn't aware of that option.  Even with it, I think my changes are
useful, at least for my particular use.
> I really dislike this idea of adding routing information at the sunrpc
> level. So, I repeat: what is the application for all this? I've heard
> mutterings about routing and multi-homed servers, but absolutely zero in
> the way of specific applications and requirements.
>
> Why can't you for instance do exactly the same thing, simply by setting
> up two separate local networks; one for each NIC?
>   
My specific application is a testing tool that emulates 1000+ unique NFS 
clients,
primarily for testing  & loading NFS servers.
I put each client on a mac-vlan and put them all on the same subnet so 
that I don't
need any routers between my box and the nfs server.  (We can also put
them on different subnets and use different routers, and the specific 
source-ip
also helps there...)

I use routing tricks to enforce that a particular source-IP uses a 
specific routing
table, and that ties pkts to a specific mac-vlan interface.  The mount 
bindaddr
option then binds a mount to a specific local IP and thus to a specific 
mac-vlan.

This shows 1000+ mounts on my test box, and the nfs server sees 1000
unique clients (all with different MACs, IPS, etc).

It's possible that this is the only useful thing anyone will ever do 
with this option,
and if so, probably not a good enough reason to add it to the tree.  
But, I think
it's more likely that it will also help someone else who is trying to do 
something
we've never considered.

I'm not really making any changes to the sunrpc layer..it already has 
the option
to bind to a local address it seems.  I'm just allowing the user to fill 
in this value
before calling the sunrpc (current code in the tree just uses 'any' for 
the source
address).

If you still see no use for this option, just say so and I'll quit 
bugging you about
it.  I appreciate the help given so far to make the patch work better 
for me,
and can keep it in my private tree easily enough.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


