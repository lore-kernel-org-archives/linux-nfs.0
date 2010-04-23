From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
Date: Fri, 23 Apr 2010 18:25:22 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004231818250.21405@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr> <4BD1BD72.2030709@oracle.com> <alpine.LSU.2.01.1004231750380.20942@obet.zrqbmnf.qr> <4BD1C4EC.8050404@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54947 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994Ab0DWQZY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 12:25:24 -0400
In-Reply-To: <4BD1C4EC.8050404@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Friday 2010-04-23 18:03, Chuck Lever wrote:
>>
>> Don't ask me. When the kernel has started, lo is in the down state, and
>> does not have any addresses assigned either. Distros have to currently
>> do that themselves - usually only after the root filesystem has been
>> moutned. I just ran into and reported that issue where lo is down the
>> entire initramfs time. Needless to say NFSv3 has no problems with lo
>> being down.
>
> ... that we know of.  I don't think statd and lockd would work in this case,
> but I've never tried it.

Well yeah, to use NFS as a root, -o nolock is commonly used.

>>> NFS has never worked in this case, because there would be no way for
>>> the kernel to communicate with user space.
>>
>> Netlink and ioctls work without lo ;-)
>
> Sure, but RPC doesn't go over ioctls :-)

Well maybe it should [go over netlink].

>> In fact, you'd be surprised how much of Linux works without an enabled
>> lo device. Part of it may be because eth0 is up and has an address that
>> can be used to do loopbacking ('local 192.168.1.15 dev eth0 proto
>> kernel scope host src 192.168.1.15' in `ip route list table local`).
>
> So, one way to address this would be if kernel_connect() returns a distinctive
> errno in this case (I would expect something like ENETDOWN) and then have the
> RPC transport behave as if it had received ECONNREFUSED.
>
> Are you in a position to enable RPC debugging before doing that mount? If so,
> you can do
>
>  # rpcdebug -m rpc -s trans

xs_error_report client f67bb800...
error 110
xs_tcp_state change client f67bb800...
state 7 conn 0 dead 0 zapped 1
xs_tcp_send_request(44) = -118
sendmsg returned unrecognized error 110
xs_tcp_state_change client ..
[...]
disconnecting xprt f67bb800 to reuse port
[...]
worker connecting xprt f67bb800 via tcp to 127.0.0.1 (port 111)
f67bb800 connect status 115 connected 0 sock state 2
xs_tcp_send_request(88) = -11
3 xmit incomplete (88 left of 88)

and so on (repeats every 20 sec)


> or, if rpcdebug isn't available, try
>
>  # echo 128 > /proc/sys/sunrpc/rpc_debug
> then try the mount. Look in /var/log/messages for the debugging messages.
>
> If not, I'll have to find a way to try it here.
