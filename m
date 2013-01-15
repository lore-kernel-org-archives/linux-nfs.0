Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab3AOUL7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 15:11:59 -0500
Date: Tue, 15 Jan 2013 15:11:56 -0500
To: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
Cc: linux-nfs@vger.kernel.org, baggins@pld-linux.org
Subject: Re: [3.7.1] kernel BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130115201156.GG4940@fieldses.org>
References: <2756629.oPBWvActBb@pawels>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <2756629.oPBWvActBb@pawels>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2013 at 11:02:34AM +0100, Paweł Sikora wrote:
> Hi all,
> 
> on one nfs-client i've noticed following bug in dmesg:
> is it a known bug?

Looks to be the same reported here:

	http://article.gmane.org/gmane.linux.kernel/1421589/match=net+sunrpc+svc_xprt+c+921

What was the last working kernel for you?

--b.

> 
> BR,
> Paweł.
> 
> [602552.165960] ------------[ cut here ]------------
> [602552.166037] kernel BUG at /home/users/pawels/rpm/BUILD/kernel-3.7.1/linux-3.7/net/sunrpc/svc_xprt.c:921!
> [602552.166123] invalid opcode: 0000 [#1] SMP 
> [602552.166293] Modules linked in: nfsv3 nfsv4 nfs dns_resolver fscache fuse nfsd auth_rpcgss nfs_acl lockd sunrpc ipmi_si ipmi_devintf ipmi_msghandler sch_sfq xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter xt_TCPMSS xt_tcpudp iptable_mangle ip_tables ip6table_filter ip6_tables x_tables quota_v2 quota_tree ext4 crc16 jbd2 raid10 raid0 dm_mod autofs4 dummy ide_cd_mod cdrom ata_generic pata_acpi pata_atiixp sp5100_tco ide_pci_generic kvm_amd kvm igb ptp microcode joydev pps_core i2c_piix4 i2c_core dca evdev hid_generic k10temp atiixp pcspkr ide_core hwmon amd64_edac_mod edac_core edac_mce_amd processor button ext3 mbcache jbd sd_mod crc_t10dif raid1 md_mod ahci libahci libata scsi_mod usbhid hid ohci_hcd ehci_hcd usbcore usb_common
> [602552.171338] CPU 1 
> [602552.171401] Pid: 13394, xid: #0, comm: nfsv4.0-svc Not tainted 3.7.1-2 #1 Supermicro H8DGU/H8DGU
> [602552.171613] RIP: 0010:[<ffffffffa03e1b62>]  [<ffffffffa03e1b62>] svc_delete_xprt+0x122/0x140 [sunrpc]
> [602552.171824] RSP: 0018:ffff8806d4cd7e28  EFLAGS: 00010286
> [602552.171920] RAX: 00000000ffffffff RBX: ffff880134d1a000 RCX: 0000000000000000
> [602552.172046] RDX: ffff88029c513a18 RSI: 7fffffffffffffff RDI: ffff880134d1a000
> [602552.172173] RBP: ffff8806d4cd7e48 R08: 0000000000000000 R09: 0000000000000000
> [602552.172299] R10: 000000000000175f R11: ffffffff8107cae4 R12: ffff8801d63b2f00
> [602552.172426] R13: ffff8801d63b2f00 R14: 0000000000000000 R15: ffff8801d63b2f00
> [602552.172553] FS:  00007f7f4faf97c0(0000) GS:ffff880313c40000(0000) knlGS:00000000f750e6c0
> [602552.172683] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [602552.172780] CR2: 00007f9c33133998 CR3: 0000000707ef5000 CR4: 00000000000007e0
> [602552.172906] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [602552.173034] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [602552.173161] Process nfsv4.0-svc (pid: 13394, threadinfo ffff8806d4cd6000, task ffff8807066286f0)
> [602552.173292] Stack:
> [602552.173412]  7fffffffffffffff ffff88030cc92000 ffff880134d1a000 ffff8801d63b2f00
> [602552.173767]  ffff8806d4cd7e98 ffffffffa03e2dc1 ffff880371cbc560 010000004e4ff850
> [602552.174122]  ffff88024e4ff848 ffff88030cc92000 ffff88030cc92000 ffffffffa04e2960
> [602552.174490] Call Trace:
> [602552.174588]  [<ffffffffa03e2dc1>] svc_recv+0x101/0x580 [sunrpc]
> [602552.174695]  [<ffffffffa04e2960>] ? nfs_callback_authenticate+0x30/0x30 [nfsv4]
> [602552.174828]  [<ffffffffa04e2993>] nfs4_callback_svc+0x33/0x60 [nfsv4]
> [602552.174930]  [<ffffffff8107496b>] kthread+0xbb/0xc0
> [602552.175026]  [<ffffffff81010000>] ? ftrace_raw_event_xen_mc__batch+0xb0/0xb0
> [602552.175130]  [<ffffffff810748b0>] ? kthread_freezable_should_stop+0x70/0x70
> [602552.175233]  [<ffffffff814e817c>] ret_from_fork+0x7c/0xb0
> [602552.175330]  [<ffffffff810748b0>] ? kthread_freezable_should_stop+0x70/0x70
> [602552.175431] Code: 89 30 48 89 c7 ff 50 10 48 8b 83 68 02 00 00 49 39 c4 75 c5 80 43 70 01 48 89 df e8 b9 fe ff ff 48 83 c4 08 5b 41 5c 41 5d 5d c3 <0f> 0b 0f 0b 48 89 fe 31 c0 48 c7 c7 0f 80 3e a0 e8 00 5e 0f e1 
> [602552.179073] RIP  [<ffffffffa03e1b62>] svc_delete_xprt+0x122/0x140 [sunrpc]
> [602552.179237]  RSP <ffff8806d4cd7e28>
> [602552.179355] ---[ end trace d712e98086b82c74 ]---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
