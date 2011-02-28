Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55599 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190Ab1B1RBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Feb 2011 12:01:21 -0500
Date: Mon, 28 Feb 2011 12:01:20 -0500
To: Andre Rodier <andre.rodier@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: kernel NFS bug
Message-ID: <20110228170120.GA13028@fieldses.org>
References: <4D695031.9050001@gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4D695031.9050001@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Feb 26, 2011 at 07:10:41PM +0000, Andre Rodier wrote:
> Hello guys,
> 
> *After typing this command,*
> 
> echo 1023>/proc/sys/sunrpc/nfs_debug ; mount /home/samba/profiles/
> 
> *I had this error:*
> 
> Feb 26 16:03:33 titan kernel: [1121430.975412] -->  nfs4_create_server()
> Feb 26 16:03:33 titan kernel: [1121430.975422] -->  nfs4_init_server()
> Feb 26 16:03:33 titan kernel: [1121430.975424] -->  nfs4_set_client()
> Feb 26 16:03:33 titan kernel: [1121430.975427] -->  nfs_get_client(ananke,v4)
> Feb 26 16:03:33 titan kernel: [1121430.975436] -->  nfs_get_client() = ffff88001d9bf800 [new]
> Feb 26 16:03:33 titan kernel: [1121430.988571] ------------[ cut here ]------------
> Feb 26 16:03:33 titan kernel: [1121430.988571] kernel BUG at /build/buildd-linux-2.6_2.6.32-30-amd64-d4MbNM/linux-2.6-2.6.32/debian/build/source_amd64_none/net/sunrpc/rpc_pipe.c:462!

Is that reproduceable with a more recent kernel?

Cc'ing linux-nfs.

--b.

> Feb 26 16:03:33 titan kernel: [1121430.988571] invalid opcode: 0000 [#1] SMP
> Feb 26 16:03:33 titan kernel: [1121430.988571] last sysfs file: /sys/module/rpcsec_gss_krb5/initstate
> Feb 26 16:03:33 titan kernel: [1121430.988571] CPU 0
> Feb 26 16:03:33 titan kernel: [1121430.988571] Modules linked in: nfsd exportfs rpcsec_gss_krb5 nfs lockd fscache nfs_acl auth_rpcgss sunrpc tun xt_multiport ipt_REJECT xt_limit xt_tcpudp ipt_addrtype xt_state ip6table_filter ip6_tables nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables loop joydev snd_pcm snd_timer usbhid hid snd i2c_piix4 soundcore snd_page_alloc psmouse evdev serio_raw pcspkr i2c_core processor button ext3 jbd mbcache sg sr_mod cdrom ata_generic ata_piix uhci_hcd ehci_hcd virtio_net virtio_blk thermal libata floppy thermal_sys virtio_pci virtio_ring virtio usbcore nls_base scsi_mod [last unloaded: scsi_wait_scan]
> Feb 26 16:03:33 titan kernel: [1121430.988571] Pid: 28867, comm: mount.nfs4 Not tainted 2.6.32-5-amd64 #1 Bochs
> Feb 26 16:03:33 titan kernel: [1121430.988571] RIP: 0010:[<ffffffffa03143ed>]  [<ffffffffa03143ed>] __rpc_create_common+0x1a/0xb0 [sunrpc]
> Feb 26 16:03:33 titan kernel: [1121430.988571] RSP: 0018:ffff8800180178e8  EFLAGS: 00010246
> Feb 26 16:03:33 titan kernel: [1121430.988571] RAX: 0000000000000000 RBX: 0000000000001180 RCX: ffffffffa03186a0
> Feb 26 16:03:33 titan kernel: [1121430.988571] RDX: 0000000000001180 RSI: ffff8800051a46c0 RDI: ffff88001ee2a700
> Feb 26 16:03:33 titan kernel: [1121430.988571] RBP: ffff8800051a46c0 R08: ffff880017d4f800 R09: ffff880001815780
> Feb 26 16:03:33 titan kernel: [1121430.988571] R10: ffff8800180c72d8 R11: ffff88001f1e4700 R12: ffff88001ee2a700
> Feb 26 16:03:33 titan kernel: [1121430.988571] R13: ffffffffa03186a0 R14: ffff880017d4f800 R15: ffff880017d4f800
> Feb 26 16:03:33 titan kernel: [1121430.988571] FS:  00007f2f08c93700(0000) GS:ffff880001800000(0000) knlGS:0000000000000000
> Feb 26 16:03:33 titan kernel: [1121430.988571] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Feb 26 16:03:33 titan kernel: [1121430.988571] CR2: 0000000000687000 CR3: 0000000017ce7000 CR4: 00000000000006f0
> Feb 26 16:03:33 titan kernel: [1121430.988571] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Feb 26 16:03:33 titan kernel: [1121430.988571] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Feb 26 16:03:33 titan kernel: [1121430.988571] Process mount.nfs4 (pid: 28867, threadinfo ffff880018016000, task ffff88001d8ae350)
> Feb 26 16:03:33 titan kernel: [1121430.988571] Stack:
> Feb 26 16:03:33 titan kernel: [1121430.988571]  0000000000001180 ffff8800051a46c0 ffffffffa03cf756 ffffffffa03440d0
> Feb 26 16:03:33 titan kernel: [1121430.988571]<0>  ffff88001ee2a700 ffffffffa0314600 ffff880017d4f800 000000018104a7f3
> Feb 26 16:03:33 titan kernel: [1121430.988571]<0>  ffff88000f8d5a80 ffff88001ee2a7b8 0000000401a80b22 ffffffffa03cf756
> Feb 26 16:03:33 titan kernel: [1121430.988571] Call Trace:
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0314600>] ? rpc_mkpipe+0x111/0x192 [sunrpc]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0341799>] ? gss_create+0x1d4/0x234 [auth_rpcgss]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa030a81d>] ? rpcauth_create+0xe5/0x130 [sunrpc]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0303f66>] ? rpc_create+0x362/0x4f0 [sunrpc]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff812f9e2c>] ? printk+0x4e/0x5a
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa037fc22>] ? nfs_create_rpc_client+0x9d/0xe3 [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0380228>] ? nfs4_set_client+0xc6/0x21a [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0380a83>] ? nfs4_create_server+0xe0/0x312 [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810eb84e>] ? pcpu_alloc_area+0x25b/0x2a7
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff811948b6>] ? vsnprintf+0x9e/0x449
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810eadaa>] ? pcpu_next_pop+0x3d/0x4a
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810e4493>] ? get_partial_node+0x15/0x85
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810e6870>] ? __slab_alloc+0xd3/0x39b
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa03894d7>] ? nfs4_remote_get_sb+0x39/0x1ae [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810e7cad>] ? __kmalloc+0x12f/0x141
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa038951b>] ? nfs4_remote_get_sb+0x7d/0x1ae [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810f0a2b>] ? vfs_kern_mount+0x99/0x14b
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0389851>] ? nfs_do_root_mount+0x72/0x8c [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0389a95>] ? nfs4_try_mount+0x55/0xae [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffffa0389d5a>] ? nfs4_get_sb+0x26c/0x2ee [nfs]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810f0a2b>] ? vfs_kern_mount+0x99/0x14b
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff810f0b30>] ? do_kern_mount+0x43/0xe2
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff81104c03>] ? do_mount+0x72a/0x792
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff81103001>] ? copy_mount_options+0xca/0x12b
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff81104ceb>] ? sys_mount+0x80/0xbd
> Feb 26 16:03:33 titan kernel: [1121430.988571]  [<ffffffff81010b42>] ? system_call_fastpath+0x16/0x1b
> Feb 26 16:03:33 titan kernel: [1121430.988571] Code: 89 c7 e8 43 a6 de e0 48 c7 c0 ef ff ff ff 41 59 c3 41 56 4d 89 c6 41 55 49 89 cd 41 54 49 89 fc 55 48 89 f5 53 f6 46 04 10 75 04<0f>  0b eb fe 48 8b bf 08 01 00 00 0f b7 f2 e8 0a fe ff ff 48 85
> Feb 26 16:03:33 titan kernel: [1121430.988571] RIP  [<ffffffffa03143ed>] __rpc_create_common+0x1a/0xb0 [sunrpc]
> Feb 26 16:03:33 titan kernel: [1121430.988571]  RSP<ffff8800180178e8>
> Feb 26 16:03:33 titan kernel: [1121431.224151] ---[ end trace 06c24dd64155af13 ]---
> Feb 26 16:04:05 titan kernel: [1121463.047413] NFS: nfs mount opts='sec=krb5,hard,addr=10.10.2.8,clientaddr=10.10.2.10'
> Feb 26 16:04:05 titan kernel: [1121463.048909] NFS:   parsing nfs mount option 'sec=krb5'
> Feb 26 16:04:05 titan kernel: [1121463.049562] NFS: parsing sec=krb5 option
> Feb 26 16:04:05 titan kernel: [1121463.050115] NFS:   parsing nfs mount option 'hard'
> Feb 26 16:04:05 titan kernel: [1121463.050707] NFS:   parsing nfs mount option 'addr=10.10.2.8'
> Feb 26 16:04:05 titan kernel: [1121463.051431] NFS:   parsing nfs mount option 'clientaddr=10.10.2.10'
> Feb 26 16:04:05 titan kernel: [1121463.052634] NFS: MNTPATH: '/home/samba/profiles'
> Feb 26 16:04:05 titan kernel: [1121463.053255] -->  nfs4_try_mount()
> Feb 26 16:04:19 titan kernel: [1121476.616103]<-- nfs4_try_mount() = -512 [error]
> 
> 
> Sorry to have not enough time to send more info, but I hope that's help.
> 
> André Rodier
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
