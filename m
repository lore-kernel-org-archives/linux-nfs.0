From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
Date: Fri, 23 Apr 2010 12:03:56 -0400
Message-ID: <4BD1C4EC.8050404@oracle.com>
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr> <4BD1BD72.2030709@oracle.com> <alpine.LSU.2.01.1004231750380.20942@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:55120 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757855Ab0DWQFF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 12:05:05 -0400
In-Reply-To: <alpine.LSU.2.01.1004231750380.20942-SHaQjdQMGhDmsUXKMKRlFA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2010 11:53 AM, Jan Engelhardt wrote:
> On Friday 2010-04-23 17:32, Chuck Lever wrote:
>> On 04/23/2010 11:18 AM, Jan Engelhardt wrote:
>>>
>>> I just noticed that in a diskless-system initramfs, mount.nfs4 appears
>>> to hang whenever it cannot get a response (any response) from the
>>> rpcbind port. If there is no rpcbind running and thus, TCP RST is sent,
>>> fine. But if it's dropped, like when the "lo" device is not in the "up"
>>> state (as can easily happen at this stage of boot), mount.nfs4 waits
>>> forever.
>>
>> The rpcbind registration RPC request is "hard".  Maybe it should be "soft".
>>
>> But a better question is why are you doing an NFS mount if "lo" is not up?
>
> Don't ask me. When the kernel has started, lo is in the down state, and
> does not have any addresses assigned either. Distros have to currently
> do that themselves - usually only after the root filesystem has been
> moutned. I just ran into and reported that issue where lo is down the
> entire initramfs time. Needless to say NFSv3 has no problems with lo
> being down.

... that we know of.  I don't think statd and lockd would work in this 
case, but I've never tried it.

NFSv4 mount backgrounding hasn't worked until recently either, fwiw.

>> NFS has never worked in this case, because there would be no way for
>> the kernel to communicate with user space.
>
> Netlink and ioctls work without lo ;-)

Sure, but RPC doesn't go over ioctls :-)

> In fact, you'd be surprised how much of Linux works without an enabled
> lo device. Part of it may be because eth0 is up and has an address that
> can be used to do loopbacking ('local 192.168.1.15 dev eth0 proto
> kernel scope host src 192.168.1.15' in `ip route list table local`).

So, one way to address this would be if kernel_connect() returns a 
distinctive errno in this case (I would expect something like ENETDOWN) 
and then have the RPC transport behave as if it had received ECONNREFUSED.

Are you in a position to enable RPC debugging before doing that mount? 
If so, you can do

   # rpcdebug -m rpc -s trans

or, if rpcdebug isn't available, try

   # echo 128 > /proc/sys/sunrpc/rpc_debug

then try the mount. Look in /var/log/messages for the debugging messages.

If not, I'll have to find a way to try it here.

-- 
chuck[dot]lever[at]oracle[dot]com
