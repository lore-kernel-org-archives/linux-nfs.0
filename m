Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moo.pl ([217.149.240.132]:48485 "EHLO moo.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab0I0VjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 17:39:13 -0400
Date: Mon, 27 Sep 2010 23:32:03 +0200
From: Leszek Urbanski <tygrys@moo.pl>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        virtualization@lists.linux-foundation.org
Subject: Re: BUG - qdev - partial loss of network connectivity
Message-ID: <20100927213203.GA28089@moo.pl>
References: <20100922171832.GA28721@moo.pl> <4C9A3FAF.9090503@codemonkey.ws> <20100922182049.GA29263@moo.pl> <4C9A4C77.2080806@codemonkey.ws> <20100923140437.GA9256@moo.pl> <20100926154324.GD21843@redhat.com>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20100926154324.GD21843@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

<20100926154324.GD21843@redhat.com>; from Michael S. Tsirkin on Sun, Sep 26, 2010 at 17:43:24 +0200

> > > >It's vanilla 2.6.32.22, but I also reproduced this on Debian's 2.6.32-23
> > > >(based on 2.6.32.21).
> > > >
> > > >If offload is the only difference, I'll play with different offload
> > > >options and check which one causes it.
> > > >   
> > > 
> > > It's not technically the only difference but it's the most likely 
> > > culprit IMHO.
> > 
> > udp fragmentation offload is definitely the culprit.
> 
> I see. Most likely guest bug - won't be the first bug around UFO.
> If so pls copy netdev linux-nfs and virtualization.
> Do you see anything in dmesg? Can try 2.6.36-rc5?

(for reference: first post is at:
http://lists.nongnu.org/archive/html/qemu-devel/2010-09/msg01685.html )

I can't reproduce it on 2.6.36-rc5. Do you have an idea which patch may have
fixed it, or should I dissect?

2.6.32.x - there's nothing interesting in dmesg, apart from traces related
to tasks in D state waiting on the NFS mounts:

[   84.396127] nfs: server 10.0.0.1 not responding, still trying
[  240.568162] INFO: task cp:1838 blocked for more than 120 seconds.
[  240.569715] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.571486] cp            D 0000000000000002     0  1838   1831 0x00000000
[  240.573340]  ffff88011fa5b880 0000000000000082 0000000000000000 ffff88011e45bb44
[  240.575508]  ffff88011e45bcc8 ffffffff8102cdac 000000000000f9e0 ffff88011e45bfd8
[  240.578827]  0000000000015780 0000000000015780 ffff88011c7ce2e0 ffff88011c7ce5d8
[  240.580502] Call Trace:
[  240.581132]  [<ffffffff8102cdac>] ? pvclock_clocksource_read+0x3a/0x8b
[  240.582427]  [<ffffffff8102cdac>] ? pvclock_clocksource_read+0x3a/0x8b
[  240.583869]  [<ffffffff810b3bdd>] ? sync_page+0x0/0x46
[  240.585034]  [<ffffffff810b3bdd>] ? sync_page+0x0/0x46
[  240.586087]  [<ffffffff812f9939>] ? io_schedule+0x73/0xb7
[  240.587287]  [<ffffffff810b3c1e>] ? sync_page+0x41/0x46
[  240.588202]  [<ffffffff812f9e46>] ? __wait_on_bit+0x41/0x70
[  240.589314]  [<ffffffff810b3da2>] ? wait_on_page_bit+0x6b/0x71
[  240.590630]  [<ffffffff81064a1c>] ? wake_bit_function+0x0/0x23
[  240.591906]  [<ffffffff810bb9ea>] ? pagevec_lookup_tag+0x1a/0x21
[  240.592954]  [<ffffffff810b4577>] ? wait_on_page_writeback_range+0x69/0x11b
[  240.594403]  [<ffffffff810b536e>] ? filemap_write_and_wait+0x26/0x32
[  240.595563]  [<ffffffffa02c0d35>] ? nfs_setattr+0xb9/0x117 [nfs]
[  240.596670]  [<ffffffff810b3a0b>] ? find_get_page+0x1a/0x77
[  240.598012]  [<ffffffff810b3bb9>] ? lock_page+0x9/0x1f
[  240.598878]  [<ffffffff810b41ee>] ? filemap_fault+0xb9/0x2f6
[  240.599839]  [<ffffffff810ca3c2>] ? __do_fault+0x38c/0x3c3
[  240.601003]  [<ffffffff810ee1ce>] ? do_sync_write+0xce/0x113
[  240.602082]  [<ffffffff81051e75>] ? current_fs_time+0x1e/0x24
[  240.602968]  [<ffffffff811009b7>] ? notify_change+0x180/0x2c5
[  240.604245]  [<ffffffff8110b7b5>] ? utimes_common+0x12d/0x14d
[  240.605355]  [<ffffffff8110b856>] ? do_utimes+0x81/0xca
[  240.606558]  [<ffffffff8110b9ab>] ? sys_utimensat+0x5b/0x6a
[  240.607817]  [<ffffffff81010b42>] ? system_call_fastpath+0x16/0x1b
[  240.609124] INFO: task find:1866 blocked for more than 120 seconds.
[  240.610409] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.612066] find          D 0000000000000000     0  1866   1863 0x00000000
[  240.613490]  ffffffff8145d1f0 0000000000000086 0000000000000000 ffff88011e2d2350
[  240.615188]  00000022b63d07c7 ffff88011c55e000 000000000000f9e0 ffff8800c78a5fd8
[  240.616576]  0000000000015780 0000000000015780 ffff88011e2d2350 ffff88011e2d2648
[  240.618297] Call Trace:
[  240.618777]  [<ffffffff810e5369>] ? virt_to_head_page+0x9/0x2a
[  240.619906]  [<ffffffff812fa07a>] ? __mutex_lock_common+0x122/0x192
[  240.621324]  [<ffffffff812fa1a2>] ? mutex_lock+0x1a/0x31
[  240.622543]  [<ffffffff81102c11>] ? mntput_no_expire+0x23/0xee
[  240.623860]  [<ffffffffa02c0b03>] ? nfs_getattr+0x3b/0xda [nfs]
[  240.625219]  [<ffffffff810f1839>] ? vfs_fstatat+0x43/0x57
[  240.626290]  [<ffffffff810f185e>] ? sys_newfstatat+0x11/0x30
[  240.627594]  [<ffffffff81102c11>] ? mntput_no_expire+0x23/0xee
[  240.628768]  [<ffffffff8101195b>] ? device_not_available+0x1b/0x20
[  240.629644]  [<ffffffff81010b42>] ? system_call_fastpath+0x16/0x1b


-- 
Leszek "Tygrys" Urbanski, SCSA, SCNA
 "Unix-to-Unix Copy Program;" said PDP-1. "You will never find a more
  wretched hive of bugs and flamers. We must be cautious." -- DECWARS
     http://cygnus.moo.pl/ -- Cygnus High Altitude Balloon
