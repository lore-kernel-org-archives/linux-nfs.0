Return-Path: <SRS0=1lUO=RV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C102FC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 20:38:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 656A92085A
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 20:38:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726980AbfCRUi1 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 16:38:27 -0400
Received: from mx2.math.uh.edu ([129.7.128.33]:46846 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726959AbfCRUi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 16:38:27 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1h5z1c-0006Q0-7K
        for linux-nfs@vger.kernel.org; Mon, 18 Mar 2019 15:38:26 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 27EC4801554; Mon, 18 Mar 2019 15:38:24 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Null pointer dereference in gss_verify_mic_kerberos (4.20.14)
Date:   Mon, 18 Mar 2019 15:38:24 -0500
Message-ID: <ufad0mn6hq7.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just hit an odd oops on a desktop running Fedora's 4.20.14, which was
followed by a complete hang of all NFS operations.  The Fedora kernel is
only lightly patched, but does include Trond's "[PATCH] NFSv4.1: Avoid
false retries when RPC calls are interrupted".  I don't think that's
involved here but I'm certainly no expert.  I also don't know if this is
known, but I don't see anything in 4.20.15 or 4.20.16 that looks like it
would be help.

So far I've seen this only once across 100+ desktops and have no idea
how I might reproduce it.

I have filed a ticket with Fedora
(https://bugzilla.redhat.com/show_bug.cgi?id=1690123).  If there's
another place I should report this, please let me know.

 - J<

[Mar18 13:57] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
[  +0.000004] PGD 0 P4D 0 
[  +0.000004] Oops: 0000 [#1] SMP PTI
[  +0.000003] CPU: 0 PID: 6747 Comm: kactivitymanage Not tainted 4.20.14-200.fc29.x86_64 #1
[  +0.000001] Hardware name: ASUS All Series/H87I-PLUS, BIOS 2002 07/22/2014
[  +0.000006] RIP: 0010:gss_verify_mic_kerberos+0x73/0x300 [rpcsec_gss_krb5]
[  +0.000002] Code: 00 0f 84 a7 02 00 00 48 8d 44 24 34 4c 8b 62 08 c7 44 24 20 14 00 00 00 48 89 44 24 28 f6 05 9f f8 d2 ff 10 0f 85 95 3a 00 00 <66> 41 81 3c 24 04 04 41 bd 00 00 09 00 0f 85 b3 00 00 00 41 0f b6
[  +0.000002] RSP: 0018:ffff97f702afb748 EFLAGS: 00010246
[  +0.000002] RAX: ffff97f702afb77c RBX: ffff8a69b3945600 RCX: 0000000000000012
[  +0.000001] RDX: ffff97f702afb7c0 RSI: ffff97f702afb7d0 RDI: ffff8a69a4bafe20
[  +0.000002] RBP: ffff97f702afb7d0 R08: 00000000000002f4 R09: ffff8a69b38e9780
[  +0.000001] R10: ffff8a690ddfcf98 R11: 0000000035e353de R12: 0000000000000000
[  +0.000002] R13: 0000000000000000 R14: 0000000000000b14 R15: ffff8a6991c68660
[  +0.000002] FS:  00007f2f9785de00(0000) GS:ffff8a6a4f800000(0000) knlGS:0000000000000000
[  +0.000001] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  +0.000002] CR2: 0000000000000000 CR3: 0000000348fee004 CR4: 00000000001606f0
[  +0.000001] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  +0.000002] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  +0.000001] Call Trace:
[  +0.000008]  gss_unwrap_resp_integ.isra.10+0xa6/0xf0 [auth_rpcgss]
[  +0.000017]  ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
[  +0.000003]  gss_unwrap_resp+0x1c4/0x230 [auth_rpcgss]
[  +0.000011]  ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
[  +0.000014]  rpcauth_unwrap_resp+0x67/0xc0 [sunrpc]
[  +0.000012]  ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
[  +0.000009]  call_decode+0x260/0x500 [sunrpc]
[  +0.000010]  ? trace_event_raw_event_rpc_stats_latency+0x240/0x240 [sunrpc]
[  +0.000008]  ? call_refreshresult+0xd0/0xd0 [sunrpc]
[  +0.000009]  __rpc_execute+0x7f/0x350 [sunrpc]
[  +0.000005]  ? recalibrate_cpu_khz+0x10/0x10
[  +0.000002]  ? ktime_get+0x36/0xa0
[  +0.000008]  rpc_run_task+0x121/0x180 [sunrpc]
[  +0.000009]  nfs4_call_sync_sequence+0x64/0xa0 [nfsv4]
[  +0.000008]  _nfs4_proc_readdir+0x208/0x280 [nfsv4]
[  +0.000010]  nfs4_proc_readdir+0x86/0x120 [nfsv4]
[  +0.000008]  ? nfs4_proc_symlink+0x1e0/0x1e0 [nfsv4]
[  +0.000011]  nfs_readdir_xdr_to_array+0x17a/0x3f0 [nfs]
[  +0.000005]  ? xas_store+0x2a/0x520
[  +0.000003]  ? mem_cgroup_commit_charge+0x82/0x150
[  +0.000003]  ? __add_to_page_cache_locked+0x2b1/0x3d0
[  +0.000008]  nfs_readdir_filler+0x1b/0x90 [nfs]
[  +0.000003]  do_read_cache_page+0x375/0x7d0
[  +0.000006]  ? nfs_readdir_xdr_to_array+0x3f0/0x3f0 [nfs]
[  +0.000011]  ? nfs4_do_check_delegation+0x18/0x40 [nfsv4]
[  +0.000007]  nfs_readdir+0x137/0x510 [nfs]
[  +0.000009]  ? nfs4_xdr_dec_allocate+0xd0/0xd0 [nfsv4]
[  +0.000005]  iterate_dir+0x91/0x180
[  +0.000003]  ksys_getdents64+0x9c/0x130
[  +0.000002]  ? iterate_dir+0x180/0x180
[  +0.000003]  __x64_sys_getdents64+0x16/0x20
[  +0.000003]  do_syscall_64+0x5b/0x160
[  +0.000003]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  +0.000002] RIP: 0033:0x7f2f9a2e2e2b
[  +0.000002] Code: 00 00 48 83 c4 08 5b 5d c3 66 0f 1f 44 00 00 f3 0f 1e fa 48 8b 47 20 c3 0f 1f 80 00 00 00 00 f3 0f 1e fa b8 d9 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 05 c3 0f 1f 40 00 48 8b 15 29 b0 0f 00 f7 d8
[  +0.000002] RSP: 002b:00007ffde2c6b468 EFLAGS: 00000246 ORIG_RAX: 00000000000000d9
[  +0.000002] RAX: ffffffffffffffda RBX: 00005628b48fb6f0 RCX: 00007f2f9a2e2e2b
[  +0.000001] RDX: 0000000000008000 RSI: 00005628b48fb720 RDI: 0000000000000012
[  +0.000001] RBP: 00005628b48fb720 R08: 0000000000000001 R09: 0000000000000020
[  +0.000002] R10: 00005628b451c010 R11: 0000000000000246 R12: ffffffffffffff40
[  +0.000001] R13: 0000000000000002 R14: 00007ffde2c6b4b8 R15: 00005628b48efae0
[  +0.000002] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs lockd grace fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat_ipv4 nf_nat iptable_mangle iptable_raw iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_set nfnetlink ebtable_filter ebtables ip6table_filter ip6_tables vfat fat intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp iTCO_wdt iTCO_vendor_support snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel crct10dif_pclmul snd_hda_codec crc32_pclmul snd_hda_core snd_hwdep snd_seq joydev ghash_clmulni_intel intel_cstate eeepc_wmi snd_seq_device asus_wmi sparse_keymap intel_uncore rfkill snd_pcm intel_rapl_perf wmi_bmof i2c_i801 mei_me e1000e snd_timer mei snd soundcore lpc_ich pcc_cpufreq auth_rpcgss sunrpc binfmt_misc xfs libcrc32c i915 kvmgt mdev vfio kvm hid_logitech_hidpp irqbypass i2c_algo_bit drm_kms_he
 lper drm
[  +0.000032]  crc32c_intel wmi video hid_logitech_dj
[  +0.000005] CR2: 0000000000000000
[  +0.000016] ---[ end trace afe2e7ddfac01670 ]---
[  +0.000004] RIP: 0010:gss_verify_mic_kerberos+0x73/0x300 [rpcsec_gss_krb5]
[  +0.000002] Code: 00 0f 84 a7 02 00 00 48 8d 44 24 34 4c 8b 62 08 c7 44 24 20 14 00 00 00 48 89 44 24 28 f6 05 9f f8 d2 ff 10 0f 85 95 3a 00 00 <66> 41 81 3c 24 04 04 41 bd 00 00 09 00 0f 85 b3 00 00 00 41 0f b6
[  +0.000001] RSP: 0018:ffff97f702afb748 EFLAGS: 00010246
[  +0.000002] RAX: ffff97f702afb77c RBX: ffff8a69b3945600 RCX: 0000000000000012
[  +0.000002] RDX: ffff97f702afb7c0 RSI: ffff97f702afb7d0 RDI: ffff8a69a4bafe20
[  +0.000001] RBP: ffff97f702afb7d0 R08: 00000000000002f4 R09: ffff8a69b38e9780
[  +0.000001] R10: ffff8a690ddfcf98 R11: 0000000035e353de R12: 0000000000000000
[  +0.000002] R13: 0000000000000000 R14: 0000000000000b14 R15: ffff8a6991c68660
[  +0.000002] FS:  00007f2f9785de00(0000) GS:ffff8a6a4f800000(0000) knlGS:0000000000000000
[  +0.000001] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  +0.000001] CR2: 0000000000000000 CR3: 0000000348fee004 CR4: 00000000001606f0
[  +0.000002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  +0.000001] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
