Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:61523 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122Ab3JaTp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 15:45:57 -0400
Received: from [192.168.178.60] ([84.173.43.191]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0Lx83d-1VijQQ0xT7-016cv6 for
 <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 20:45:55 +0100
Message-ID: <5272B372.8040307@gmx.de>
Date: Thu, 31 Oct 2013 20:45:54 +0100
From: Helge Deller <deller@gmx.de>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux Kernel Development <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        linux-parisc <linux-parisc@vger.kernel.org>
Subject: Re: 3.12-rcX - NFS regression - kswapd0 / kswapd1 stays using 100%
 CPU?
References: <52604BA9.20104@gmx.de>		 <1382044045.3216.44.camel@leira.trondhjem.org> <52618B5F.4000508@gmx.de>	 <1382124981.20461.4.camel@leira.trondhjem.org> <5261940A.4090101@gmx.de> <1382127133.20461.9.camel@leira.trondhjem.org> <5262CF20.20301@gmx.de>
In-Reply-To: <5262CF20.20301@gmx.de>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/19/2013 08:27 PM, Helge Deller wrote:
> On 10/18/2013 10:12 PM, Myklebust, Trond wrote:
>> On Fri, 2013-10-18 at 22:03 m, Helge Deller wrote:
>>> On 10/18/2013 09:36 PM, Myklebust, Trond wrote:
>>>> Also, could you please try a sysRQ-t the next time it happens, so that
>>>> we can get a trace of where the mount program is hanging. Knowing that
>>>> the mount is stuck in "__schedule()" is not really interesting unless we
>>>> know from where that was called.
>>>
>>> Actually, the machine was still running in this state.
>>> Here is sysrq-t:
>>> [112009.084000] mount           S 00000000401040c0     0 25331      1 0x00000010
>>> [112009.084000] Backtrace:
>>> [112009.084000]  [<0000000040113a68>] __schedule
>>> [112009.232000]
>>> [112009.232000] mount.nfs       D 00000000401040c0     0 25332  25331 0x00000010
>>> [112009.232000] Backtrace:
>>> [112009.232000]  [<0000000040113a68>] __schedule
>>
>> That makes no sense unless sysrq-t works differently on parisc than on
>> other platforms. I'd expect the backtrace to at least include a system
>> call. Parisc experts?
> 
> sysrq-t doesn't work differently on parisc. For other processes I do get
> a backtrace like the one on x86_64.
> That's the main reason why I asked for ideas here on the list.
> I do see the stuck process, but don't see any indications where it comes from.

I'm pretty sure that the regression (kswapd using 100% CPU) I reported here is fixed by this patch:
http://git.kernel.org/cgit/linux/kernel/git/deller/parisc-linux.git/commit/?id=c56b097af26cb11c1f49a4311ba538c825666fed

I will start some testing...

Helge
