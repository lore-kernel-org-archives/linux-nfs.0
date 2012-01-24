Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.scalarmail.ca ([98.158.95.75]:52458 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751926Ab2AXEMy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 23:12:54 -0500
Date: Mon, 23 Jan 2012 23:12:51 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: NFS auth_rpcgss client crash in 3.3-rc1+ (regression)
Message-ID: <20120124041251.GA16952@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing crashes similar to the following with latest Linus' git on an
NFSv4 client machine.  User home directories are NFS mounted with
sec=krb5, and the crash often occurs immediately or shortly after the
first successful login.  However, it does not always crash: it happens
maybe 50% of the time.  Most of the time the box is dead as a result.

I see this in Linux 3.3-rc1 as well, but I've not had a chance to bisect
it yet (might be tricky since it's not 100% reliable).  The server is
running Linux 3.2.1.

  general protection fault: 0000 [#1] PREEMPT SMP 
  CPU 3 
  Modules linked in: netconsole sha1_ssse3 sha1_generic hmac aes_x86_64 aes_generic cbc cts rpcsec_gss_krb5 nfs lockd auth_rpcgss nfs_acl sunrpc ipv6 coretemp hwmon_vid hwmon snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss nls_iso8859_1 nls_cp437 vfat fat acpi_cpufreq mperf snd_hda_codec_hdmi snd_hda_codec_realtek arc4 snd_hda_intel snd_hda_codec ath9k mac80211 snd_pcm i915 drm_kms_helper drm snd_timer ath9k_common ath9k_hw ath cfg80211 snd intel_agp i2c_algo_bit r8169 intel_gtt psmouse evdev agpgart video i2c_i801 soundcore i2c_core snd_page_alloc mii
  
  Pid: 2088, comm: zsh Not tainted 3.3.0-rc1-00060-gc1aab02 #12 System manufacturer System Product Name/P8H67-I DELUXE
  RIP: 0010:[<ffffffff811848fe>]  [<ffffffff811848fe>] strcmp+0x4/0x21
  RSP: 0018:ffff88022f2b9808  EFLAGS: 00010282
  RAX: 0000000000000000 RBX: ffff880234a13c60 RCX: ffff8802317aa6c0
  RDX: 0038004000000000 RSI: ffff8802316d2170 RDI: 0038004000000000
  RBP: ffff88022f2b9808 R08: ffff8802319e1600 R09: ffff88022f2b9918
  R10: ffffffff810089c5 R11: ffff88022f2b9968 R12: ffff88023167fba8
  R13: 0000000000000000 R14: ffff8802369ca2e0 R15: ffff880234ac8780
  FS:  00007fee11170700(0000) GS:ffff88023fb80000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007fee10613f80 CR3: 000000023169d000 CR4: 00000000000406e0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
  Process zsh (pid: 2088, threadinfo ffff88022f2b8000, task ffff88023586bca0)
  Stack:
   ffff88022f2b9818 ffffffffa02eeeae ffff88022f2b9888 ffffffffa02b3f88
   ffff88022f2b9838 0000000000000000 0000000000000000 ffff880234a13c6c
   ffff88022f2b9848 ffff88022f2b9848 ffff8802304b3800 ffff8802319e1600
  Call Trace:
   [<ffffffffa02eeeae>] gss_match+0x44/0x5e [auth_rpcgss]
   [<ffffffffa02b3f88>] rpcauth_lookup_credcache+0xdf/0x221 [sunrpc]
   [<ffffffffa02eef11>] gss_lookup_cred+0x9/0xb [auth_rpcgss]
   [<ffffffffa02b4c77>] generic_bind_cred+0x17/0x19 [sunrpc]
   [<ffffffffa02b469d>] rpcauth_refreshcred+0x47/0x15a [sunrpc]
   [<ffffffffa02aeca7>] ? xprt_reserve+0x23e/0x24b [sunrpc]
   [<ffffffffa02ab387>] call_refresh+0x5c/0x60 [sunrpc]
   [<ffffffffa02b33e8>] __rpc_execute+0x76/0x28b [sunrpc]
   [<ffffffffa02b365e>] rpc_execute+0x3d/0x41 [sunrpc]
   [<ffffffffa02accdc>] rpc_run_task+0xdf/0xeb [sunrpc]
   [<ffffffffa02acdc3>] rpc_call_sync+0x3d/0x5e [sunrpc]
   [<ffffffffa031cd63>] ? nfs_fattr_init+0x21/0x41 [nfs]
   [<ffffffffa0330fb6>] _nfs4_call_sync+0x1c/0x1e [nfs]
   [<ffffffffa032d278>] nfs4_call_sync+0x11/0x13 [nfs]
   [<ffffffffa0330e8a>] _nfs4_proc_access+0xf4/0x151 [nfs]
   [<ffffffffa0330f16>] nfs4_proc_access+0x2f/0x55 [nfs]
   [<ffffffffa03198b5>] nfs_do_access+0x1a8/0x3e9 [nfs]
   [<ffffffffa02b4e90>] ? generic_lookup_cred+0x10/0x12 [sunrpc]
   [<ffffffffa02b441b>] ? rpcauth_lookupcred+0x8e/0xab [sunrpc]
   [<ffffffffa0319bc3>] nfs_permission+0xcd/0x160 [nfs]
   [<ffffffff810b285b>] inode_permission+0x66/0x9f
   [<ffffffff810b2928>] link_path_walk+0x94/0x463
   [<ffffffff810b2f80>] ? path_init+0x1d1/0x2f4
   [<ffffffff810bf73b>] ? vfsmount_lock_local_unlock+0x34/0x3f
   [<ffffffff810b16d0>] ? complete_walk+0x8c/0xe1
   [<ffffffff810b30f7>] path_lookupat+0x54/0x314
   [<ffffffff81188515>] ? strncpy_from_user+0x34/0x37
   [<ffffffff810b33d5>] do_path_lookup+0x1e/0x54
   [<ffffffff810b4bec>] user_path_at_empty+0x4e/0x94
   [<ffffffff810ac857>] ? cp_new_stat+0xe9/0x101
   [<ffffffff810b4c3e>] user_path_at+0xc/0xe
   [<ffffffff810ac9db>] vfs_fstatat+0x3a/0x65
   [<ffffffff810aca37>] vfs_stat+0x16/0x18
   [<ffffffff810acb34>] sys_newstat+0x1a/0x34
   [<ffffffff81300222>] system_call_fastpath+0x16/0x1b
  Code: 48 ff c1 80 39 00 75 f8 eb 0d 48 ff c1 48 ff ca 75 05 c6 01 00 eb 0e 40 8a 3e 48 ff c6 40 88 39 40 84 ff 75 e5 c9 c3 55 48 89 e5 <8a> 07 8a 16 48 ff c7 48 ff c6 38 d0 74 07 19 c0 83 c8 01 eb 06 
  RIP  [<ffffffff811848fe>] strcmp+0x4/0x21
   RSP <ffff88022f2b9808>
  ---[ end trace 3bf9223f590824da ]---

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

