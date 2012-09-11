Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:36431 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174Ab2IKTkw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2012 15:40:52 -0400
Date: Tue, 11 Sep 2012 12:40:51 -0700
From: Simon Kirby <sim@hostway.ca>
To: Yan-Pai Chen <yanpai.chen@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Message-ID: <20120911194051.GB11160@hostway.ca>
References: <loom.20120905T093214-245@post.gmane.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com>
 <6cb9.5049fd40.b47c1@altium.nl>
 <6cb9.5049fd40.b47c1@altium.nl>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>
 <447c.504a05c9.dd0a9@altium.nl>
 <447c.504a05c9.dd0a9@altium.nl>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>
 <74c7.504b9d45.a5956@altium.nl>
 <loom.20120910T105944-416@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20120910T105944-416@post.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 10, 2012 at 09:00:37AM +0000, Yan-Pai Chen wrote:

> Hi Trond,
> 
> Apologies for my late response.
> Upgrading to kernel 3.5 requires some effort. I am still working on it.
> 
> After applying your patch on 3.3 kernel, the problem is gone when using UDP 
> mounts.
> But it remains hang in the case of NFS over TCP mounts. 
> 
> I reproduced the problem by executing mm/mtest06_3 (i.e. mmap3) in the LTP test 
> suite repeatedly.
> About less than 200 times, it eventually ran into the CLOSE_WAIT hang.
> I got the following messages after enabling rpc_debug & nfs_debug:
> 
> 47991 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
> a:call_reserveresult q:xprt_sending
> 47992 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
> a:call_reserveresult q:xprt_sending
> 47993 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
> a:call_reserveresult q:xprt_sending
> 47994 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
> a:call_reserveresult q:xprt_sending
> 47995 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
> a:call_reserveresult q:xprt_sending
> ...

Hello!

This problem still bites us rarely, and we've been using TCP NFS for some
time. However, our case seems to be narrowed it down to a very long
storage hang on the knfsd side. If storage never has any problems, we
don't see the NFS client hang. I was going to try to make a test-case by
forcing the server to hang, but I never got around to this. Meanwhile,
I've been running the clients with the debugging patches I posted
earlier, and it always prints the 'xprt_force_disconnect(): setting
XPRT_CLOSE_WAIT" warning before hanging. If Apache is in sendfile() at
the time, it seems to get stuck forever; otherwise, it might recover.

http://www.spinics.net/lists/linux-nfs/msg29495.html
http://0x.ca/sim/ref/3.2.10/dmesg

I suppose we could try 3.5 at this point.

Simon-
