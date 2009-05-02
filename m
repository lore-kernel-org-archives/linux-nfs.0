From: Rince <rincebrain@gmail.com>
Subject: NULL pointer dereference in _nfs4_do_setlk (was: [patch] mm: close
	page_mkwrite races (try 3))
Date: Sat, 2 May 2009 18:32:47 -0400
Message-ID: <5da0588e0905021532j566daa59m2ee19ff838adfc77@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:61739 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbZEBWcu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 May 2009 18:32:50 -0400
Received: by qyk34 with SMTP id 34so4461882qyk.33
        for <linux-nfs@vger.kernel.org>; Sat, 02 May 2009 15:32:49 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kernel is 2.6.30-rc4 with patches

mm-close-page_mkwrite-races-try-3.patch
mm-close-page_mkwrite-races-try-3-update.patch
mm-close-page_mkwrite-races-try-3-fix.patch
mm-close-page_mkwrite-races-try-3-fix-fix.patch
and http://lkml.org/lkml/2009/4/25/64

Presumably a bug exposed by fixing the race, and not something new intr=
oduced?

- Rich

---------- Forwarded message ----------
=46rom: Rince <rincebrain@gmail.com>
Date: Sat, May 2, 2009 at 6:12 PM
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-fsdevel@vger.kernel.org


Well...that's different.

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
10
IP: [<ffffffffa02c8ff2>] _nfs4_do_setlk+0xe3/0x289 [nfs]
PGD 10e4f7067 PUD 109221067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/virtual/block/md0/md/metadata_version
CPU 0
Modules linked in: autofs4 coretemp hwmon nfs lockd nfs_acl
auth_rpcgss sunrpc cachefiles fscache ipv6 cpufreq_ondemand
acpi_cpufreq freq_table kvm_intel kvm snd_hda_codec_idt snd_hda_intel
snd_hda_codec snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm cpia_usb
e1000e snd_timer ppdev cpia snd ums_cypress parport_pc videodev
firewire_ohci i82975x_edac usb_storage parport firewire_core i2c_i801
edac_core v4l1_compat soundcore snd_page_alloc iTCO_wdt
v4l2_compat_ioctl32 pcspkr i2c_core crc_itu_t iTCO_vendor_support
raid1 [last unloaded: scsi_wait_scan]
Pid: 29418, comm: 10.1.1.2-manage Not tainted 2.6.30-rc4 #1
RIP: 0010:[<ffffffffa02c8ff2>] =A0[<ffffffffa02c8ff2>]
_nfs4_do_setlk+0xe3/0x289 [nfs]
RSP: 0018:ffff880102361d30 =A0EFLAGS: 00010246
RAX: ffff8800ce865f00 RBX: ffff88010b4b74d8 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 00000000000000d0 RDI: 0000000000000138
RBP: ffff880102361de0 R08: ffff880126557000 R09: ffff8800b38c3900
R10: ffffffffa02cbd1c R11: ffff880126553c00 R12: 00000000fffffff4
R13: 0000000000000000 R14: ffff88012d42f5c0 R15: ffff88012d42f5c0
=46S: =A00000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000=
000000000
CS: =A00010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000010 CR3: 0000000016eda000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process 10.1.1.2-manage (pid: 29418, threadinfo ffff880102360000, task
ffff8800015b5c00)
Stack:
=A0ffff880102361d40 0000000600000001 ffff8800ce865f00 ffffffffa02cbc5c
=A00000000000000000 ffff880126555c00 ffff880102361d90 ffffffffa02db960
=A00000000000000000 ffff880128093000 0000000000000001 ffffffffa02b88aa
Call Trace:
=A0[<ffffffffa02cbc5c>] ? nfs4_open_recover_helper+0x82/0x97 [nfs]
=A0[<ffffffffa02b88aa>] ? __put_nfs_open_context+0x31/0x98 [nfs]
=A0[<ffffffffa02c9646>] nfs4_lock_reclaim+0x60/0x8d [nfs]
=A0[<ffffffffa02d57a3>] nfs4_do_reclaim+0x13d/0x322 [nfs]
=A0[<ffffffffa02d5b21>] nfs4_run_state_manager+0x199/0x27f [nfs]
=A0[<ffffffffa02d5988>] ? nfs4_run_state_manager+0x0/0x27f [nfs]
=A0[<ffffffffa02d5988>] ? nfs4_run_state_manager+0x0/0x27f [nfs]
=A0[<ffffffff8105e7bf>] kthread+0x5b/0x88
=A0[<ffffffff81011dba>] child_rip+0xa/0x20
=A0[<ffffffff8101177d>] ? restore_args+0x0/0x30
=A0[<ffffffff8105e764>] ? kthread+0x0/0x88
=A0[<ffffffff81011db0>] ? child_rip+0x0/0x20
Code: 10 e1 49 8b 47 58 4d 8b af 90 00 00 00 be d0 00 00 00 bf 38 01
00 00 41 bc f4 ff ff ff 48 8b 80 a0 00 00 00 48 89 85 60 ff ff ff <49>
8b 45 10 4c 8b 70 38 49 8b 86 00 01 00 00 48 8b 80 a8 02 00
RIP =A0[<ffffffffa02c8ff2>] _nfs4_do_setlk+0xe3/0x289 [nfs]
=A0RSP <ffff880102361d30>
CR2: 0000000000000010
---[ end trace 205a6f9494aa30de ]---

It's unclear to me whether I should blame this on the patches applied,
or that this is just something never triggered unless the
aforementioned bug is fixed...

- Rich

--

Aquele que ri do destino conquistar=E1 a fortuna. -- Benjamin Disraeli



--=20

Violence is molding.
