Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:47383 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab3AXT0S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 14:26:18 -0500
Message-ID: <51018AD9.2040608@candelatech.com>
Date: Thu, 24 Jan 2013 11:26:17 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Comments on the bind-to-local IP patch series I posted?
References: <51018157.9060000@candelatech.com> <4FA345DA4F4AE44899BD2B03EEEC2FA91833788D@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91833788D@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/24/2013 11:12 AM, Myklebust, Trond wrote:
> On Thu, 2013-01-24 at 10:45 -0800, Ben Greear wrote:
>> I'd really like to get some feedback on whether the patches I posted
>> have a chance at upstream inclusion.  If the whole idea is DOA,
>> then just let me know and I promise not to ask again for a few
>> years :)
>>
>> Otherwise, if any improvements are needed, I'll be happy to work on
>> them.
>
> My stated goal has always been to support this kind of setup through net
> namespaces and containers. Now that Stanislav has added that support (at
> least for the RPC+NFS clients), why do we need a second solution?
>
> IOW: Is there any reason why you can't just use 'virt-sandbox', for
> instance, to start up an lxc session with its own network ip address and
> then run your application?

My application would not work well with that..if for no other reason than it
would be terribly complicated to manage 3000 sandboxes and whatever applications
were running in those sandboxes.

In addition, on multi-homed machines, there can be some general advantages
to allowing binding to specific IP addresses.  A somewhat contrived example
would be two network interfaces on same subnet, wired to a 1G/10G switch.
With binding, you could mount the same server two different times, and spread
the load on the two 1G (client side) interfaces.

Or, just keep all nfs traffic on a particular interface for some other
reason like some small level of security.

 From what I can tell, my patches should not add any real overhead,
and the code is not that complex.

But, I suspect that my handling of the callback binding address could be
problematic if someone wanted to do some strange asymmetric routing,
so I'd probably need a way to make that configurable and disabled
by default.  If the rest of the series has a chance, I'd like to
ask your opinion on a preferred way to configure this.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

