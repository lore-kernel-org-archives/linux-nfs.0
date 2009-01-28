From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Linux 2.6.27.13
Date: Wed, 28 Jan 2009 13:58:06 +0100
Message-ID: <4980565E.3000800@krogh.cc>
References: <20090125004823.GA6711@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	linux-nfs@vger.kernel.org, autofs@linux.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753902AbZA1M6e@vger.kernel.org>
In-Reply-To: <20090125004823.GA6711@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg KH wrote:
> We (the -stable team) are announcing the release of the 2.6.27.13
> kernel.
> 
> It contains a wide range of bugfixes, and all users of the 2.6.27 kernel
> series are strongly encouraged to upgrade.
> 
> I'll also be replying to this message with a copy of the patch between
> 2.6.27.12 and 2.6.27.13

Still on a 2.6.27.6  I got this on an NFS client while restarting the 
NFS-server at the other end. Seems autofs/nfs releated.


[6367172.212954] ------------[ cut here ]------------
[6367172.213122] kernel BUG at net/sunrpc/rpcb_clnt.c:498!
[6367172.213263] invalid opcode: 0000 [1] SMP
[6367172.213397] CPU 1
[6367172.213502] Modules linked in: nfs lockd sunrpc autofs4 ipv6 
iptable_filter ip_tables x_tables usbhid hid uhci_hcd ehci_hcd usbkbd 
parport_pc lp parport af_packet i2c_amd756 i2c_core container amd_rng 
serio_raw button k8temp shpchp pci_hotplug evdev pcspkr psmouse ext3 jbd 
mbcache sg sd_mod ide_cd_mod cdrom ata_generic libata dock floppy mptspi 
mptscsih mptbase scsi_transport_spi scsi_mod tg3 libphy amd74xx ide_core 
ohci_hcd usbcore thermal processor fan thermal_sys fuse
[6367172.214628] Pid: 5802, comm: automount Not tainted 2.6.27.6 #2
[6367172.214778] RIP: 0010:[<ffffffffa02c5288>]  [<ffffffffa02c5288>] 
rpcb_getport_async+0x318/0x440 [sunrpc]
[6367172.215082] RSP: 0018:ffff880037a3bb48  EFLAGS: 00010287
[6367172.215226] RAX: ffffffffa02e2da0 RBX: ffff8800fade5200 RCX: 
00000000c0000100
[6367172.215467] RDX: 0000000000000001 RSI: ffff880037a3bc18 RDI: 
ffff8800f659ba00
[6367172.215708] RBP: ffff8800faf30000 R08: ffff880037a3a000 R09: 
000823d4ebf72992
[6367172.215948] R10: ffff8800ba8f3928 R11: ffffffffa02c4f70 R12: 
ffff8800f6672200
[6367172.216189] R13: ffff8800f659ba00 R14: ffff8800d54d0c00 R15: 
ffff8800d54d0b70
[6367172.216430] FS:  00007f95a76396e0(0000) GS:ffff8800fbb0e280(0000) 
knlGS:00000000556f68c0
[6367172.216681] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[6367172.216681] CR2: 00007f93cfcb3768 CR3: 0000000028fbb000 CR4: 
00000000000006e0
[6367172.216681] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[6367172.216681] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[6367172.216681] Process automount (pid: 5802, threadinfo 
ffff880037a3a000, task ffff8800bab7c440)
[6367172.216681] Stack:  ffff8800bab7c680 000000015edfa7ae 
0000000300000000 ffff8800f61093c8
[6367172.216681]  0000000000000000 0000000000000296 0000000000000282 
ffff880037a3bc08
[6367172.216681]  ffff880037a3bc18 0000000000000082 ffff8800c1002ee0 
ffffffffa02bc750
[6367172.216681] Call Trace:
[6367172.216681]  [<ffffffffa02bc750>] ? rpc_wait_bit_killable+0x0/0x40 
[sunrpc]
[6367172.216681]  [<ffffffff80459e1b>] ? __wait_on_bit+0x6b/0x80
[6367172.216681]  [<ffffffffa02bc750>] ? rpc_wait_bit_killable+0x0/0x40 
[sunrpc]
[6367172.216681]  [<ffffffff80459eaa>] ? out_of_line_wait_on_bit+0x7a/0xa0
[6367172.216681]  [<ffffffff8024c9f0>] ? wake_bit_function+0x0/0x30
[6367172.216681]  [<ffffffffa02bcd83>] ? __rpc_execute+0x63/0x270 [sunrpc]
[6367172.216681]  [<ffffffffa02b5c84>] ? rpc_run_task+0x34/0x70 [sunrpc]
[6367172.216681]  [<ffffffffa02b5d5c>] ? rpc_call_sync+0x3c/0x60 [sunrpc]
[6367172.216681]  [<ffffffffa0314e8a>] ? nfs3_rpc_wrapper+0x3a/0x60 [nfs]
[6367172.216681]  [<ffffffffa0315631>] ? nfs3_proc_getattr+0x51/0x90 [nfs]
[6367172.216681]  [<ffffffffa0307635>] ? 
__nfs_revalidate_inode+0x175/0x2a0 [nfs]
[6367172.216681]  [<ffffffff802a9f13>] ? path_walk+0x63/0xb0
[6367172.216681]  [<ffffffff802aa02a>] ? do_path_lookup+0x7a/0x160
[6367172.216681]  [<ffffffff802a8eb5>] ? getname+0xe5/0x1f0
[6367172.216681]  [<ffffffff802aac85>] ? user_path_at+0x55/0x80
[6367172.216681]  [<ffffffff8027f1b2>] ? do_wp_page+0x262/0x550
[6367172.216681]  [<ffffffff802a2915>] ? cp_new_stat+0xe5/0x100
[6367172.216681]  [<ffffffffa03080da>] ? nfs_getattr+0x7a/0x120 [nfs]
[6367172.216681]  [<ffffffff802a2c47>] ? vfs_lstat_fd+0x37/0x60
[6367172.216681]  [<ffffffff802a2c97>] ? sys_newlstat+0x27/0x50
[6367172.216681]  [<ffffffff8020c2db>] ? system_call_fastpath+0x16/0x1b
[6367172.216681]
[6367172.216681]
[6367172.216681] Code: ff ff ff 0f 84 7f fd ff ff 41 0f b7 b5 06 01 00 
00 48 c7 c2 b0 cc 2c a0 48 c7 c7 88 03 2d a0 31 c0 e8 8d 38 f7 df e9 5d 
fd ff ff <0f> 0b eb fe 0f 1f 40 00 8b 85 a0 00 00 00 0f b7 b7 06 01 00 00
[6367172.216681] RIP  [<ffffffffa02c5288>] 
rpcb_getport_async+0x318/0x440 [sunrpc]
[6367172.216681]  RSP <ffff880037a3bb48>
[6367172.223900] ---[ end trace 5edd17395c2b1b4f ]---


Full dmesg here:
http://krogh.cc/~jesper/dmesg-autofs-nfs.txt
