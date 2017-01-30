Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36848 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753074AbdA3USf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2017 15:18:35 -0500
Received: by mail-it0-f68.google.com with SMTP id f200so1652831itf.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2017 12:18:35 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 30 Jan 2017 15:18:34 -0500
Message-ID: <CAN-5tyFDssw65H4r6bzOiny-4W_s1etk=t7iRgbyQFeJZyE9yA@mail.gmail.com>
Subject: upstream nfsd kernel oops in auth_rpcgss
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I ran into this oops in the nfsd (below) (4.10-rc3 kernel). To trigger
this I had a client (unsuccessfully) try to mount the server with krb5
where the server doesn=E2=80=99t have the rpcsec_gss_krb5 module built.

Below code seems to fix things:

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
b/net/sunrpc/auth_gss/svcauth_gss.c
index 886e9d38..7faffd8 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1187,9 +1187,9 @@ static int gss_proxy_save_rsc(struct cache_detail *cd=
,
  status =3D -EOPNOTSUPP;
  /* get mech handle from OID */
  gm =3D gss_mech_get_by_OID(&ud->mech_oid);
+ rsci.cred.cr_gss_mech =3D gm;
  if (!gm)
  goto out;
- rsci.cred.cr_gss_mech =3D gm;



  status =3D -EINVAL;
  /* mech-specific data: */

I guess the problem is because rsci.cred gets initialed from something
that=E2=80=99s passed in that doesn=E2=80=99t have it=E2=80=99s cr_gss_mech=
 initialized to
NULL. So when gss_mech_get_by_OID() fails and it calls rsc_free() and
tries to free a bad pointer.


Don=E2=80=99t know if this is acceptable or it should be traced to where th=
e
uninitialized pointer is coming from.

If this approach is ok, I can re-send this as a patch.

[120408.542387] general protection fault: 0000 [#1] SMP
[120408.544273] Modules linked in: nfsd nfs_acl nfsv4 dns_resolver nfs
lockd auth_rpcgss grace fscache sunrpc fuse ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT
nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack
nf_conntrack snd_seq_midi snd_seq_midi_event ebtable_nat
ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle
ip6table_security ip6table_raw ip6table_filter ip6_tables
iptable_mangle iptable_security iptable_raw rfcomm iptable_filter bnep
ip_tables coretemp crc32_pclmul crc32c_intel ghash_clmulni_intel btusb
btrtl btbcm btintel bluetooth rfkill snd_ens1371 snd_ac97_codec ppdev
ac97_bus snd_seq aesni_intel crypto_simd cryptd glue_helper uvcvideo
videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core
snd_pcm pcspkr serio_raw
[120408.558655]  videodev snd_rawmidi snd_timer snd_seq_device snd
soundcore vmw_vmci shpchp i2c_piix4 parport_pc parport acpi_cpufreq
uinput xfs libcrc32c sr_mod sd_mod cdrom ata_generic pata_acpi vmwgfx
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm
ata_piix e1000 ahci libahci libata mptspi scsi_transport_spi mptscsih
mptbase i2c_core dm_mirror dm_region_hash dm_log dm_mod
[120408.565724] CPU: 0 PID: 3601 Comm: nfsd Not tainted 4.10.0-rc3+ #16
[120408.567037] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[120408.569225] task: ffff8800776f95c0 task.stack: ffffc90003d58000
[120408.570483] RIP: 0010:gss_mech_put+0xb/0x20 [auth_rpcgss]
[120408.571614] RSP: 0018:ffffc90003d5bb78 EFLAGS: 00010206
[120408.572731] RAX: ffff880072ecc301 RBX: ffffc90003d5bba8 RCX:
00000000003d0040
[120408.574240] RDX: 00000000003d003f RSI: 0000000000000246 RDI:
4f432e4553554f48
[120408.575685] RBP: ffffc90003d5bb90 R08: 000000000001b2c0 R09:
ffffffffa0703e0c
[120408.577149] R10: ffff88007b61b2c0 R11: ffffea0001cbb300 R12:
ffff8800730c1500
[120408.578592] R13: 00000000ffffffa1 R14: ffff880073a94b40 R15:
ffff880074e0d600
[120408.580058] FS:  0000000000000000(0000) GS:ffff88007b600000(0000)
knlGS:0000000000000000
[120408.581708] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[120408.582889] CR2: 00007fe3980140b8 CR3: 000000006f063000 CR4:
00000000001406f0
[120408.584395] Call Trace:
[120408.584946]  ? rsc_free+0x55/0x90 [auth_rpcgss]
[120408.585901]  gss_proxy_save_rsc+0xb2/0x2a0 [auth_rpcgss]
[120408.587017]  svcauth_gss_proxy_init+0x3cc/0x520 [auth_rpcgss]
[120408.588257]  ? __enqueue_entity+0x6c/0x70
[120408.589101]  svcauth_gss_accept+0x391/0xb90 [auth_rpcgss]
[120408.590212]  ? try_to_wake_up+0x4a/0x360
[120408.591036]  ? wake_up_process+0x15/0x20
[120408.592093]  ? svc_xprt_do_enqueue+0x12e/0x2d0 [sunrpc]
[120408.593177]  svc_authenticate+0xe1/0x100 [sunrpc]
[120408.594168]  svc_process_common+0x203/0x710 [sunrpc]
[120408.595220]  svc_process+0x105/0x1c0 [sunrpc]
[120408.596278]  nfsd+0xe9/0x160 [nfsd]
[120408.597060]  kthread+0x101/0x140
[120408.597734]  ? nfsd_destroy+0x60/0x60 [nfsd]
[120408.598626]  ? kthread_park+0x90/0x90
[120408.599448]  ret_from_fork+0x22/0x30
[120408.600232] Code: 0f 1f 44 00 00 55 48 89 e5 53 48 89 fb 48 8b 7f
10 e8 9a 0a 9f e0 48 89 d8 5b 5d c3 0f 1f 40 00 0f 1f 44 00 00 48 85
ff 74 0e 55 <48> 8b 7f 10 48 89 e5 e8 d9 f6 9e e0 5d f3 c3 66 0f 1f 44
00 00
[120408.604123] RIP: gss_mech_put+0xb/0x20 [auth_rpcgss] RSP: ffffc90003d5b=
b78
[120408.607012] ---[ end trace 473ba7f734debac4 ]---
[120408.608027] Kernel panic - not syncing: Fatal exception
[120408.609268] Kernel Offset: disabled
[120408.610027] ---[ end Kernel panic - not syncing: Fatal exception
