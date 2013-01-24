Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:52496 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3AXSmM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 13:42:12 -0500
Message-ID: <51018083.1000304@candelatech.com>
Date: Thu, 24 Jan 2013 10:42:11 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: Hung tasks related to do_filp_open in net-next (3.8.0-rc3+)
References: <51005858.4040107@candelatech.com>
In-Reply-To: <51005858.4040107@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/23/2013 01:38 PM, Ben Greear wrote:
>
> I cranked up my 3000 NFS mounts test case on today's net-next (3.8.0-rc3+)
> and about 8 of these splats.  There were around 780 mounts active
> when these occurred.
>
> Seems like the system continues OK, so not sure how important
> this is...

I'm seeing this occasionally on 3.7.3 (plus Eric's patch to fix
the crashes I was seeing), so it's not a regression.

Maybe it's just expected on a very overloaded system....

Thanks,
Ben

>
> INFO: task btserver:8756 blocked for more than 180 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> btserver        D 0000000000000004     0  8756   5781 0x00000080
>   ffff880404ab1bf8 0000000000000046 0000000004ab1ba8 0000000000000432
>   ffff880404ab0010 ffff880402263f20 ffff880404ab1fd8 00000000000132c0
>   00000000000132c0 00000000000132c0 ffff880404ab1fd8 00000000000132c0
> Call Trace:
>   [<ffffffff815491ea>] schedule+0x5f/0x61
>   [<ffffffff815494fa>] schedule_preempt_disabled+0x13/0x1f
>   [<ffffffff81547ea8>] __mutex_lock_common+0x264/0x42d
>   [<ffffffff8115fadb>] ? do_last+0x1db/0xa4e
>   [<ffffffff8115fadb>] ? do_last+0x1db/0xa4e
>   [<ffffffff815480d0>] mutex_lock_nested+0x16/0x18
>   [<ffffffff8115fadb>] do_last+0x1db/0xa4e
>   [<ffffffff8115f3a5>] ? path_init+0xcd/0x2b6
>   [<ffffffff8116090b>] path_openat+0xcb/0x363
>   [<ffffffff810d0055>] ? __lock_acquire+0x1df/0x53d
>   [<ffffffff81160ca8>] do_filp_open+0x38/0x84
>   [<ffffffff8154a2db>] ? _raw_spin_unlock+0x45/0x52
>   [<ffffffff8116c203>] ? __alloc_fd+0x106/0x11a
>   [<ffffffff815490f9>] ? __schedule+0x561/0x5a3
> 8021q: adding VLAN 0 to HW filter on device eth4#621
>   [<ffffffff81153bfc>] do_sys_open+0x6d/0xff
> 8021q: adding VLAN 0 to HW filter on device eth3#612
>   [<ffffffff81153cbb>] sys_open+0x1c/0x1e
>   [<ffffffff8154f629>] system_call_fastpath+0x16/0x1b
> 2 locks held by btserver/8756:
>   #0:  (sb_writers#10){......}, at: [<ffffffff81170013>] mnt_want_write+0x1f/0x48
>   #1:  (&type->i_mutex_dir_key#4){......}, at: [<ffffffff8115fadb>] do_last+0x1db/0xa4e
>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

