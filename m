Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:41619 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab3AWVxr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 16:53:47 -0500
Message-ID: <51005BE9.7060705@candelatech.com>
Date: Wed, 23 Jan 2013 13:53:45 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com>  <50FF4BC9.1060206@candelatech.com>  <1358921493.12374.737.camel@edumazet-glaptop>  <50FF8DEC.9070901@candelatech.com> <1358952122.12374.791.camel@edumazet-glaptop>
In-Reply-To: <1358952122.12374.791.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/23/2013 06:42 AM, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 23:14 -0800, Ben Greear wrote:
>
>> I suspect the bug goes back at least as far as 3.3.  And since
>> I need the NFS patches for this test case, bisecting will be pure hell.
>
> Make sure the bug is still present in net-next.
>

My test case isn't running well on net-next.  Seems most
of the file-io processes are hung trying to open a file:

[root@lf1011-12060006 lanforge]# cat /proc/10612/stack
[<ffffffff8115fadb>] do_last+0x1db/0xa4e
[<ffffffff8116090b>] path_openat+0xcb/0x363
[<ffffffff81160ca8>] do_filp_open+0x38/0x84
[<ffffffff81153bfc>] do_sys_open+0x6d/0xff
[<ffffffff81153cbb>] sys_open+0x1c/0x1e
[<ffffffff8154f629>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff


I'm going back to 3.7.3 and will try to learn some more
about what it's doing there.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

