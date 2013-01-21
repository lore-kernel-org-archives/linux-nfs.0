Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:38711 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902Ab3AURMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2013 12:12:31 -0500
Date: Mon, 21 Jan 2013 17:12:16 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <734E2E0455BD4515C657BA69@Ximines.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>	
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

--On 21 January 2013 15:50:48 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

>> I don't think QEMU is actually using O_DIRECT unless I set cache=none
>> on the drive. That causes a different interesting failure which isn't
>> my focus just now!
>
> Then your reference to Ian's bug is a red herring.
>
> If the application is using buffered writes, then the data is
> immediately copied from userspace to the page cache. Once the copy to
> the page cache is done, userspace can do whatever it wants with the
> original buffer, because only the page cache pages are used in the RPC
> calls.
>
> aio doesn't change any of this...

So, just to be clear, if a process is using NFS and AIO with O_DSYNC
(but not O_DIRECT) - which is I think what QEMU is meant to be doing -
then it should *never* be zero copy (even if writes happen to be
appropriately aligned). Is that correct? If so, I can strace the
process and see exactly what flags it is using.

-- 
Alex Bligh
