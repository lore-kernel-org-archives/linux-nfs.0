Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab3KLOzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 09:55:49 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rACEtmt4029131
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 09:55:48 -0500
Received: from tlielax.poochiereds.net (vpn-57-82.rdu2.redhat.com [10.10.57.82])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id rACEtm7q007508
	for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 09:55:48 -0500
Date: Tue, 12 Nov 2013 09:55:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: reproducible stack corruption in nfs mount codepath
Message-ID: <20131112095547.283a1b8b@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While testing the patches that add the new infrastructure to test
whether gssd is running, I found a way to apparently reliably reproduce
some stack corruption:

[ 7535.626147] RPC: AUTH_GSS upcall timed out.
[ 7535.626147] Please check user daemon is running.
[ 7535.643063] BUG: unable to handle kernel paging request at 000000037fea6be0
[ 7535.644041] IP: [<ffffffff810aca07>] cpuacct_charge+0x27/0x40
[ 7535.644041] PGD 0 
[ 7535.644041] Thread overran stack, or stack corrupted
[ 7535.644041] Oops: 0000 [#1] SMP 
[ 7535.644041] Modules linked in: cts rpcsec_gss_krb5(OF) nfsv4 dns_resolver nfs fscache kvm virtio_balloon virtio_net i2c_piix4 serio_raw nfsd auth_rpcgss(OF) nfs_acl lockd sunrpc(OF) cirrus drm_kms_helper virtio_blk ttm drm i2c_core virtio_pci virtio_ring virtio ata_generic pata_acpi
[ 7535.644041] CPU: 0 PID: 1419 Comm: mount.nfs Tainted: GF          O 3.12.0-2.fc21.x86_64 #1
[ 7535.644041] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 7535.644041] task: ffff88007bef6300 ti: ffff88007be86000 task.ti: ffff88007be86000
[ 7535.644041] RIP: 0010:[<ffffffff810aca07>]  [<ffffffff810aca07>] cpuacct_charge+0x27/0x40
[ 7535.644041] RSP: 0018:ffff88007fc03d88  EFLAGS: 00010046
[ 7535.644041] RAX: 000000000000e6a0 RBX: ffff88007bef6368 RCX: 000000007fc36200
[ 7535.644041] RDX: ffffffff81c48d20 RSI: 00000000000c1c64 RDI: ffff88007bef6300
[ 7535.644041] RBP: ffff88007fc03d88 R08: 00000000000000f0 R09: 0000000000000000
[ 7535.644041] R10: 0000000000000001 R11: ffffea0001edf800 R12: ffff8800375d0000
[ 7535.644041] R13: ffff88007bef6300 R14: 00000000000c1c64 R15: 0000000000000000
[ 7535.644041] FS:  00007fdd196208c0(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[ 7535.644041] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 7535.644041] CR2: 000000037fea6be0 CR3: 000000007aaa7000 CR4: 00000000000006f0
[ 7535.644041] Stack:
[ 7535.644041]  ffff88007fc03dc8 ffffffff810a18ac 000000008389773d ffff88007bef6368
[ 7535.644041]  0000000000000000 ffff8800375d0000 ffff88007fc14540 0000000000000000
[ 7535.644041]  ffff88007fc03e28 ffffffff810a3259 ffff88007fc03e00 ffffffff8109dc08
[ 7535.644041] Call Trace:
[ 7535.644041]  <IRQ> 
[ 7535.644041]  [<ffffffff810a18ac>] update_curr+0xcc/0x160
[ 7535.644041]  [<ffffffff810a3259>] task_tick_fair+0x2b9/0x680
[ 7535.644041]  [<ffffffff8109dc08>] ? sched_clock_cpu+0xa8/0x100
[ 7535.644041]  [<ffffffff81099b81>] scheduler_tick+0x61/0xe0
[ 7535.644041]  [<ffffffff81076dc6>] update_process_times+0x66/0x80
[ 7535.644041]  [<ffffffff810cab95>] tick_sched_handle.isra.15+0x25/0x60
[ 7535.644041]  [<ffffffff810cac11>] tick_sched_timer+0x41/0x60
[ 7535.644041]  [<ffffffff8108e6e4>] __run_hrtimer+0x74/0x1d0
[ 7535.644041]  [<ffffffff810cabd0>] ? tick_sched_handle.isra.15+0x60/0x60
[ 7535.644041]  [<ffffffff8108eef7>] hrtimer_interrupt+0xf7/0x240
[ 7535.644041]  [<ffffffff81041ab7>] local_apic_timer_interrupt+0x37/0x60
[ 7535.644041]  [<ffffffff8167323f>] smp_apic_timer_interrupt+0x3f/0x60
[ 7535.644041]  [<ffffffff81671bdd>] apic_timer_interrupt+0x6d/0x80
[ 7535.644041]  <EOI> 
[ 7535.644041] Code: 5d eb d7 90 66 66 66 66 90 48 8b 47 08 55 48 89 e5 48 63 48 18 48 8b 87 b8 06 00 00 48 8b 50 48 0f 1f 40 00 48 8b 82 88 00 00 00 <48> 03 04 cd e0 5b cf 81 48 01 30 48 8b 52 40 48 85 d2 75 e5 5d 
[ 7535.644041] RIP  [<ffffffff810aca07>] cpuacct_charge+0x27/0x40
[ 7535.644041]  RSP <ffff88007fc03d88>
[ 7535.644041] CR2: 000000037fea6be0

This happens with or without the patchset I proposed earlier. I've also
seen it double fault, and spontaneously reboot. Here's how I'm able to
reproduce it:

I have this in /etc/fstab:

server:/scratch		/mnt/nfs	nfs	sec=krb5,noauto	0 0

...start with rpc.gssd running.

# mount /mnt/nfs
# umount /mnt/nfs
# service rpcgssd stop
# mount /mnt/nfs

...at this point, the mount command will hang as expected due to gssd
being down, but it then continues hanging even after printing this
message:

    RPC: AUTH_GSS upcall timed out.

...a little while later, I either get the stack trace above, or one
reporting a double fault, or a spontaneous reboot.

Perhaps we've got something on the stack (maybe a timer?) and then
aren't cancelling it before returning from the function that owns it?

-- 
Jeff Layton <jlayton@redhat.com>
