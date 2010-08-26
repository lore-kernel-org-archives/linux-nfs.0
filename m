Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22172 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab0HZRhq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 13:37:46 -0400
Subject: Re: Kernel BUG() in nfs_do_writepage (write.c:276)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C767A1D.80103@mudrichsystems.com>
Date: Thu, 26 Aug 2010 13:36:42 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <799B4575-8B95-4485-90E0-72E9781FE6AE@oracle.com>
References: <4C767A1D.80103@mudrichsystems.com>
To: David Mudrich <dmudrich@mudrichsystems.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 26, 2010, at 10:28 AM, David Mudrich wrote:

> Hello,
> 
> we often get Kernel BUG().
> 
> dmesg:
> 
> ------------[ cut here ]------------
> kernel BUG at fs/nfs/write.c:276!
> invalid opcode: 0000 [#2] SMP
> last sysfs file: /sys/devices/virtio-pci/virtio1/block/vda/size
> CPU 0
> Modules linked in:
> 
> Pid: 2098, comm: flush-0:17 Tainted: G      D     2.6.35.3.x86_64.aufs #4 /Bochs
> RIP: 0010:[<ffffffff811b66f1>]  [<ffffffff811b66f1>] nfs_do_writepage+0x201/0x210
> RSP: 0018:ffff88003c601a10  EFLAGS: 00010202
> RAX: 0000000000000002 RBX: ffff880037951f80 RCX: 0000000000000001
> RDX: 0000000000001fa0 RSI: 000000000000000b RDI: ffff880037a8cc00
> RBP: ffffea00006286f8 R08: ffff88003c601920 R09: 0000000000000000
> R10: 00000000ffffffff R11: ffff88001d4895c8 R12: 0000000000000000
> R13: 0000000000000001 R14: ffff88003c601bb0 R15: ffff88003c601d40
> FS:  0000000000000000(0000) GS:ffff880001800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000841210 CR3: 000000003daa5000 CR4: 00000000000006b0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process flush-0:17 (pid: 2098, threadinfo ffff88003c600000, task ffff880037afd230)
> Stack:
> ffff88001d409c50 ffffffff810a7dda ffffffff811ab70b ffff88003c601a58
> <0> 0000000000000286 ffffea00006286f8 ffff88001d409c50 ffffffffffffffff
> <0> ffffea00006286f8 0000000000000000 ffff88003c601ae8 ffffffff811b6d26
> Call Trace:
> [<ffffffff810a7dda>] ? find_get_pages_tag+0x3a/0x110
> [<ffffffff811ab70b>] ? nfs_refresh_inode+0x4b/0x70
> [<ffffffff811b6d26>] ? nfs_writepages_callback+0x16/0x40
> [<ffffffff810af4c1>] ? write_cache_pages+0x1a1/0x370
> [<ffffffff811b6d10>] ? nfs_writepages_callback+0x0/0x40
> [<ffffffff811b6c86>] ? nfs_writepages+0xa6/0x130
> [<ffffffff811b8000>] ? nfs_flush_one+0x0/0xe0
> [<ffffffff811013a9>] ? writeback_single_inode+0xe9/0x400
> [<ffffffff81101b36>] ? writeback_sb_inodes+0x196/0x270
> [<ffffffff810464f0>] ? pvclock_clocksource_read+0x50/0xc0
> [<ffffffff8110245c>] ? writeback_inodes_wb+0x9c/0x1a0
> [<ffffffff8110279b>] ? wb_writeback+0x23b/0x2a0
> [<ffffffff810575ec>] ? finish_task_switch+0x3c/0xc0
> [<ffffffff81102963>] ? wb_do_writeback+0x163/0x170
> [<ffffffff81406e64>] ? schedule_timeout+0x164/0x230
> [<ffffffff811029b7>] ? bdi_writeback_task+0x47/0x150
> [<ffffffff81075484>] ? bit_waitqueue+0x14/0xb0
> [<ffffffff81408765>] ? _raw_spin_lock+0x5/0x10
> [<ffffffff810bbe1e>] ? bdi_start_fn+0x7e/0x100
> [<ffffffff810bbda0>] ? bdi_start_fn+0x0/0x100
> [<ffffffff810750ce>] ? kthread+0x8e/0xa0
> [<ffffffff8102a384>] ? kernel_thread_helper+0x4/0x10
> [<ffffffff81075040>] ? kthread+0x0/0xa0
> [<ffffffff8102a380>] ? kernel_thread_helper+0x0/0x10
> Code: ff ff 48 63 d8 e9 0c ff ff ff 0f 0b eb fe 0f 1f 40 00 48 83 c7 48 31 f6 e8 ad 4b f0 ff e9 69 ff ff ff 48 8b 45 10 e9 36 ff ff ff <0f> 0b eb fe 66 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 68 ba 14
> RIP  [<ffffffff811b66f1>] nfs_do_writepage+0x201/0x210
> RSP <ffff88003c601a10>
> ---[ end trace 9a06d7f037e4429e ]---
> 
> uname -r:
> 
> 2.6.35.3.x86_64.aufs
> --------------------------------------------------------
> 
> It is a VM on qemu-kvm, 2GB RAM, 1 Virtual CPU,
> Root filesystem is a copy-on-write AUFS, changes are written via NFS.

At first blush, it looks like the guest's VM subsystem is asking the NFS client to write back a clean page.  Could be a misbehavior in AUFS?

I confess I'm not familiar with AUFS; 2.6.35 doesn't list anything called AUFS in the File Systems menu, but I could be missing something.

> This machine runs always into this error on startup, after installing Fedora 389 directory server.

I'm a little confused by this.  Do you mean the BUG pops just after "service dirsrv start" during the guest's boot-up sequence?

> We have seen this error also when memory was low, but this VM has plenty memory free.

When memory is low, the VM is more likely to drive writebacks, so that could make this error occur more frequently.  But low memory is not the only reason to drive a writeback.

> top:
> 
> Tasks:  56 total,   1 running,  55 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.4%us,  1.4%sy,  0.0%ni, 96.9%id,  1.0%wa,  0.0%hi,  0.2%si,  0.0%st
> Mem:   2058768k total,   661556k used,  1397212k free,   157792k buffers
> Swap:        0k total,        0k used,        0k free,    87844k cached
> 
>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>    1 root      20   0 19284 1428 1160 S  0.0  0.1   0:00.39 init
>    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
>    3 root      20   0     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd/0
>    4 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0
>    5 root      20   0     0    0    0 S  0.0  0.0   0:00.01 events/0
>    6 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cpuset
>    7 root      20   0     0    0    0 S  0.0  0.0   0:00.01 khelper
>   12 root      20   0     0    0    0 S  0.0  0.0   0:00.00 async/mgr
>  139 root      20   0     0    0    0 S  0.0  0.0   0:00.00 sync_supers
>  141 root      20   0     0    0    0 S  0.0  0.0   0:00.00 bdi-default
>  143 root      20   0     0    0    0 S  0.0  0.0   0:00.09 kblockd/0
>  145 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpid
>  146 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpi_notify
>  147 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpi_hotplug
>  219 root      20   0     0    0    0 S  0.0  0.0   0:00.00 khubd
>  222 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kseriod
>  246 root      20   0     0    0    0 S  0.0  0.0   0:00.19 rpciod/0
>  247 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kvm-irqfd-clean
>  266 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kswapd0
>  267 root      20   0     0    0    0 S  0.0  0.0   0:00.00 aio/0
>  268 root      20   0     0    0    0 S  0.0  0.0   0:00.05 nfsiod
>  270 root      20   0     0    0    0 S  0.0  0.0   0:00.00 aufsd/0
>  271 root      20   0     0    0    0 S  0.0  0.0   0:00.03 aufsd_pre/0
>  272 root      20   0     0    0    0 S  0.0  0.0   0:00.00 crypto/0
>  460 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kpsmoused
>  466 root      20   0     0    0    0 S  0.0  0.0   0:00.00 usbhid_resumer
>  932 root      20   0     0    0    0 S  0.0  0.0   0:00.00 jbd2/vda1-8
>  933 root      20   0     0    0    0 S  0.0  0.0   0:00.00 ext4-dio-unwrit
> 1061 root      16  -4 11004 1056  320 S  0.0  0.1   0:00.02 udevd
> 1837 root      20   0  9084  596  124 S  0.0  0.0   0:00.00 dhclient
> 1966 root      20   0  238m 1420  852 S  0.0  0.1   0:00.04 rsyslogd
> 1995 rpc       20   0 18916  856  612 S  0.0  0.0   0:00.02 rpcbind
> 2025 rpcuser   20   0 23084 1128  844 S  0.0  0.1   0:00.00 rpc.statd
> 2146 root      20   0  185m 3484 1572 S  0.0  0.2   0:00.03 httpd.worker
> 2149 root      20   0  185m 2280  368 S  0.0  0.1   0:00.00 httpd.worker
> 2150 LDAP      20   0  777m 3804 1168 S  0.0  0.2   0:00.00 httpd.worker
> 2227 dbus      20   0 21464  908  624 S  0.0  0.0   0:00.00 dbus-daemon
> 
> --------------------------------------------------------
> 
> cat /proc/mounts:
> 
> rootfs / rootfs rw 0 0
> /proc /proc proc rw,relatime 0 0
> /sys /sys sysfs rw,relatime 0 0
> udev /dev tmpfs rw,relatime,mode=755 0 0
> devpts /dev/pts devpts rw,relatime,gid=5,mode=620 0 0
> tmpfs /dev/shm tmpfs rw,relatime 0 0
> /dev/vda1 /dev/ro ext4 ro,relatime,barrier=1,data=ordered 0 0
> aufs / aufs rw,sync,noatime,si=92ba86936973eb7c 0 0
> 192.168.255.1:/dev/servers /dev/servers nfs rw,sync,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=20,sec=sys,mountaddr=192.168.255.1,mountvers=3,mountport=49222,mountproto=udp,addr=192.168.255.1 0 0
> /proc/bus/usb /proc/bus/usb usbfs rw,relatime 0 0
> none /proc/sys/fs/binfmt_misc binfmt_misc rw,relatime 0 0
> 
> --------------------------------------------------------
> 
> We are ready create VMs for testing.
> If you need more info, please ask.
> 
> Regards
> 
> David Mudrich
> 
> -- 
> Mudrich Systems
> 
> David Mudrich Geschäftsführung / Executive
> Tel/Fax +49 3907 775646
> E-Mail dmudrich@mudrichsystems.com
> Web www.mudrichsystems.com <http://www.mudrichsystems.com>
> Mudrich EDV David und Johannes Mudrich GbR
> Bäckergang 1, 39638 Gardelegen, Germany
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




