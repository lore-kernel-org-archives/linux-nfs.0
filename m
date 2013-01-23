Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:44655 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab3AWPXA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 10:23:00 -0500
Date: Wed, 23 Jan 2013 15:22:46 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <DABFD69DFA23FF330123B298@nimrod.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>		
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>		
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>	
 <734E2E0455BD4515C657BA69@Ximines.local>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

--On 21 January 2013 17:20:36 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

>> So, just to be clear, if a process is using NFS and AIO with O_DSYNC
>> (but not O_DIRECT) - which is I think what QEMU is meant to be doing -
>> then it should *never* be zero copy (even if writes happen to be
>> appropriately aligned). Is that correct? If so, I can strace the
>> process and see exactly what flags it is using.
>>
>
> That is correct. If you want zero-copy, then O_DIRECT is your thing
> (with or without aio). Otherwise, the kernel will always write to disk
> by copying through the page cache.

Just to follow up on this, QEMU (specifically hw/xen_disk.c) was using
O_DIRECT. If O_DIRECT is turned off, we get an additional page copy
but the bug does not appear.

It thus appears that the root of the problem is that if an AIO NFS
request is made with O_DIRECT, AIO can report the request is completed
even when the segment may need to be retransmitted, and whilst the
TCP stack correctly holds a reference to the page concerned, this
is not currently preventing Xen unmapping it as Xen thinks the IO
has completed.

I believe this problem may apply to iSCSI and for that matter (e.g.)
DRDB too.

-- 
Alex Bligh
