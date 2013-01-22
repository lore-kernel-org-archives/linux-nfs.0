Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:42274 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab3AVF5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 00:57:45 -0500
Message-ID: <50FE2A57.3040804@candelatech.com>
Date: Mon, 21 Jan 2013 21:57:43 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com> <1358829606.3464.3151.camel@edumazet-glaptop>
In-Reply-To: <1358829606.3464.3151.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/2013 08:40 PM, Eric Dumazet wrote:
> On Mon, 2013-01-21 at 16:32 -0800, Ben Greear wrote:
>> On 01/21/2013 01:07 PM, Ben Greear wrote:
>>> I posted about this a few days ago, but this time the patches applied
>>> are minimal and there are no out-of-tree kernel modules loaded.
>>
>> Here's another crash, this time with SLUB memory debugging turned on.
>>
>> Seems much harder to hit this way...I've only managed this one.  I
>> believe the RCX register might be interesting...that 6b is probably
>> freed memory poisioning.  Maybe skb or skb_dest() is already freed?
>>
>> I have added a 'verify_mem_not_deleted(skb)' before the
>> dst_input line in ip_rcv_finish..but so far, it hasn't
>> hit the problem...
>>
>
> There is no way skb is freed here.
>
> I would say macvlan is at fault here.
>
> It probably lacks a proper (dev->flags & IFF_UP) test.

Thanks for the patch.  It's running OK so far, but I'll need to
do a bunch more testing tomorrow to make sure I'm not just getting
lucky!

I'll let you know how it goes tomorrow.

Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

