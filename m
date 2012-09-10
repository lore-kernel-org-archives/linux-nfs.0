Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:50548 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347Ab2IJJBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 05:01:03 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TAzrU-00023w-A5
	for linux-nfs@vger.kernel.org; Mon, 10 Sep 2012 11:00:59 +0200
Received: from 59-124-179-67.HINET-IP.hinet.net ([59.124.179.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 10 Sep 2012 11:00:56 +0200
Received: from yanpai.chen by 59-124-179-67.HINET-IP.hinet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 10 Sep 2012 11:00:56 +0200
To: linux-nfs@vger.kernel.org
From: Yan-Pai Chen <yanpai.chen@gmail.com>
Subject: Re: [3.2.5] NFSv3 =?utf-8?b?Q0xPU0VfV0FJVA==?= hang
Date: Mon, 10 Sep 2012 09:00:37 +0000 (UTC)
Message-ID: <loom.20120910T105944-416@post.gmane.org>
References: <20120302184918.GA20702@hostway.ca> <loom.20120905T093214-245@post.gmane.org> <loom.20120905T093214-245@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com> <6cb9.5049fd40.b47c1@altium.nl> <6cb9.5049fd40.b47c1@altium.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com> <447c.504a05c9.dd0a9@altium.nl> <447c.504a05c9.dd0a9@altium.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com> <74c7.504b9d45.a5956@altium.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dick Streefland <dick.streefland@...> writes:

> 
> "Myklebust, Trond" <Trond.Myklebust@...> wrote:
> | Yes. Can you please see if the following patch fixes the UDP hang?
> | 
> | 8<---------------------------------------------------------------------
> | From f39c1bfb5a03e2d255451bff05be0d7255298fa4 Mon Sep 17 00:00:00 2001
> | From: Trond Myklebust <Trond.Myklebust@...>
> | Date: Fri, 7 Sep 2012 11:08:50 -0400
> | Subject: [PATCH] SUNRPC: Fix a UDP transport regression
> | 
> | Commit 43cedbf0e8dfb9c5610eb7985d5f21263e313802 (SUNRPC: Ensure that
> | we grab the XPRT_LOCK before calling xprt_alloc_slot) is causing
> | hangs in the case of NFS over UDP mounts.
> | 
> | Since neither the UDP or the RDMA transport mechanism use dynamic slot
> | allocation, we can skip grabbing the socket lock for those transports.
> | Add a new rpc_xprt_op to allow switching between the TCP and UDP/RDMA
> | case.
> | 
> | Note that the NFSv4.1 back channel assigns the slot directly
> | through rpc_run_bc_task, so we can ignore that case.
> | 
> | Reported-by: Dick Streefland <dick.streefland@...>
> | Signed-off-by: Trond Myklebust <Trond.Myklebust@...>
> | Cc: stable@... [>= 3.1]
> 
> This patch appears to fix the issue for me. I cannot reproduce the
> hang anymore.
> 

Hi Trond,

Apologies for my late response.
Upgrading to kernel 3.5 requires some effort. I am still working on it.

After applying your patch on 3.3 kernel, the problem is gone when using UDP 
mounts.
But it remains hang in the case of NFS over TCP mounts. 

I reproduced the problem by executing mm/mtest06_3 (i.e. mmap3) in the LTP test 
suite repeatedly.
About less than 200 times, it eventually ran into the CLOSE_WAIT hang.
I got the following messages after enabling rpc_debug & nfs_debug:

47991 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
a:call_reserveresult q:xprt_sending
47992 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
a:call_reserveresult q:xprt_sending
47993 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
a:call_reserveresult q:xprt_sending
47994 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
a:call_reserveresult q:xprt_sending
47995 0001    -11 cf2910e0   (null)        0 c0243f40 nfsv3 WRITE 
a:call_reserveresult q:xprt_sending
...

And the hung task information:

INFO: task mmap3:24017 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mmap3           D c0237070     0 24017  23980 0x00000000
[<c0237070>] (__schedule+0x608/0x6d8) from [<c02372d4>] (io_schedule+0x84/0xc0)
[<c02372d4>] (io_schedule+0x84/0xc0) from [<c006f2f0>] (sleep_on_page+0x8/0x10)
[<c006f2f0>] (sleep_on_page+0x8/0x10) from [<c02357dc>] 
(__wait_on_bit+0x54/0x9c)
[<c02357dc>] (__wait_on_bit+0x54/0x9c) from [<c006f6a8>] 
(wait_on_page_bit+0xbc/0xd4)
[<c006f6a8>] (wait_on_page_bit+0xbc/0xd4) from [<c00700c4>] 
(filemap_fdatawait_range+0x88/0x13c)
[<c00700c4>] (filemap_fdatawait_range+0x88/0x13c) from [<c007029c>] 
(filemap_write_and_wait_range+0x50/0x64)
[<c007029c>] (filemap_write_and_wait_range+0x50/0x64) from [<c00ff280>] 
(nfs_file_fsync+0x5c/0x154)
[<c00ff280>] (nfs_file_fsync+0x5c/0x154) from [<c00c200c>] 
(vfs_fsync_range+0x30/0x40)
[<c00c200c>] (vfs_fsync_range+0x30/0x40) from [<c00c203c>] (vfs_fsync+0x20/0x28)
[<c00c203c>] (vfs_fsync+0x20/0x28) from [<c009b880>] (filp_close+0x40/0x84)
[<c009b880>] (filp_close+0x40/0x84) from [<c001b9b0>] 
(put_files_struct+0xa8/0xfc)
[<c001b9b0>] (put_files_struct+0xa8/0xfc) from [<c001d3f4>] 
(do_exit+0x278/0x78c)
[<c001d3f4>] (do_exit+0x278/0x78c) from [<c001d9b0>] (do_group_exit+0xa8/0xd4)
[<c001d9b0>] (do_group_exit+0xa8/0xd4) from [<c002a538>] 
(get_signal_to_deliver+0x48c/0x4f8)
[<c002a538>] (get_signal_to_deliver+0x48c/0x4f8) from [<c000b7a0>] 
(do_signal+0x88/0x584)
[<c000b7a0>] (do_signal+0x88/0x584) from [<c000bcb4>] 
(do_notify_resume+0x18/0x50)
[<c000bcb4>] (do_notify_resume+0x18/0x50) from [<c0009418>] 
(work_pending+0x24/0x28)

--
Regards,
Andrew

