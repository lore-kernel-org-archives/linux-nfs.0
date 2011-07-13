Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64078 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab1GMOyw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 10:54:52 -0400
Received: by iwn6 with SMTP id 6so5654834iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2011 07:54:52 -0700 (PDT)
Date: Wed, 13 Jul 2011 10:54:51 -0400
Message-ID: <CAN-5tyEaNKNj59RQCRrSv2gpT+GOyGR4sE7Lk0SkX29_Z0_c3Q@mail.gmail.com>
Subject: nfs41 daemon kernel oops
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Running iozone using the windows client consistently crashes nfsd
(nfsd from latest pnfs tree).
Before the oops kernel prints a number of  "state lock taken by pid =
xxxx fun=nfsd4_read".

BUG: unable to handle kernel NULL pointer dereference at 00000000000002ac
IP: [<ffffffffa02d5fe7>] __nfs4_lock_state+0x33/0x68 [nfsd]
PGD 0
Oops: 0000 [#1] SMP
CPU 1
Modules linked in: nfs fscache tcp_lp deflate zlib_deflate ctr camellia cast5 rm
d160 crypto_null ccm serpent blowfish twofish_x86_64 twofish_common ecb xcbc cbc
 sha256_generic sha512_generic aes_x86_64 aes_generic ah6 ah4 esp6 esp4 xfrm4_mo
de_beet xfrm4_tunnel tunnel4 xfrm4_mode_tunnel xfrm4_mode_transport xfrm6_mode_t
ransport xfrm6_mode_ro xfrm6_mode_beet nfsd lockd xfrm6_mode_tunnel ipcomp ipcom
p6 xfrm_ipcomp xfrm6_tunnel tunnel6 exportfs nfs_acl af_key rpcsec_gss_krb5 auth
_rpcgss des_generic sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_R
EJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_
analog joydev snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_p
cm snd_timer snd soundcore snd_page_alloc r8169 iTCO_wdt i2c_i801 iTCO_vendor_su
pport mii serio_raw pcspkr asus_atk0110 microcode ipv6 autofs4 firewire_ohci fir
ewire_core ata_generic pata_acpi crc_itu_t pata_jmicron i915 drm_kms_helper drm
i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]

Pid: 16982, comm: nfsd Not tainted 3.0.0-rc5-pnfs #1 System manufacturer System
Product Name/P5B-BN
RIP: 0010:[<ffffffffa02d5fe7>]  [<ffffffffa02d5fe7>] __nfs4_lock_state+0x33/0x68
 [nfsd]
RSP: 0018:ffff88017477fd30  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffffffa02e3ac8 RCX: 00000000ffffffff
RDX: ffffffffa02e3ac8 RSI: ffff8800514ca040 RDI: ffffffffa02e69a4
RBP: ffff88017477fd40 R08: 0000000000000000 R09: ffff8800516e0500
R10: ffff88017477fd00 R11: ffff88017477fd00 R12: ffff8800514ca040
R13: ffff880174698000 R14: 0000000016000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88017bc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000002ac CR3: 0000000051640000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 16982, threadinfo ffff88017477e000, task ffff880051692e40)
Stack:
 ffff8800514ce2c0 ffff8800514ce2c0 ffff88017477fd70 ffffffffa02cc593
 ffff8800514ca000 ffff8800514ce2b8 ffff8800514ce000 ffff880174698000
 ffff88017477fdc0 ffffffffa02cb975 ffff8800514ca180 ffff8800514ca040
Call Trace:
 [<ffffffffa02cc593>] nfsd4_read+0x43/0x9e [nfsd]
 [<ffffffffa02cb975>] nfsd4_proc_compound+0x22e/0x416 [nfsd]
 [<ffffffffa02bd83c>] nfsd_dispatch+0xed/0x1d2 [nfsd]
 [<ffffffffa01f7325>] svc_process_common+0x2d4/0x4d5 [sunrpc]
 [<ffffffffa01f7746>] svc_process+0x11d/0x13b [sunrpc]
 [<ffffffffa02bd0f3>] nfsd+0xf3/0x13c [nfsd]
 [<ffffffffa02bd000>] ? 0xffffffffa02bcfff
 [<ffffffff810647fb>] kthread+0x84/0x8c
 [<ffffffff814621a4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81064777>] ? kthread_worker_fn+0x148/0x148
 [<ffffffff814621a0>] ? gs_change+0x13/0x13
Code: 66 66 90 48 89 fb 48 c7 c7 70 c7 2e a0 e8 12 3b 18 e1 85 c0 75 2e 48 8b 05
 67 95 01 00 48 8b 15 58 95 01 00 48 c7 c7 a4 69 2e a0 <8b> b0 ac 02 00 00 31 c0
 e8 c4 c1 17 e1 48 c7 c7 70 c7 2e a0 e8
RIP  [<ffffffffa02d5fe7>] __nfs4_lock_state+0x33/0x68 [nfsd]
 RSP <ffff88017477fd30>
CR2: 00000000000002ac
---[ end trace 9b7c9e0f99f5ee03 ]---
