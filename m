Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39675 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab0DWRAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 13:00:33 -0400
Message-ID: <4BD1D21E.7080506@oracle.com>
Date: Fri, 23 Apr 2010 13:00:14 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Jan Engelhardt <jengelh@medozas.de>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr> <4BD1BD72.2030709@oracle.com> <alpine.LSU.2.01.1004231750380.20942@obet.zrqbmnf.qr> <4BD1C4EC.8050404@oracle.com> <alpine.LSU.2.01.1004231818250.21405@obet.zrqbmnf.qr>
In-Reply-To: <alpine.LSU.2.01.1004231818250.21405@obet.zrqbmnf.qr>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/23/2010 12:25 PM, Jan Engelhardt wrote:
>
> On Friday 2010-04-23 18:03, Chuck Lever wrote:
>>>
>>> Don't ask me. When the kernel has started, lo is in the down state, and
>>> does not have any addresses assigned either. Distros have to currently
>>> do that themselves - usually only after the root filesystem has been
>>> moutned. I just ran into and reported that issue where lo is down the
>>> entire initramfs time. Needless to say NFSv3 has no problems with lo
>>> being down.
>>
>> ... that we know of.  I don't think statd and lockd would work in this case,
>> but I've never tried it.
>
> Well yeah, to use NFS as a root, -o nolock is commonly used.

NFSv4 is known not to work for NFSROOT (although you are using 
mount.nfs4 from an initramfs, not NFSROOT).  One problem is that 
idmapper has to be running to prevent NFSv4 deadlocks.

I'm just a little surprised because I was not aware that anyone was 
doing user space NFS mounts in an environment with no lo configured.

If you have an initramfs mounted as root, the ramfs's init scripts 
probably could get lo going before doing the mount, in this case.

>>>> NFS has never worked in this case, because there would be no way for
>>>> the kernel to communicate with user space.
>>>
>>> Netlink and ioctls work without lo ;-)
>>
>> Sure, but RPC doesn't go over ioctls :-)
>
> Well maybe it should [go over netlink].

I'm actually planning to construct an RPC over AF_UNIX transport 
capability for the kernel.  This will mirror support for RPC over 
AF_UNIX added in user space with the introduction of libtirpc.  rpcbind 
already has an AF_UNIX listener thanks to libtirpc.

However, this work was planned for a time when lo is replaced with lo6 
in a large number of cases, which should be some time in the future. 
Your report is accelerating this use case!  :-)

>>> In fact, you'd be surprised how much of Linux works without an enabled
>>> lo device. Part of it may be because eth0 is up and has an address that
>>> can be used to do loopbacking ('local 192.168.1.15 dev eth0 proto
>>> kernel scope host src 192.168.1.15' in `ip route list table local`).
>>
>> So, one way to address this would be if kernel_connect() returns a distinctive
>> errno in this case (I would expect something like ENETDOWN) and then have the
>> RPC transport behave as if it had received ECONNREFUSED.
>>
>> Are you in a position to enable RPC debugging before doing that mount? If so,
>> you can do
>>
>>   # rpcdebug -m rpc -s trans
>
> xs_error_report client f67bb800...
> error 110
> xs_tcp_state change client f67bb800...
> state 7 conn 0 dead 0 zapped 1
> xs_tcp_send_request(44) = -118
> sendmsg returned unrecognized error 110
> xs_tcp_state_change client ..
> [...]
> disconnecting xprt f67bb800 to reuse port
> [...]
> worker connecting xprt f67bb800 via tcp to 127.0.0.1 (port 111)
> f67bb800 connect status 115 connected 0 sock state 2
> xs_tcp_send_request(88) = -11
> 3 xmit incomplete (88 left of 88)
>
> and so on (repeats every 20 sec)

I'd like to see the full log captured during your test, with time 
stamps.  110 is ETIMEDOUT, which suggests the network layer is not 
reporting that the loopback interface is not up, but simply that the SYN 
is timing out.

And if you could, "^-s trans^-s trans xprt clnt sched bind".

Thanks for your help.

-- 
chuck[dot]lever[at]oracle[dot]com
