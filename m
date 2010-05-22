From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Possible NFS bug in 2.6.34...
Date: Sat, 22 May 2010 12:09:40 -0400
Message-ID: <1274544580.4860.73.camel@heimdal.trondhjem.org>
References: <4BF72D34.60701@actusa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Stuart Sheldon <stu-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39944 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753508Ab0EVQJp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 May 2010 12:09:45 -0400
In-Reply-To: <4BF72D34.60701-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-05-21 at 18:02 -0700, Stuart Sheldon wrote: 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA256
> 
> Hi all,
> 
> Got the following on a 64bit intel NFS client while a process was
> running heavy read and writes to a large (40G) file on a 64bit Intel NFS
> server. Both client and server were running 2.6.34 from kernel.org.
> 
> Basically, the client never recovered, and had to be power cycled to
> correct the issue.
> 
> Here is the mount info:
> 
> drbd:/data/export on /home type nfs
> (rw,rsize=32768,wsize=32768,nfsvers=3,bg,intr,addr=xxx.xx.xx.xxx)
> 
> Here's the log:
> 
> May 21 16:50:55 tovirtcore1 kernel: BUG: soft lockup - CPU#3 stuck for
> 61s! [qemu-system-x86:6340]
> May 21 16:50:55 tovirtcore1 kernel: Modules linked in: tun nfs lockd
> nfs_acl auth_rpcgss sunrpc 8021q bridge stp kvm_intel kvm parport_pc
> i2c_i801 rtc_cmos rtc_core rtc_lib parport psmouse i2c_core evdev
> serio_raw button processor intel_agp pcspkr ext3 jbd mbcache dm_mirror
> dm_region_hash dm_log dm_snapshot dm_mod raid1 md_mod sd_mod
> ide_pci_generic ide_core ata_generic pata_marvell ata_piix ohci1394
> ieee1394 uhci_hcd ehci_hcd pata_acpi firewire_ohci firewire_core
> crc_itu_t libata e1000 scsi_mod e1000e usbcore thermal [last unloaded:
> scsi_wait_scan]
> May 21 16:50:55 tovirtcore1 kernel: CPU 3
> May 21 16:50:55 tovirtcore1 kernel: Modules linked in: tun nfs lockd
> nfs_acl auth_rpcgss sunrpc 8021q bridge stp kvm_intel kvm parport_pc
> i2c_i801 rtc_cmos rtc_core rtc_lib parport psmouse i2c_core evdev
> serio_raw button processor intel_agp pcspkr ext3 jbd mbcache dm_mirror
> dm_region_hash dm_log dm_snapshot dm_mod raid1 md_mod sd_mod
> ide_pci_generic ide_core ata_generic pata_marvell ata_piix ohci1394
> ieee1394 uhci_hcd ehci_hcd pata_acpi firewire_ohci firewire_core
> crc_itu_t libata e1000 scsi_mod e1000e usbcore thermal [last unloaded:
> scsi_wait_scan]
> May 21 16:50:55 tovirtcore1 kernel:
> May 21 16:50:55 tovirtcore1 kernel: Pid: 6340, comm: qemu-system-x86 Not
> tainted 2.6.34-0-xeon-actusa #1 DQ965GF/
> May 21 16:50:55 tovirtcore1 kernel: RIP: 0010:[<ffffffff8107005a>]
> [<ffffffff8107005a>] clear_page_dirty_for_io+0xb2/0xb8
> May 21 16:50:55 tovirtcore1 kernel: RSP: 0000:ffff8801ecf0fc38  EFLAGS:
> 00000246
> May 21 16:50:55 tovirtcore1 kernel: RAX: 0000000000000000 RBX:
> ffff880227586eb0 RCX: 0000000000000000
> May 21 16:50:55 tovirtcore1 kernel: RDX: 0000000000000000 RSI:
> ffff880227586fa8 RDI: ffffea00059c5700
> May 21 16:50:55 tovirtcore1 kernel: RBP: ffffffff8100314e R08:
> 8000000000000000 R09: 0000000000000000
> May 21 16:50:55 tovirtcore1 kernel: R10: ffff8801ecf0fb48 R11:
> ffff8801ecf0fbc0 R12: 0000000000000010
> May 21 16:50:55 tovirtcore1 kernel: R13: ffffffff81041afb R14:
> ffffffffffffff10 R15: 0e00000000000000
> May 21 16:50:55 tovirtcore1 kernel: FS:  000000004469f950(0063)
> GS:ffff880001780000(0000) knlGS:0000000000000000
> May 21 16:50:55 tovirtcore1 kernel: CS:  0010 DS: 002b ES: 002b CR0:
> 000000008005003b
> May 21 16:50:55 tovirtcore1 kernel: CR2: 00000000006cd3d8 CR3:
> 000000022aff3000 CR4: 00000000000026e0
> May 21 16:50:55 tovirtcore1 kernel: DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> May 21 16:50:55 tovirtcore1 kernel: DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> May 21 16:50:55 tovirtcore1 kernel: Process qemu-system-x86 (pid: 6340,
> threadinfo ffff8801ecf0e000, task ffff88022bddc090)
> May 21 16:50:55 tovirtcore1 kernel: Stack:
> May 21 16:50:55 tovirtcore1 kernel: 0000000000000000 ffffea00059c5700
> ffffea00059c5700 ffffffffa02e7bcd
> May 21 16:50:55 tovirtcore1 kernel: <0> 0000000000000000
> 0000000000000000 0000000000000001 0000000000000000
> May 21 16:50:55 tovirtcore1 kernel: <0> 0000000000000000
> 0000000000000000 0000000000000000 00000002cfb52000
> May 21 16:50:55 tovirtcore1 kernel: Call Trace:
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02e7bcd>] ?
> nfs_wb_page+0x57/0x8c [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81072025>] ?
> invalidate_inode_pages2_range+0x140/0x25c
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8102b4c7>] ?
> default_wake_function+0x0/0x9
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02ddbc6>] ?
> nfs_revalidate_mapping+0x66/0xf3 [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02dc40f>] ?
> nfs_file_read+0x92/0xd5 [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8109203b>] ?
> do_sync_read+0xb0/0xf2
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103aa24>] ?
> __send_signal+0x1cd/0x1ea
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103acf2>] ?
> kill_pid_info+0x31/0x3b
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103ae9a>] ?
> sys_kill+0x72/0x140
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81092a38>] ?
> vfs_read+0xaa/0x146
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81092b2b>] ?
> sys_pread64+0x57/0x77
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8100286b>] ?
> system_call_fastpath+0x16/0x1b
> May 21 16:50:55 tovirtcore1 kernel: Code: 60 48 83 ce ff 0f bd 15 c5 e8
> 2f 00 0f 44 d0 8d 14 d5 08 00 00 00 e8 56 be 0b 00 53 9d ba 01 00 00 00
> eb 07 f0 0f ba 33 04 19 d2 <5e> 89 d0 5b 5d c3 55 48 89 fd 53 48 83 ec
> 08 f0 0f ba 2f 00 19
> May 21 16:50:55 tovirtcore1 kernel: Call Trace:
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02e7bcd>] ?
> nfs_wb_page+0x57/0x8c [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81072025>] ?
> invalidate_inode_pages2_range+0x140/0x25c
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8102b4c7>] ?
> default_wake_function+0x0/0x9
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02ddbc6>] ?
> nfs_revalidate_mapping+0x66/0xf3 [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffffa02dc40f>] ?
> nfs_file_read+0x92/0xd5 [nfs]
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8109203b>] ?
> do_sync_read+0xb0/0xf2
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103aa24>] ?
> __send_signal+0x1cd/0x1ea
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103acf2>] ?
> kill_pid_info+0x31/0x3b
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8103ae9a>] ?
> sys_kill+0x72/0x140
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81092a38>] ?
> vfs_read+0xaa/0x146
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff81092b2b>] ?
> sys_pread64+0x57/0x77
> May 21 16:50:55 tovirtcore1 kernel: [<ffffffff8100286b>] ?
> system_call_fastpath+0x16/0x1b
> 
> If you need any additional info, let me know

Do you see any more NFS traffic to the server when the above hang
occurs? I'm wondering if we don't need something like the following
patch.

Cheers
  Trond 
--------------------------------------------------------------------------------
