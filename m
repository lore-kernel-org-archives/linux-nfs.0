Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32924 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752182AbdKIAnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 19:43:20 -0500
From: Patrick McLean <chutzpah@gentoo.org>
Subject: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: stable@vger.kernel.org, regressions@leemhuis.info,
        torvalds@linux-foundation.org
Message-ID: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
Date: Wed, 8 Nov 2017 16:43:17 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of 4.13.11 (and also with 4.14-rc) we have an issue where when
serving nfs4 sometimes we get the following BUG. When this bug happens,
it usually also causes the motherboard to no longer POST until we
externally re-flash the BIOS (using the BMC web interface). If a
motherboard does not have an external way to flash the BIOS, this would
brick the hardware.

The issue was introduced somewhere between 4.13.8 and 4.13.11 in the
stable series 4.13 kernels. It seems to be much easier to trigger on
4.14 kernels than 4.13 kernels.

We are working on bisecting it, but it is slow going since it often
takes several reboots to trigger the issue.

The taint is caused by the "gkuart" an out-of-kernel driver which is a
fork of the cp210x driver with GPIO lines added to it, we can provide
the source for this if needed.

When the BIOS is gets broke, we see these messages in the shutdown logs:
> [ 2206.698884] kvm: exiting hardware virtualization
> [ 2206.700160] e1000e: EEE TX LPI TIMER: 00t
> [ 2206.743126] ACPI MEMORY or I/O RESET_REG.

Here is the BUG we are getting:
> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
> [   58.963918] IP: vfs_statfs+0x73/0xb0
> [   58.964597] PGD 0 P4D 0 
> [   58.965208] Oops: 0000 [#1] SMP
> [   58.965847] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_multiport xt_addrtype iptable_mangle iptable_raw iptable_nat nf_nat_ipv4 nf_nat gkuart(O) usbserial x86_pkg_temp_thermal ipmi_ssif tpm_tis tpm_tis_core ie31200_edac ext4 mbcache jbd2 e1000e crc32c_intel
> [   58.969163] CPU: 0 PID: 3970 Comm: nfsd Tainted: G           O    4.14.0-rc8-git-kratos-1-00012-gd6a2cf07f0c9 #1
> [   58.970693] Hardware name: TYAN S5510/S5510, BIOS V2.02 03/12/2013
> [   58.971685] task: ffff88040b286200 task.stack: ffffc90002c94000
> [   58.972576] RIP: 0010:vfs_statfs+0x73/0xb0
> [   58.973329] RSP: 0018:ffffc90002c97b30 EFLAGS: 00010202
> [   58.974188] RAX: 0000000000000000 RBX: ffffc90002c97bf8 RCX: 0000000000001c00
> [   58.975253] RDX: 0000000000000c00 RSI: 0000000000000020 RDI: 0000000000000000
> [   58.976213] RBP: ffffc90002c97bc8 R08: 0000000000000000 R09: 00000000000000ff
> [   58.977161] R10: 000000000038be3a R11: ffff88040ec440c8 R12: ffff88040c5ba000
> [   58.978107] R13: ffff88040a86e000 R14: ffff88040c5c1000 R15: ffffc90002c97bf8
> [   58.979051] FS:  0000000000000000(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
> [   58.980448] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   58.981419] CR2: 0000000000000230 CR3: 0000000001e0a002 CR4: 00000000001606f0
> [   58.982483] Call Trace:
> [   58.983108]  nfsd4_encode_fattr+0x1f3/0x2070
> [   58.983873]  ? find_inode_fast+0x52/0x90
> [   58.984587]  ? get_acl+0x17/0xf0
> [   58.985258]  ? generic_permission+0x122/0x1a0
> [   58.986019]  nfsd4_encode_getattr+0x25/0x30
> [   58.986746]  nfsd4_encode_operation+0x98/0x1a0
> [   58.987485]  nfsd4_proc_compound+0x3eb/0x5c0
> [   58.988206]  nfsd_dispatch+0xa8/0x230
> [   58.988891]  svc_process_common+0x347/0x640
> [   58.989619]  svc_process+0x100/0x1b0
> [   58.990334]  nfsd+0xe3/0x150
> [   58.990988]  kthread+0xfc/0x130
> [   58.991651]  ? nfsd_destroy+0x60/0x60
> [   58.992364]  ? kthread_create_on_node+0x40/0x40
> [   58.993153]  ret_from_fork+0x25/0x30
> [   58.993858] Code: d1 83 c9 08 40 f6 c6 04 0f 45 d1 89 d1 80 cd 04 40 f6 c6 08 0f 45 d1 89 d1 80 cd 08 40 f6 c6 10 0f 45 d1 89 d1 80 cd 10 83 e6 20 <48> 8b b7 30 02 00 00 0f 45 d1 83 ca 20 89 f1 83 e1 10 89 cf 83
> [   58.996592] RIP: vfs_statfs+0x73/0xb0 RSP: ffffc90002c97b30
> [   58.997474] CR2: 0000000000000230
> [   58.998147] ---[ end trace c3a6e976d53aaa00 ]---
> [  107.669217] random: crng init done
> [  210.170059] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
> [  210.176363] IP: vfs_statfs+0x73/0xb0
> [  210.177032] PGD 0 P4D 0
> [  210.177633] Oops: 0000 [#2] SMP
> [  210.178286] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_multiport xt_addrtype iptable_mangle iptable_raw iptable_nat nf_nat_ipv4 nf_nat gkuart(O) usbserial x86_pkg_temp_thermal ipmi_ssif tpm_tis tpm_tis_core ie31200_edac ext4 mbcache jbd2 e1000e crc32c_intel
> [  210.192120] CPU: 0 PID: 3969 Comm: nfsd Tainted: G      D    O    4.14.0-rc8-git-kratos-1-00012-gd6a2cf07f0c9 #1
> [  210.203168] Hardware name: TYAN S5510/S5510, BIOS V2.02 03/12/2013
> [  210.204140] task: ffff880409a7aa00 task.stack: ffffc90002c8c000
> [  210.205168] RIP: 0010:vfs_statfs+0x73/0xb0
> [  210.205893] RSP: 0018:ffffc90002c8fb30 EFLAGS: 00010202
> [  210.206708] RAX: 0000000000000000 RBX: ffffc90002c8fbf8 RCX: 0000000000001c00
> [  210.218314] RDX: 0000000000000c00 RSI: 0000000000000020 RDI: 0000000000000000
> [  210.219364] RBP: ffffc90002c8fbc8 R08: 0000000000000000 R09: 00000000000000ff
> [  210.220426] R10: 000000000038be3a R11: ffff88040ec440c8 R12: ffff88040c5b8000
> [  210.221455] R13: ffff88040a86e000 R14: ffff88040c5c4000 R15: ffffc90002c8fbf8
> [  210.222484] FS:  0000000000000000(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
> [  210.223894] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  210.224938] CR2: 0000000000000230 CR3: 0000000001e0a003 CR4: 00000000001606f0
> [  210.226020] Call Trace:
> [  210.226615]  nfsd4_encode_fattr+0x1f3/0x2070
> [  210.227348]  ? find_inode_fast+0x52/0x90
> [  210.238225]  ? get_acl+0x17/0xf0
> [  210.238890]  ? generic_permission+0x122/0x1a0
> [  210.239637]  nfsd4_encode_getattr+0x25/0x30
> [  210.240365]  nfsd4_encode_operation+0x98/0x1a0
> [  210.241127]  nfsd4_proc_compound+0x3eb/0x5c0
> [  210.241868]  nfsd_dispatch+0xa8/0x230
> [  210.242564]  svc_process_common+0x347/0x640
> [  210.243294]  svc_process+0x100/0x1b0
> [  210.243969]  nfsd+0xe3/0x150
> [  210.244582]  kthread+0xfc/0x130
> [  210.255467]  ? nfsd_destroy+0x60/0x60
> [  210.256153]  ? kthread_create_on_node+0x40/0x40
> [  210.256892]  ret_from_fork+0x25/0x30
> [  210.257570] Code: d1 83 c9 08 40 f6 c6 04 0f 45 d1 89 d1 80 cd 04 40 f6 c6 08 0f 45 d1 89 d1 80 cd 08 40 f6 c6 10 0f 45 d1 89 d1 80 cd 10 83 e6 20 <48> 8b b7 30 02 00 00 0f 45 d1 83 ca 20 89 f1 83 e1 10 89 cf 83
> [  210.260340] RIP: vfs_statfs+0x73/0xb0 RSP: ffffc90002c8fb30
> [  210.261157] CR2: 0000000000000230
> [  210.261810] ---[ end trace c3a6e976d53aaa01 ]---
