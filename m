From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
Date: Wed, 27 Jan 2010 14:05:22 -0500
Message-ID: <20100127190522.GB18278@fieldses.org>
References: <4B4F5A00.4060604@atmos.washington.edu> <20100122150325.6ad12428.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47578 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755861Ab0A0TD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 14:03:56 -0500
In-Reply-To: <20100122150325.6ad12428.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 22, 2010 at 03:03:25PM -0800, Andrew Morton wrote:
> (cc linux-nfs)
> 
> On Thu, 14 Jan 2010 09:53:04 -0800
> Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org> wrote:
> 
> > I have a single quad-core Xeon machine running 2.6.32.2 that keeps 
> > giving me "WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()".  This 
> > machine is mainaly used as a NFS server.  I have attached the kern.log 
> > and my config file.   Any ideas?

Are you using NFSv4, or only v2/v3?  Looking at the trace:

Jan 11 06:01:51 t kernel: [1311646.832173] ------------[ cut here ]------------
Jan 11 06:01:53 t kernel: [1311646.860891] WARNING: at lib/kref.c:43 kref_get+0x23/0x2b()

OK, so that's the warning that we're trying to get something with
reference count 0.

Jan 11 06:01:53 t kernel: [1311646.894782] Hardware name: X7DB8
Jan 11 06:01:53 t kernel: [1311646.915165] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
Jan 11 06:01:53 t kernel: [1311647.178038] Pid: 3068, comm: nfsd Tainted: G      D W  2.6.32.2 #1

What does the very first oops, bug, or warning you get look like?  (If
I'm reading the tain information right, this isn't the first one.)

Jan 11 06:01:53 t kernel: [1311647.216100] Call Trace:
Jan 11 06:01:53 t kernel: [1311647.231808]  [<ffffffff81142230>] ?  kref_get+0x23/0x2b
Jan 11 06:01:53 t kernel: [1311647.263633]  [<ffffffff81038943>] warn_slowpath_common+0x77/0xa4
Jan 11 06:01:53 t kernel: [1311647.300658]  [<ffffffff8103897f>] warn_slowpath_null+0xf/0x11
Jan 11 06:01:53 t kernel: [1311647.336122]  [<ffffffff81142230>] kref_get+0x23/0x2b
Jan 11 06:01:53 t kernel: [1311647.366914]  [<ffffffffa032b7df>] ?  nfsd+0x0/0x13a [nfsd]
Jan 11 06:01:53 t kernel: [1311647.400301]  [<ffffffffa028637f>] svc_recv+0x305/0x7e6 [sunrpc]

And the only likely candidate I see for a kref is the
svc_xprt_get(xprt).

--b.

Jan 11 06:01:53 t kernel: [1311647.436803]  [<ffffffffa027abe4>] ?  svc_process+0x759/0x768 [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.475903]  [<ffffffff81035177>] ?  default_wake_function+0x0/0xf
Jan 11 06:01:53 t kernel: [1311647.513452]  [<ffffffffa032b7df>] ?  nfsd+0x0/0x13a [nfsd]
Jan 11 06:01:53 t kernel: [1311647.546838]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
Jan 11 06:01:53 t kernel: [1311647.579701]  [<ffffffff8104af36>] kthread+0x7d/0x85
Jan 11 06:01:53 t kernel: [1311647.609967]  [<ffffffff8100c97a>] child_rip+0xa/0x20
Jan 11 06:01:53 t kernel: [1311647.640749]  [<ffffffff8104aeb9>] ?  kthread+0x0/0x85
Jan 11 06:01:53 t kernel: [1311647.671535]  [<ffffffff8100c970>] ?  child_rip+0x0/0x20
Jan 11 06:01:53 t kernel: [1311647.703359] ---[ end trace 1a77408724500fc0 ]---
Jan 11 06:01:53 t kernel: [1311647.732134] ------------[ cut here ]------------
Jan 11 06:01:53 t kernel: [1311647.736063] kernel BUG at fs/inode.c:1343!
Jan 11 06:01:53 t kernel: [1311647.736063] invalid opcode: 0000 [#10] SMP
Jan 11 06:01:53 t kernel: [1311647.736063] last sysfs file: /sys/block/md2/md/raid_disks
Jan 11 06:01:53 t kernel: [1311647.736063] CPU 3
Jan 11 06:01:53 t kernel: [1311647.736063] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
Jan 11 06:01:53 t kernel: [1311647.736063] Pid: 3068, comm: nfsd
Tainted: G      D W  2.6.32.2 #1 X7DB8
Jan 11 06:01:53 t kernel: [1311647.736063] RIP:
0010:[<ffffffff810bccc2>]  [<ffffffff810bccc2>] iput+0x1b/0x65
Jan 11 06:01:53 t kernel: [1311647.736063] RSP: 0018:ffff88012730bd20 EFLAGS: 00010246
Jan 11 06:01:53 t kernel: [1311647.736063] RAX: 0000000000000000 RBX: ffff88010c9c7408 RCX: ffffffff8139f927
Jan 11 06:01:53 t kernel: [1311647.736063] RDX: 0000000000000000 RSI: 0000000000000040 RDI: ffff88010c9c7408
Jan 11 06:01:53 t kernel: [1311647.736063] RBP: ffff88012730bd30 R08: 0000000000000020 R09: ffff88002830ca70
Jan 11 06:01:53 t kernel: [1311647.736063] R10: ffffffff81142230 R11: 0000000000000000 R12: ffff88010c9c73c0
Jan 11 06:01:53 t kernel: [1311647.736063] R13: ffffffffa028ef50 R14: ffff880018c58000 R15: ffff88012dd423c0
Jan 11 06:01:53 t kernel: [1311647.736063] FS:  0000000000000000(0000) GS:ffff880028380000(0000) knlGS:0000000000000000
Jan 11 06:01:53 t kernel: [1311647.736063] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Jan 11 06:01:53 t kernel: [1311647.736063] CR2: 00007f0dc9cc5098 CR3: 0000000005bd8000 CR4: 00000000000006e0
Jan 11 06:01:53 t kernel: [1311647.736063] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jan 11 06:01:53 t kernel: [1311647.736063] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jan 11 06:01:53 t kernel: [1311647.736063] Process nfsd (pid: 3068, threadinfo ffff88012730a000, task ffff8801270e8150)
Jan 11 06:01:53 t kernel: [1311647.736063] Stack:
Jan 11 06:01:53 t kernel: [1311647.736063]  ffff88012730bd90 ffff880018c58000 ffff88012730bd50 ffffffff811f4be2
Jan 11 06:01:53 t kernel: [1311647.736063] <0> ffff880018c58000 ffff880018c58010 ffff88012730bd70 ffffffffa027c1d2
Jan 11 06:01:53 t kernel: [1311647.736063] <0> ffff88012730bd70 ffff880018c58000 ffff88012730bda0 ffffffffa0286b03
Jan 11 06:01:53 t kernel: [1311647.736063] Call Trace:
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff811f4be2>] sock_release+0x5c/0x6c
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa027c1d2>] svc_sock_free+0x45/0x51 [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa0286b03>] svc_xprt_free+0x3e/0x4e [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff81142230>] ?  kref_get+0x23/0x2b
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa0286ac5>] ?  svc_xprt_free+0x0/0x4e [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff81142201>] kref_put+0x43/0x4f
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa0285f9f>] svc_xprt_release+0xc6/0xcf [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa02867fc>] svc_recv+0x782/0x7e6 [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa027abe4>] ?  svc_process+0x759/0x768 [sunrpc]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff81035177>] ?  default_wake_function+0x0/0xf
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa032b7df>] ?  nfsd+0x0/0x13a [nfsd]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff8104af36>] kthread+0x7d/0x85
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff8100c97a>] child_rip+0xa/0x20
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff8104aeb9>] ?  kthread+0x0/0x85
Jan 11 06:01:53 t kernel: [1311647.736063]  [<ffffffff8100c970>] ?  child_rip+0x0/0x20
Jan 11 06:01:53 t kernel: [1311647.736063] Code: c0 74 d5 48 83 c4 20 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 85 ff 74 50 48 83 bf 10 02 00 00 40 75 04 <0f> 0b eb fe 48 8d 7f 48 48 c7 c6 a0 7d 4a 81 e8 e2 31 08 00 85
Jan 11 06:01:53 t kernel: [1311647.736063] RIP  [<ffffffff810bccc2>] iput+0x1b/0x65
Jan 11 06:01:53 t kernel: [1311647.736063]  RSP <ffff88012730bd20>
Jan 11 06:01:53 t kernel: [1311649.618340] ---[ end trace 1a77408724500fc1 ]--- 
