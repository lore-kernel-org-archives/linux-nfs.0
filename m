Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43111 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab0G1SOx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 14:14:53 -0400
Received: by gxk23 with SMTP id 23so1796570gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jul 2010 11:14:52 -0700 (PDT)
Date: Wed, 28 Jul 2010 23:44:49 +0530
Message-ID: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>
Subject: BUG: unable to handle kernel NULL pointer dereference at
	0000000000000020
From: yo mama <mamamia69@gmail.com>
To: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I am running Kernel version 2.6.35-rc5-pnfs and notice there is kernel
crash everytime i run iozone on the mounted directory. Is there a
patch already developed for this bug which i can apply. Please see the
error message from message log.




Jul 28 11:06:28 localhost kernel: BUG: unable to handle kernel NULL
pointer dereference at 0000000000000020
Jul 28 11:06:28 localhost kernel: IP: [<ffffffffa025d117>]
encode_stateid+0x3e/0x8f [nfs]
Jul 28 11:06:28 localhost kernel: PGD 6d288067 PUD 70e43067 PMD 0
Jul 28 11:06:28 localhost kernel: Oops: 0000 [#1] SMP
Jul 28 11:06:28 localhost kernel: last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.3/local_cpus
Jul 28 11:06:28 localhost kernel: CPU 0
Jul 28 11:06:28 localhost kernel: Modules linked in: nfslayoutdriver
nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 p4_clockmod
freq_table speedstep_lib dm_multipath uinput e1000e iTCO_wdt serio_raw
iTCO_vendor_support i2c_i801 pcspkr usb_storage i915 drm_kms_helper
drm i2c_algo_bit i2c_core video output [last unloaded: mperf]
Jul 28 11:06:28 localhost kernel:
Jul 28 11:06:28 localhost kernel: Pid: 1317, comm: iozone Not tainted
2.6.35-rc5-pnfs #1 To be filled by O.E.M./To Be Filled By O.E.M.
Jul 28 11:06:28 localhost kernel: RIP: 0010:[<ffffffffa025d117>]
[<ffffffffa025d117>] encode_stateid+0x3e/0x8f [nfs]
Jul 28 11:06:28 localhost kernel: RSP: 0018:ffff880079223a08  EFLAGS: 00010286
Jul 28 11:06:28 localhost kernel: RAX: ffff8800744b10b8 RBX:
ffff8800744b10b8 RCX: 0000000000000000
Jul 28 11:06:28 localhost kernel: RDX: ffff88007b03c008 RSI:
ffff880070a0d9c0 RDI: ffff880079223ab8
Jul 28 11:06:28 localhost kernel: RBP: ffff880079223a48 R08:
ffff8800744b10b4 R09: 0000000000000004
Jul 28 11:06:28 localhost kernel: R10: ffff8800702d72b8 R11:
0000000000000007 R12: ffff88006d148500
Jul 28 11:06:28 localhost kernel: R13: 0000000000000000 R14:
ffff880079223ab8 R15: ffffffffa025d2a1
Jul 28 11:06:28 localhost kernel: FS:  00007f34ff276700(0000)
GS:ffff880002000000(0000) knlGS:0000000000000000
Jul 28 11:06:28 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Jul 28 11:06:28 localhost kernel: CR2: 0000000000000020 CR3:
000000006d2a7000 CR4: 00000000000006f0
Jul 28 11:06:28 localhost kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Jul 28 11:06:28 localhost kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Jul 28 11:06:28 localhost kernel: Process iozone (pid: 1317,
threadinfo ffff880079222000, task ffff88006ed4dcc0)
Jul 28 11:06:28 localhost kernel: Stack:
Jul 28 11:06:28 localhost kernel: ffff880079223a18 ffffffffa025ae90
ffff880079223a78 00000000a4433f68
Jul 28 11:06:28 localhost kernel: <0> 000a12d000000010
ffff880079223a88 ffff880079223ab8 ffff8800702d71f0
Jul 28 11:06:28 localhost kernel: <0> ffff880079223a78
ffffffffa025d1a3 ffff88007b03c000 ffff8800702d71f0
Jul 28 11:06:28 localhost kernel: Call Trace:
Jul 28 11:06:28 localhost kernel: [<ffffffffa025ae90>] ?
reserve_space+0xe/0x19 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffffa025d1a3>]
encode_write+0x3b/0x89 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffffa025d33a>]
nfs4_xdr_enc_write+0x99/0xc5 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffffa01b782a>]
rpcauth_wrap_req+0x7f/0x8e [sunrpc]
Jul 28 11:06:28 localhost kernel: [<ffffffffa01afe97>]
call_transmit+0x1e9/0x26d [sunrpc]
Jul 28 11:06:28 localhost kernel: [<ffffffffa01b6d4a>]
__rpc_execute+0x86/0x213 [sunrpc]
Jul 28 11:06:28 localhost kernel: [<ffffffffa01b6efa>]
rpc_execute+0x23/0x27 [sunrpc]
Jul 28 11:06:28 localhost kernel: [<ffffffffa01b09bf>]
rpc_run_task+0x29/0x2f [sunrpc]
Jul 28 11:06:28 localhost kernel: [<ffffffffa0244812>]
nfs_direct_write_execute+0x6a/0xc8 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffffa02452b3>]
nfs_file_direct_write+0x503/0x66f [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffff8106506e>] ? wake_up_bit+0x25/0x2a
Jul 28 11:06:28 localhost kernel: [<ffffffffa023d0c4>]
nfs_file_write+0x62/0x184 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffff8110410e>] do_sync_write+0xcb/0x108
Jul 28 11:06:28 localhost kernel: [<ffffffffa0249471>] ?
nfs_wb_all+0x42/0x44 [nfs]
Jul 28 11:06:28 localhost kernel: [<ffffffff811c5caf>] ?
security_file_permission+0x16/0x18
Jul 28 11:06:28 localhost kernel: [<ffffffff81104691>] vfs_write+0xae/0x10b
Jul 28 11:06:28 localhost kernel: [<ffffffff811047ae>] sys_write+0x4a/0x6e
Jul 28 11:06:28 localhost kernel: [<ffffffff81009c32>]
system_call_fastpath+0x16/0x1b
Jul 28 11:06:28 localhost kernel: Code: 89 f4 be 10 00 00 00 49 89 d5
65 48 8b 04 25 28 00 00 00 48 89 45 d8 31 c0 e8 78 dd ff ff 49 8b 74
24 48 48 89 c3 48 85 f6 74 1e <49> 8b 55 20 4c 8d 65 c0 41 8b 4d 28 4c
89 e7 e8 c5 4d 00 00 ba
Jul 28 11:06:28 localhost kernel: RIP  [<ffffffffa025d117>]
encode_stateid+0x3e/0x8f [nfs]
Jul 28 11:06:28 localhost kernel: RSP <ffff880079223a08>
Jul 28 11:06:28 localhost kernel: CR2: 0000000000000020
Jul 28 11:06:28 localhost kernel: ---[ end trace 8dabbf8bb362aa6e ]---
Jul 28 11:06:36 localhost abrtd: Hmm, stray update_client: 'Creating
kernel oops crash reports...'
Jul 28 11:06:36 localhost abrt: Kerneloops: Reported 1 kernel oopses to Abrt
Jul 28 11:06:36 localhost abrtd: Directory 'kerneloops-1280340396-1'
creation detected
Jul 28 11:06:36 localhost abrtd: Getting local universal unique identification
Jul 28 11:06:36 localhost abrtd: New crash, saving...
