From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
Date: Tue, 2 Feb 2010 11:22:28 -0500
Message-ID: <20100202162228.GD4293@fieldses.org>
References: <4B4F5A00.4060604@atmos.washington.edu> <20100122150325.6ad12428.akpm@linux-foundation.org> <20100127190522.GB18278@fieldses.org> <4B60C5D4.6070000@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Harry Edmon <harry@atmos.washington.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B60C5D4.6070000@atmos.washington.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 27, 2010 at 03:01:40PM -0800, Harry Edmon wrote:
> J. Bruce Fields wrote:
>> On Fri, Jan 22, 2010 at 03:03:25PM -0800, Andrew Morton wrote:
>>   
>>> (cc linux-nfs)
>>>
>>> On Thu, 14 Jan 2010 09:53:04 -0800
>>> Harry Edmon <harry@atmos.washington.edu> wrote:
>>>
>>>     
>>>> I have a single quad-core Xeon machine running 2.6.32.2 that keeps  
>>>> giving me "WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()".  This  
>>>> machine is mainaly used as a NFS server.  I have attached the 
>>>> kern.log and my config file.   Any ideas?
>>>>       
>>
>> Are you using NFSv4, or only v2/v3?  Looking at the trace:
>>
>> Jan 11 06:01:51 t kernel: [1311646.832173] ------------[ cut here ]------------
>> Jan 11 06:01:53 t kernel: [1311646.860891] WARNING: at lib/kref.c:43 kref_get+0x23/0x2b()
>>   
> NFSv4 and NFSv3.

Thanks.  And you aren't using rdma are you?

>> OK, so that's the warning that we're trying to get something with
>> reference count 0.
>>
>> Jan 11 06:01:53 t kernel: [1311646.894782] Hardware name: X7DB8
>> Jan 11 06:01:53 t kernel: [1311646.915165] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
>> Jan 11 06:01:53 t kernel: [1311647.178038] Pid: 3068, comm: nfsd Tainted: G      D W  2.6.32.2 #1
>>
>> What does the very first oops, bug, or warning you get look like?  (If
>> I'm reading the tain information right, this isn't the first one.)
>>   
> Attached is the kern.log that contains the first warning.

Thanks.  So yes, the first warning is a stray kref_put() in svc_recv(),
and the such put I see on a quick skim is a svc_xprt_put().  The
following BUG() is confirmation, since it's an attempt inside
scv-xprt_release() to clear an inode with I_CLEAR already set; so we
dropped the reference count to zero, cleared it, then tried to do
another get/put pair, resulting in an attempt to free the same socket
twice.

--b.

>
> -- 
> Dr. Harry Edmon			E-MAIL: harry@atmos.washington.edu
> 206-543-0547 FAX: 206-543-0308		harry@washington.edu, harry@uw.edu
> Director of IT, College of the Environment and
> Director of Computing, Dept of Atmospheric Sciences
> University of Washington, Box 351640, Seattle, WA 98195-1640
>

> Dec 27 11:57:44 t kernel: [37000.838904] 3w-9xxx: scsi6: AEN: INFO (0x04:0x0055): Battery charging started:.
> Dec 27 11:57:46 t kernel: [37002.028946] 3w-9xxx: scsi6: AEN: INFO (0x04:0x0056): Battery charging completed:.
> Dec 28 00:00:51 t kernel: [80387.429120] 3w-9xxx: scsi6: AEN: INFO (0x04:0x0029): Verify started:unit=0.
> Dec 28 03:32:07 t kernel: [93063.950486] 3w-9xxx: scsi6: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
> Dec 29 17:04:43 t kernel: [228218.883443] ------------[ cut here ]------------
> Dec 29 17:04:45 t kernel: [228218.911691] WARNING: at lib/kref.c:43 kref_get+0x23/0x2b()
> Dec 29 17:04:45 t kernel: [228218.945083] Hardware name: X7DB8
> Dec 29 17:04:45 t kernel: [228218.964948] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Dec 29 17:04:45 t kernel: [228219.227296] Pid: 3108, comm: nfsd Not tainted 2.6.32.2 #1
> Dec 29 17:04:45 t kernel: [228219.260164] Call Trace:
> Dec 29 17:04:45 t kernel: [228219.275350]  [<ffffffff81142230>] ? kref_get+0x23/0x2b
> Dec 29 17:04:45 t kernel: [228219.306656]  [<ffffffff81038943>] warn_slowpath_common+0x77/0xa4
> Dec 29 17:04:45 t kernel: [228219.343160]  [<ffffffff8103897f>] warn_slowpath_null+0xf/0x11
> Dec 29 17:04:45 t kernel: [228219.378105]  [<ffffffff81142230>] kref_get+0x23/0x2b
> Dec 29 17:04:45 t kernel: [228219.408379]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Dec 29 17:04:45 t kernel: [228219.441242]  [<ffffffffa028637f>] svc_recv+0x305/0x7e6 [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.477225]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.515806]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Dec 29 17:04:45 t kernel: [228219.552834]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Dec 29 17:04:45 t kernel: [228219.585698]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Dec 29 17:04:45 t kernel: [228219.618043]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Dec 29 17:04:45 t kernel: [228219.647789]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Dec 29 17:04:45 t kernel: [228219.678052]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Dec 29 17:04:45 t kernel: [228219.708317]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Dec 29 17:04:45 t kernel: [228219.739621] ---[ end trace 1a77408724500fae ]---
> Dec 29 17:04:45 t kernel: [228219.767925] ------------[ cut here ]------------
> Dec 29 17:04:45 t kernel: [228219.792730] kernel BUG at fs/inode.c:1343!
> Dec 29 17:04:45 t kernel: [228219.792730] invalid opcode: 0000 [#1] SMP 
> Dec 29 17:04:45 t kernel: [228219.792730] last sysfs file: /sys/class/scsi_host/host6/stats
> Dec 29 17:04:45 t kernel: [228219.792730] CPU 0 
> Dec 29 17:04:45 t kernel: [228219.792730] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Dec 29 17:04:45 t kernel: [228219.792730] Pid: 3108, comm: nfsd Tainted: G        W  2.6.32.2 #1 X7DB8
> Dec 29 17:04:45 t kernel: [228219.792730] RIP: 0010:[<ffffffff810bccc2>]  [<ffffffff810bccc2>] iput+0x1b/0x65
> Dec 29 17:04:45 t kernel: [228219.792730] RSP: 0018:ffff88012588bd20  EFLAGS: 00010246
> Dec 29 17:04:45 t kernel: [228219.792730] RAX: 0000000000000000 RBX: ffff88003c3c2cc8 RCX: ffffffff8139f927
> Dec 29 17:04:45 t kernel: [228219.792730] RDX: 0000000000000000 RSI: 0000000000000040 RDI: ffff88003c3c2cc8
> Dec 29 17:04:45 t kernel: [228219.792730] RBP: ffff88012588bd30 R08: 0000000000000002 R09: 0000000000000000
> Dec 29 17:04:45 t kernel: [228219.792730] R10: ffffffff81142230 R11: 0000000100000001 R12: ffff88003c3c2c80
> Dec 29 17:04:45 t kernel: [228219.792730] R13: ffffffffa028ef50 R14: ffff88010072d400 R15: ffff88012dd423c0
> Dec 29 17:04:45 t kernel: [228219.792730] FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
> Dec 29 17:04:45 t kernel: [228219.792730] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Dec 29 17:04:45 t kernel: [228219.792730] CR2: 00007fad86c2e000 CR3: 00000000305e5000 CR4: 00000000000006f0
> Dec 29 17:04:45 t kernel: [228219.792730] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Dec 29 17:04:45 t kernel: [228219.792730] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Dec 29 17:04:45 t kernel: [228219.792730] Process nfsd (pid: 3108, threadinfo ffff88012588a000, task ffff880125e66150)
> Dec 29 17:04:45 t kernel: [228219.792730] Stack:
> Dec 29 17:04:45 t kernel: [228219.792730]  ffff88012588bd90 ffff88010072d400 ffff88012588bd50 ffffffff811f4be2
> Dec 29 17:04:45 t kernel: [228219.792730] <0> ffff88010072d400 ffff88010072d410 ffff88012588bd70 ffffffffa027c1d2
> Dec 29 17:04:45 t kernel: [228219.792730] <0> ffff88012588bd70 ffff88010072d400 ffff88012588bda0 ffffffffa0286b03
> Dec 29 17:04:45 t kernel: [228219.792730] Call Trace:
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff811f4be2>] sock_release+0x5c/0x6c
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa027c1d2>] svc_sock_free+0x45/0x51 [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa0286b03>] svc_xprt_free+0x3e/0x4e [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff81142230>] ? kref_get+0x23/0x2b
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa0286ac5>] ? svc_xprt_free+0x0/0x4e [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff81142201>] kref_put+0x43/0x4f
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa0285f9f>] svc_xprt_release+0xc6/0xcf [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa02867fc>] svc_recv+0x782/0x7e6 [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Dec 29 17:04:45 t kernel: [228219.792730]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Dec 29 17:04:45 t kernel: [228219.792730] Code: c0 74 d5 48 83 c4 20 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 85 ff 74 50 48 83 bf 10 02 00 00 40 75 04 <0f> 0b eb fe 48 8d 7f 48 48 c7 c6 a0 7d 4a 81 e8 e2 31 08 00 85 
> Dec 29 17:04:45 t kernel: [228219.792730] RIP  [<ffffffff810bccc2>] iput+0x1b/0x65
> Dec 29 17:04:45 t kernel: [228219.792730]  RSP <ffff88012588bd20>
> Dec 29 17:04:45 t kernel: [228221.632694] ---[ end trace 1a77408724500faf ]---
> Dec 29 20:53:01 t kernel: [241917.056374] ------------[ cut here ]------------
> Dec 29 20:53:01 t kernel: [241917.084581] WARNING: at lib/kref.c:43 kref_get+0x23/0x2b()
> Dec 29 20:53:01 t kernel: [241917.117941] Hardware name: X7DB8
> Dec 29 20:53:01 t kernel: [241917.137804] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Dec 29 20:53:01 t kernel: [241917.400101] Pid: 3207, comm: nfsd Tainted: G      D W  2.6.32.2 #1
> Dec 29 20:53:01 t kernel: [241917.437653] Call Trace:
> Dec 29 20:53:01 t kernel: [241917.452843]  [<ffffffffa0286b0b>] ? svc_xprt_free+0x46/0x4e [sunrpc]
> Dec 29 20:53:01 t kernel: [241917.491420]  [<ffffffff81142230>] ? kref_get+0x23/0x2b
> Dec 29 20:53:01 t kernel: [241917.522728]  [<ffffffff81038943>] warn_slowpath_common+0x77/0xa4
> Dec 29 20:53:01 t kernel: [241917.559230]  [<ffffffff8103897f>] warn_slowpath_null+0xf/0x11
> Dec 29 20:53:01 t kernel: [241917.594177]  [<ffffffff81142230>] kref_get+0x23/0x2b
> Dec 29 20:53:01 t kernel: [241917.624446]  [<ffffffffa028637f>] svc_recv+0x305/0x7e6 [sunrpc]
> Dec 29 20:53:01 t kernel: [241917.660432]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Dec 29 20:53:01 t kernel: [241917.699013]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Dec 29 20:53:01 t kernel: [241917.736041]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Dec 29 20:53:01 t kernel: [241917.768905]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Dec 29 20:53:01 t kernel: [241917.801249]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Dec 29 20:53:01 t kernel: [241917.830993]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Dec 29 20:53:01 t kernel: [241917.861258]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Dec 29 20:53:01 t kernel: [241917.891522]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Dec 29 20:53:01 t kernel: [241917.922827] ---[ end trace 1a77408724500fb0 ]---
> Dec 29 20:53:01 t kernel: [241917.951084] ------------[ cut here ]------------
> Dec 29 20:53:03 t kernel: [241917.974874] kernel BUG at fs/inode.c:1343!
> Dec 29 20:53:03 t kernel: [241917.988010] invalid opcode: 0000 [#2] SMP 
> Dec 29 20:53:03 t kernel: [241917.988010] last sysfs file: /sys/class/scsi_host/host6/stats
> Dec 29 20:53:03 t kernel: [241917.988010] CPU 1 
> Dec 29 20:53:03 t kernel: [241917.988010] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Dec 29 20:53:03 t kernel: [241918.102960] Pid: 3207, comm: nfsd Tainted: G      D W  2.6.32.2 #1 X7DB8
> Dec 29 20:53:03 t kernel: [241918.102960] RIP: 0010:[<ffffffff810bccc2>]  [<ffffffff810bccc2>] iput+0x1b/0x65
> Dec 29 20:53:03 t kernel: [241918.102960] RSP: 0000:ffff8801225b9d20  EFLAGS: 00010246
> Dec 29 20:53:03 t kernel: [241918.102960] RAX: 0000000000000000 RBX: ffff880120435148 RCX: ffffffff8139f927
> Dec 29 20:53:03 t kernel: [241918.102960] RDX: 0000000000000000 RSI: 0000000000000040 RDI: ffff880120435148
> Dec 29 20:53:03 t kernel: [241918.102960] RBP: ffff8801225b9d30 R08: 0000000000000020 R09: ffff88002820c9d0
> Dec 29 20:53:03 t kernel: [241918.102960] R10: ffffffff81142230 R11: 0000000000000000 R12: ffff880120435100
> Dec 29 20:53:03 t kernel: [241918.102960] R13: ffffffffa028ef50 R14: ffff8800c1b3b800 R15: ffff88012dd423c0
> Dec 29 20:53:03 t kernel: [241918.102960] FS:  0000000000000000(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
> Dec 29 20:53:03 t kernel: [241918.102960] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Dec 29 20:53:03 t kernel: [241918.102960] CR2: 00007fad86c2e000 CR3: 0000000129ae6000 CR4: 00000000000006e0
> Dec 29 20:53:03 t kernel: [241918.102960] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Dec 29 20:53:03 t kernel: [241918.102960] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Dec 29 20:53:03 t kernel: [241918.102960] Process nfsd (pid: 3207, threadinfo ffff8801225b8000, task ffff880122416640)
> Dec 29 20:53:03 t kernel: [241918.102960] Stack:
> Dec 29 20:53:03 t kernel: [241918.102960]  ffff8801225b9d90 ffff8800c1b3b800 ffff8801225b9d50 ffffffff811f4be2
> Dec 29 20:53:03 t kernel: [241918.102960] <0> ffff8800c1b3b800 ffff8800c1b3b810 ffff8801225b9d70 ffffffffa027c1d2
> Dec 29 20:53:03 t kernel: [241918.102960] <0> ffff8801225b9d70 ffff8800c1b3b800 ffff8801225b9da0 ffffffffa0286b03
> Dec 29 20:53:03 t kernel: [241918.102960] Call Trace:
> Dec 29 20:53:03 t kernel: [241918.102960]  [<ffffffff811f4be2>] sock_release+0x5c/0x6c
> Dec 29 20:53:03 t kernel: [241918.102960]  [<ffffffffa027c1d2>] svc_sock_free+0x45/0x51 [sunrpc]
> Dec 29 20:53:03 t kernel: [241918.102960]  [<ffffffffa0286b03>] svc_xprt_free+0x3e/0x4e [sunrpc]
> Dec 29 20:53:03 t kernel: [241918.102960]  [<ffffffff81142230>] ? kref_get+0x23/0x2b
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa0286ac5>] ? svc_xprt_free+0x0/0x4e [sunrpc]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff81142201>] kref_put+0x43/0x4f
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa0285f9f>] svc_xprt_release+0xc6/0xcf [sunrpc]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa02867fc>] svc_recv+0x782/0x7e6 [sunrpc]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Dec 29 20:53:04 t kernel: [241918.102960]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Dec 29 20:53:04 t kernel: [241918.102960] Code: c0 74 d5 48 83 c4 20 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 85 ff 74 50 48 83 bf 10 02 00 00 40 75 04 <0f> 0b eb fe 48 8d 7f 48 48 c7 c6 a0 7d 4a 81 e8 e2 31 08 00 85 
> Dec 29 20:53:04 t kernel: [241918.102960] RIP  [<ffffffff810bccc2>] iput+0x1b/0x65
> Dec 29 20:53:04 t kernel: [241918.102960]  RSP <ffff8801225b9d20>
> Dec 29 20:53:04 t kernel: [241919.822190] ---[ end trace 1a77408724500fb1 ]---
> Dec 30 11:22:26 t kernel: [294082.152979] 3w-9xxx: scsi6: AEN: ERROR (0x04:0x0009): Drive timeout detected:port=0.
> Dec 31 11:24:44 t kernel: [380620.428029] br0: port 2(eth2) entering disabled state
> Dec 31 11:24:44 t kernel: [380620.458826] br0: port 1(eth1) entering disabled state
> Dec 31 11:24:44 t kernel: [380620.666738] device eth1 left promiscuous mode
> Dec 31 11:24:44 t kernel: [380620.693361] br0: port 1(eth1) entering disabled state
> Dec 31 11:24:44 t kernel: [380620.909921] device eth2 left promiscuous mode
> Dec 31 11:24:44 t kernel: [380620.936603] br0: port 2(eth2) entering disabled state
> Dec 31 11:24:48 t kernel: [380624.449637] device eth1 entered promiscuous mode
> Dec 31 11:24:48 t kernel: [380624.533887] e1000e 0000:06:00.1: irq 55 for MSI/MSI-X
> Dec 31 11:24:48 t kernel: [380624.620065] e1000e 0000:06:00.1: irq 55 for MSI/MSI-X
> Dec 31 11:24:48 t kernel: [380624.651581] ADDRCONF(NETDEV_UP): eth1: link is not ready
> Dec 31 11:24:48 t kernel: [380624.687675] device eth2 entered promiscuous mode
> Dec 31 11:24:48 t kernel: [380624.860445] e1000e 0000:08:00.0: irq 56 for MSI/MSI-X
> Dec 31 11:24:48 t kernel: [380624.944084] e1000e 0000:08:00.0: irq 56 for MSI/MSI-X
> Dec 31 11:24:48 t kernel: [380624.975824] ADDRCONF(NETDEV_UP): eth2: link is not ready
> Dec 31 11:24:50 t kernel: [380626.984998] e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:24:51 t kernel: [380627.031517] ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
> Dec 31 11:24:51 t kernel: [380627.066844] br0: port 2(eth2) entering forwarding state
> Dec 31 11:24:51 t kernel: [380627.251584] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:24:51 t kernel: [380627.300433] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> Dec 31 11:24:51 t kernel: [380627.335625] br0: port 1(eth1) entering forwarding state
> Dec 31 11:24:59 t kernel: [380635.148016] br0: no IPv6 routers present
> Dec 31 11:25:01 t kernel: [380637.504511] eth1: no IPv6 routers present
> Dec 31 11:25:01 t kernel: [380637.720515] eth2: no IPv6 routers present
> Dec 31 11:28:30 t kernel: [380846.205549] e1000e: eth1 NIC Link is Down
> Dec 31 11:28:30 t kernel: [380846.248659] br0: port 1(eth1) entering disabled state
> Dec 31 11:28:32 t kernel: [380848.693501] e1000e: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:28:32 t kernel: [380848.739167] 0000:06:00.1: eth1: 10/100 speed: disabling TSO
> Dec 31 11:28:32 t kernel: [380848.776396] br0: port 1(eth1) entering forwarding state
> Dec 31 11:28:49 t kernel: [380865.803038] e1000e: eth1 NIC Link is Down
> Dec 31 11:28:49 t kernel: [380865.874086] br0: port 1(eth1) entering disabled state
> Dec 31 11:28:52 t kernel: [380868.267943] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:28:52 t kernel: [380868.316772] br0: port 1(eth1) entering forwarding state
> Dec 31 11:29:18 t kernel: [380894.253543] e1000e: eth1 NIC Link is Down
> Dec 31 11:29:18 t kernel: [380894.293597] br0: port 1(eth1) entering disabled state
> Dec 31 11:29:20 t kernel: [380896.688442] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:29:20 t kernel: [380896.737255] br0: port 1(eth1) entering forwarding state
> Dec 31 11:29:25 t kernel: [380901.493543] e1000e: eth1 NIC Link is Down
> Dec 31 11:29:25 t kernel: [380901.534074] br0: port 1(eth1) entering disabled state
> Dec 31 11:29:28 t kernel: [380904.161008] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 31 11:29:28 t kernel: [380904.209842] br0: port 1(eth1) entering forwarding state
> Jan  1 22:40:06 t kernel: [507542.268700] ------------[ cut here ]------------
> Jan  1 22:40:08 t kernel: [507542.296925] WARNING: at lib/kref.c:43 kref_get+0x23/0x2b()
> Jan  1 22:40:08 t kernel: [507542.330301] Hardware name: X7DB8
> Jan  1 22:40:08 t kernel: [507542.350163] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Jan  1 22:40:08 t kernel: [507542.614635] Pid: 3134, comm: nfsd Tainted: G      D W  2.6.32.2 #1
> Jan  1 22:40:08 t kernel: [507542.652191] Call Trace:
> Jan  1 22:40:08 t kernel: [507542.667375]  [<ffffffff81142230>] ? kref_get+0x23/0x2b
> Jan  1 22:40:08 t kernel: [507542.698681]  [<ffffffff81038943>] warn_slowpath_common+0x77/0xa4
> Jan  1 22:40:08 t kernel: [507542.735186]  [<ffffffff8103897f>] warn_slowpath_null+0xf/0x11
> Jan  1 22:40:08 t kernel: [507542.770130]  [<ffffffff81142230>] kref_get+0x23/0xBj
> Jan  1 22:40:08 t kernel: [507542.800400]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Jan  1 22:40:08 t kernel: [507542.833269]  [<ffffffffa028637f>] svc_recv+0x305/0x7e6 [sunrpc]
> Jan  1 22:40:08 t kernel: [507542.869251]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Jan  1 22:40:08 t kernel: [507542.907825]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Jan  1 22:40:08 t kernel: [507542.944853]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Jan  1 22:40:08 t kernel: [507542.977720]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Jan  1 22:40:08 t kernel: [507543.010063]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Jan  1 22:40:08 t kernel: [507543.039808]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Jan  1 22:40:08 t kernel: [507543.070071]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Jan  1 22:40:08 t kernel: [507543.100337]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Jan  1 22:40:08 t kernel: [507543.131640] ---[ end trace 1a77408724500fb2 ]---
> Jan  1 22:40:08 t kernel: [507543.160026] general protection fault: 0000 [#3] SMP 
> Jan  1 22:40:08 t kernel: [507543.165025] last sysfs file: /sys/class/net/eth2/brport/hold_timer
> Jan  1 22:40:08 t kernel: [507543.165025] CPU 3 
> Jan  1 22:40:08 t kernel: [507543.165025] Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative nfsd nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp llc ipv6 i5000_edac edac_core i2c_i801 parport_pc parport psmouse container i2c_core ioatdma dca i5k_amb serio_raw pcspkr button processor joydev evdev xfs exportfs sg usbhid sr_mod hid cdrom ata_piix floppy uhci_hcd ehci_hcd ata_generic 3w_9xxx e1000e thermal fan raid1 md_mod sd_mod ahci libata scsi_mod [last unloaded: scsi_wait_scan]
> Jan  1 22:40:08 t kernel: [507543.165025] Pid: 3134, comm: nfsd Tainted: G      D W  2.6.32.2 #1 X7DB8
> Jan  1 22:40:08 t kernel: [507543.165025] RIP: 0010:[<ffffffffa0286797>]  [<ffffffffa0286797>] svc_recv+0x71d/0x7e6 [sunrpc]
> Jan  1 22:40:08 t kernel: [507543.165025] RSP: 0018:ffff880124ea1e00  EFLAGS: 00010246
> Jan  1 22:40:08 t kernel: [507543.165025] RAX: 3a30343a32322031 RBX: 0000000000000000 RCX: 0000000000000000
> Jan  1 22:40:08 t kernel: [507543.165025] RDX: 0000000000004c86 RSI: ffff880124ea1df0 RDI: ffff880124e00000
> Jan  1 22:40:08 t kernel: [507543.165025] RBP: ffff880124ea1eb0 R08: 0000000000000020 R09: ffff88002830ca70
> Jan  1 22:40:08 t kernel: [507543.165025] R10: ffff88002838cf40 R11: 0000000000000000 R12: 0000000000000082
> Jan  1 22:40:08 t kernel: [507543.165025] R13: ffff880124e00000 R14: ffff8800c7444000 R15: ffff88012dd423c0
> Jan  1 22:40:08 t kernel: [507543.165025] FS:  0000000000000000(0000) GS:ffff880028380000(0000) knlGS:0000000000000000
> Jan  1 22:40:08 t kernel: [507543.165025] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jan  1 22:40:08 t kernel: [507543.165025] CR2: 00007f0dc9cc5098 CR3: 000000012c266000 CR4: 00000000000006e0
> Jan  1 22:40:08 t kernel: [507543.165025] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jan  1 22:40:08 t kernel: [507543.165025] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jan  1 22:40:08 t kernel: [507543.165025] Process nfsd (pid: 3134, threadinfo ffff880124ea0000, task ffff880124e9f890)
> Jan  1 22:40:08 t kernel: [507543.165025] Stack:
> Jan  1 22:40:08 t kernel: [507543.165025]  ffff880124e00000 ffff880124e9f890 ffff880124ea1e40 00000000000dbba0
> Jan  1 22:40:08 t kernel: [507543.165025] <0> ffff88012dd423c4 ffff88012c0bea40 ffff880000000082 0000000000000001
> Jan  1 22:40:08 t kernel: [507543.165025] <0> ffff880124ea1eb0 ffffffffa027abe4 0000000000000000 ffff880124e9f890
> Jan  1 22:40:08 t kernel: [507543.165025] Call Trace:
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffffa027abe4>] ? svc_process+0x759/0x768 [sunrpc]
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffff81035177>] ? default_wake_function+0x0/0xf
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffffa032b7df>] ? nfsd+0x0/0x13a [nfsd]
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffffa032b886>] nfsd+0xa7/0x13a [nfsd]
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffff8104af36>] kthread+0x7d/0x85
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffff8100c97a>] child_rip+0xa/0x20
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffff8104aeb9>] ? kthread+0x0/0x85
> Jan  1 22:40:08 t kernel: [507543.165025]  [<ffffffff8100c970>] ? child_rip+0x0/0x20
> Jan  1 22:40:08 t kernel: [507543.165025] Code: 00 49 8d 85 88 01 00 00 49 89 85 a0 09 00 00 8b 82 e8 00 00 00 8d 1c 85 00 00 00 00 2b 9a e0 00 00 00 eb 0c 49 8b 46 08 4c 89 ef <ff> 50 18 89 c3 f6 05 56 ce 00 00 01 74 10 89 de 48 c7 c7 cf b6 
> Jan  1 22:40:08 t kernel: [507543.165025] RIP  [<ffffffffa0286797>] svc_recv+0x71d/0x7e6 [sunrpc]
> Jan  1 22:40:08 t kernel: [507543.165025]  RSP <ffff880124ea1e00>
> Jan  1 22:40:08 t kernel: [507544.713111] ---[ end trace 1a77408724500fb3 ]---
> Jan  2 12:06:02 t kernel: [555898.365986] RPC: multiple fragments per record not supported
> Jan  2 12:06:02 t kernel: [555898.527050] RPC: multiple fragments per record not supported
> Jan  2 12:06:05 t kernel: [555901.700485] RPC: multiple fragments per record not supported
> Jan  2 12:06:08 t kernel: [555904.880825] RPC: multiple fragments per record not supported
> Jan  3 00:01:08 t kernel: [598804.533706] 3w-9xxx: scsi6: AEN: INFO (0x04:0x0029): Verify started:unit=0.
> Jan  3 00:57:01 t kernel: [602157.347383] md: data-check of RAID array md0
> Jan  3 00:57:01 t kernel: [602157.350802] md: delaying data-check of md2 until md0 has finished (they share one or more physical units)
> Jan  3 00:57:01 t kernel: [602157.431453] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> Jan  3 00:57:01 t kernel: [602157.467054] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
> Jan  3 00:57:01 t kernel: [602157.526113] md: using 128k window, over a total of 19542976 blocks.
> Jan  3 01:03:47 t kernel: [602563.525129] md: md0: data-check done.
> Jan  3 01:03:47 t kernel: [602563.554886] md: data-check of RAID array md2
> Jan  3 01:03:47 t kernel: [602563.581194] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> Jan  3 01:03:47 t kernel: [602563.616879] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
> Jan  3 01:03:47 t kernel: [602563.675944] md: using 128k window, over a total of 460928832 blocks.
> Jan  3 04:47:09 t kernel: [615965.563359] md: md2: data-check done.
