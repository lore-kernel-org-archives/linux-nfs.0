Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:36751 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168AbcANUNJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2016 15:13:09 -0500
Received: from bender.morinfr.org (unknown [81.57.171.53])
	by smtp4-g21.free.fr (Postfix) with ESMTPS id 986D84C8059
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jan 2016 21:11:58 +0100 (CET)
Received: from guillaum by bender.morinfr.org with local (Exim 4.84)
	(envelope-from <guillaume@morinfr.org>)
	id 1aJoGY-0006Nn-HD
	for linux-nfs@vger.kernel.org; Thu, 14 Jan 2016 21:13:06 +0100
Date: Thu, 14 Jan 2016 21:13:06 +0100
From: Guillaume Morin <guillaume@morinfr.org>
To: linux-nfs@vger.kernel.org
Subject: 4.1.13: nfs_have_writebacks(inode) warning triggered in
 nfs_clear_inode
Message-ID: <20160114201306.GA22752@bender.morinfr.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a machine running 4.1.13 where this warning triggered.  Before
you ask, I have a few machines running that kernel with the same nfs
mounts and roughly the same workload and it happened only this one time.
So I am guessing it will be hard to reproduce

[949229.574284] ------------[ cut here ]------------
[949229.574306] WARNING: CPU: 11 PID: 100 at fs/nfs/inode.c:121 nfs_clear_inode+0x6a/0xa0 [nfs]()
[949229.574319] Modules linked in: tcp_diag inet_diag nfnetlink_queue nfnetlink_log nfnetlink nfsd nfsv3 nfs_acl rpcsec_gss_krb5 auth_rpcgss oid_registry nfsv4 nfs lockd grace sunrpc fscache rdma_ucm rdma_cm iw_cm ib_uverbs ib_cm ib_sa ib_mad ib_core ib_addr hhostname(O) ipmi_watchdog binfmt_misc gpio_ich serio_raw pcspkr coretemp i2c_i801 lpc_ich ioatdma mfd_core dca i5500_temp ipmi_si ipmi_poweroff ipmi_devintf ipv6 autofs4 sr_mod cdrom sg usbhid crc32c_intel uhci_hcd ehci_pci ehci_hcd ahci libahci usbcore usb_common
[949229.574356] CPU: 11 PID: 100 Comm: kswapd0 Tainted: G           O    4.1.13 #1
[949229.574357] Hardware name: Supermicro X8DTU/X8DTU, BIOS 2.1a       09/21/11  
[949229.574358]  ffffffffa0e92623 ffff880630093af8 ffffffff81591e69 0000000000000007
[949229.574361]  0000000000000000 ffff880630093b38 ffffffff8105925a 000000214190340a
[949229.574363]  ffff88012aef4ac8 ffff88012aef4bc8 ffffffffa0e90b80 ffff880630093cf8
[949229.574365] Call Trace:
[949229.574371]  [<ffffffff81591e69>] dump_stack+0x45/0x57
[949229.574375]  [<ffffffff8105925a>] warn_slowpath_common+0x8a/0xc0
[949229.574377]  [<ffffffff8105934a>] warn_slowpath_null+0x1a/0x20
[949229.574384]  [<ffffffffa0e7a4ea>] nfs_clear_inode+0x6a/0xa0 [nfs]
[949229.574392]  [<ffffffffa0e7c8ad>] nfs_evict_inode+0x2d/0x40 [nfs]
[949229.574395]  [<ffffffff8119b2e3>] evict+0xb3/0x1a0
[949229.574397]  [<ffffffff8119b411>] dispose_list+0x41/0x50
[949229.574399]  [<ffffffff8119c3eb>] prune_icache_sb+0x4b/0x60
[949229.574402]  [<ffffffff811833af>] super_cache_scan+0x15f/0x1b0
[949229.574406]  [<ffffffff8113ac59>] shrink_slab.part.56.constprop.68+0x1b9/0x340
[949229.574409]  [<ffffffff8113e0e5>] shrink_zone+0x155/0x190
[949229.574410]  [<ffffffff8113ecd0>] kswapd+0x510/0x980
[949229.574413]  [<ffffffff8113e7c0>] ? zone_reclaim+0x220/0x220
[949229.574417]  [<ffffffff81075f0b>] kthread+0xdb/0x100
[949229.574419]  [<ffffffff81075e30>] ? kthread_create_on_node+0x180/0x180
[949229.574422]  [<ffffffff81598412>] ret_from_fork+0x42/0x70
[949229.574424]  [<ffffffff81075e30>] ? kthread_create_on_node+0x180/0x180
[949229.574426] ---[ end trace 119ebcc8a1a978af ]---

-- 
Guillaume Morin <guillaume@morinfr.org>
