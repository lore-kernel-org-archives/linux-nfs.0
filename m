From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
Date: Fri, 23 Apr 2010 17:53:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004231750380.20942@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr> <4BD1BD72.2030709@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:53180 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994Ab0DWPxz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 11:53:55 -0400
In-Reply-To: <4BD1BD72.2030709@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 2010-04-23 17:32, Chuck Lever wrote:
> On 04/23/2010 11:18 AM, Jan Engelhardt wrote:
>>
>> I just noticed that in a diskless-system initramfs, mount.nfs4 appears
>> to hang whenever it cannot get a response (any response) from the
>> rpcbind port. If there is no rpcbind running and thus, TCP RST is sent,
>> fine. But if it's dropped, like when the "lo" device is not in the "up"
>> state (as can easily happen at this stage of boot), mount.nfs4 waits
>> forever.
>
> The rpcbind registration RPC request is "hard".  Maybe it should be "soft".
>
> But a better question is why are you doing an NFS mount if "lo" is not up?

Don't ask me. When the kernel has started, lo is in the down state, and 
does not have any addresses assigned either. Distros have to currently 
do that themselves - usually only after the root filesystem has been 
moutned. I just ran into and reported that issue where lo is down the 
entire initramfs time. Needless to say NFSv3 has no problems with lo 
being down.

>NFS has never worked in this case, because there would be no way for 
>the kernel to communicate with user space.

Netlink and ioctls work without lo ;-)
In fact, you'd be surprised how much of Linux works without an enabled 
lo device. Part of it may be because eth0 is up and has an address that 
can be used to do loopbacking ('local 192.168.1.15 dev eth0 proto 
kernel scope host src 192.168.1.15' in `ip route list table local`).
