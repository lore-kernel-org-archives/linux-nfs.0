Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f179.google.com ([209.85.160.179]:64227 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbbBRU0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Feb 2015 15:26:39 -0500
Received: by mail-yk0-f179.google.com with SMTP id 9so2058402ykp.10
        for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2015 12:26:38 -0800 (PST)
Date: Wed, 18 Feb 2015 15:26:32 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: soft lockup in the laundromat
Message-ID: <20150218152632.5a203b9f@tlielax.poochiereds.net>
In-Reply-To: <alpine.OSX.2.19.9992.1502181132520.80359@planck.local>
References: <alpine.OSX.2.19.9992.1502181132520.80359@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Feb 2015 11:36:06 -0500 (EST)
Benjamin Coddington <bcodding@redhat.com> wrote:

> While playing with callback channel failures, I ran into this on the
> server yesterday:
> 
> [  372.020003] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [kworker/u4:0:6]
> [  372.020003] Modules linked in: cts rpcsec_gss_krb5 nfnetlink_queue nfnetlink_log nfnetlink nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel serio_raw virtio_console virtio_balloon parport_pc pvpanic parport i2c_piix4 nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_net virtio_blk cirrus drm_kms_helper ttm drm virtio_pci virtio_ring virtio ata_generic pata_acpi
> [  372.020003] CPU: 1 PID: 6 Comm: kworker/u4:0 Not tainted 3.17.4-301.fc21.x86_64 #1
> [  372.020003] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
> [  372.020003] Workqueue: nfsd4 laundromat_main [nfsd]
> [  372.020003] task: ffff88007c7bb110 ti: ffff88007c04c000 task.ti: ffff88007c04c000
> [  372.020003] RIP: 0010:[<ffffffff81746162>]  [<ffffffff81746162>] _raw_spin_unlock_irqrestore+0x12/0x20
> [  372.020003] RSP: 0018:ffff88007c04fcd8  EFLAGS: 00000246
> [  372.020003] RAX: ffffffffa01876f0 RBX: 0000000000000000 RCX: 0000000000000000
> [  372.020003] RDX: ffffffffa0187708 RSI: 0000000000000246 RDI: 0000000000000246
> [  372.020003] RBP: ffff88007c04fcd8 R08: 0000000000000000 R09: 0000000000017a40
> [  372.020003] R10: ffffffffa017b4ed R11: 00000000000003a5 R12: ffffffffa01815ba
> [  372.020003] R13: ffff88007c04fc98 R14: ffffffff81f0cc80 R15: 0000000000000000
> [  372.020003] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
> [  372.020003] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  372.020003] CR2: 00007fccadbe03b8 CR3: 000000007b89e000 CR4: 00000000000406e0
> [  372.020003] Stack:
> [  372.020003]  ffff88007c04fd10 ffffffff810d6ac4 ffff88007c04fcf8 ffff88007c04fd38
> [  372.020003]  ffffffffa016f69d ffff88007a21a878 ffff88007a21a888 ffff88007c04fd38
> [  372.020003]  ffffffffa016f69d ffff88007c04fd48 ffff88007a21a800 ffff88007c04fcf8
> [  372.020003] Call Trace:
> [  372.020003]  [<ffffffff810d6ac4>] __wake_up+0x44/0x50
> [  372.020003]  [<ffffffffa016f69d>] ? nfs4_put_stid+0xcd/0xe0 [nfsd]
> [  372.020003]  [<ffffffffa016f69d>] nfs4_put_stid+0xcd/0xe0 [nfsd]
> [  372.020003]  [<ffffffffa016f93f>] __destroy_client+0xdf/0x160 [nfsd]
> [  372.020003]  [<ffffffffa016f9e2>] expire_client+0x22/0x30 [nfsd]
> [  372.020003]  [<ffffffffa016fd9e>] laundromat_main+0x18e/0x4d0 [nfsd]
> [  372.020003]  [<ffffffff810af88d>] process_one_work+0x14d/0x400
> [  372.020003]  [<ffffffff810b021b>] worker_thread+0x6b/0x4a0
> [  372.020003]  [<ffffffff810b01b0>] ? rescuer_thread+0x2a0/0x2a0
> [  372.020003]  [<ffffffff810b52fa>] kthread+0xea/0x100
> [  372.020003]  [<ffffffff810b5210>] ? kthread_create_on_node+0x1a0/0x1a0
> [  372.020003]  [<ffffffff81746a3c>] ret_from_fork+0x7c/0xb0
> [  372.020003]  [<ffffffff810b5210>] ? kthread_create_on_node+0x1a0/0x1a0
> [  372.020003] Code: c3 66 41 83 47 08 01 fb 66 66 90 66 66 90 eb ca 31 c0 eb ce e8 40 0d 95 ff 66 66 66 66 90 55 48 89 e5 66 83 07 01 48 89 f7 57 9d <66> 66 90 66 90 5d c3 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48
> 

Do all of the stack traces have the RIP in the same spot? If so then it
may be that the close_wq is corrupt or something. I wouldn't expect
that waitqueue to be highly contended.

> 
> I'll see if I can reproduce on 3.18..
> 

Yeah, that'd be good.
-- 
Jeff Layton <jlayton@poochiereds.net>
