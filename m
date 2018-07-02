Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:43713 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbeGBQT2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2018 12:19:28 -0400
Received: by mail-oi0-f52.google.com with SMTP id b15-v6so3238240oib.10
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jul 2018 09:19:28 -0700 (PDT)
MIME-Version: 1.0
From: Sverd Johnsen <sverd.johnsen@googlemail.com>
Date: Mon, 2 Jul 2018 18:19:26 +0200
Message-ID: <CAGmahrR9mkcGLB7+7=MK=7BbkpRZ3jQySy-AVnSOsMe3F4VXow@mail.gmail.com>
Subject: general protection fault: 0000 [#1] SMP PTI [...] ?
 nfs4_free_openowner+0x10/0x10 [nfsd] [...] RIP: kmem_cache_alloc+0x87/0x130
 RSP: ffffb6e7016f3c80
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hmm i hit this twice now. what should i look into?

nfsd4_validate_stateid: 157 callbacks suppressed
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
NFSD: client 192.168.21.44 testing state ID with incorrect client ID
general protection fault: 0000 [#1] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8843 Comm: nfsd Tainted: G        W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x87/0x130
RSP: 0018:ffffb6e7016f3c80 EFLAGS: 00010282
RAX: 0000000000000000 RBX: 823bf2748e3216e0 RCX: 000000000000215f
RDX: 000000000000215e RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: ffff936faf650d9b R09: 7dc4611b21571b7b
R10: ffff936f00bca448 R11: 0000000000000000 R12: ffff936faf650d9b
R13: 00000000014080c0 R14: ffff936f00bca420 R15: ffff937046515150
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: e0 4d 01 e0 4d 8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65
48 0f c7 0f 0f 94 c0 84 c0 74 b5 4d 39 c8 74 13 8b 45 20 48 01 c3 <48>
33 1b 48 33 9d 38 01 00 00 0f 18 0b 41 81 e5 00 80 00 00 75
RIP: kmem_cache_alloc+0x87/0x130 RSP: ffffb6e7016f3c80
---[ end trace 335af70e482fcb0f ]---
general protection fault: 0000 [#2] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8840 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e70167bc80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: 0000000000000000
R10: ffff936f00bcb2b8 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bcb290 R15: ffff937046515000
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e70167bc80
---[ end trace 335af70e482fcb10 ]---
general protection fault: 0000 [#3] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8842 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e7016e3c80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: 0000000000000000
R10: ffff936f00bcaa78 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bcaa50 R15: ffff9370465159d8
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e7016e3c80
---[ end trace 335af70e482fcb11 ]---
general protection fault: 0000 [#4] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8844 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e7016fbc80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: 0000000000000000
R10: ffff936f00bcafa0 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bcaf78 R15: ffff937046515348
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e7016fbc80
---[ end trace 335af70e482fcb12 ]---
general protection fault: 0000 [#5] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8838 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e701653c80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: ffff936f5a62a6c8
R10: ffff936f00bca448 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bca420 R15: ffff937046515150
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 nfsd4_open+0x574/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e701653c80
---[ end trace 335af70e482fcb13 ]---
general protection fault: 0000 [#6] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8841 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e7016d3c80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: 0000000000000000
R10: ffff936f00bcad90 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bcad68 R15: ffff937046515bd0
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e7016d3c80
---[ end trace 335af70e482fcb14 ]---
audit: type=1006 audit(1530547550.600:1694): pid=337 uid=0
old-auid=4294967295 auid=1000 tty=(none) old-ses=4294967295 ses=181
res=1
general protection fault: 0000 [#7] SMP PTI
Modules linked in: nfnetlink_queue nfnetlink_log md5
nf_conntrack_netlink tcp_diag udp_diag inet_diag unix_diag
af_packet_diag netlink_diag rpcsec_gss_krb5 sch_fq nfsd lockd
auth_rpcgss grace sunrpc nls_iso8859_1 nls_cp437 lz4 lz4_compress
lz4_decompress zram zsmalloc veth xfs esp4 xfrm6_mode_tunnel
xfrm4_mode_tunnel chacha20_x86_64 chacha20_generic poly1305_x86_64
poly1305_generic chacha20poly1305 macsec deadline_iosched overlay
dm_cache_smq dm_cache dm_bio_prison dm_persistent_data raid10 md_mod
af_packet bonding nft_reject_inet nf_reject_ipv4 nf_reject_ipv6
nft_reject nf_log_ipv6 nf_log_ipv4 nf_log_common nft_limit nft_log
cls_u32 nft_counter cls_fw nf_conntrack_ipv6 nf_defrag_ipv6 xfrm_user
nf_conntrack_ipv4 xfrm_algo nf_defrag_ipv4 sch_prio sch_htb 8021q
nft_ct nf_conntrack nft_meta
 nft_set_bitmap nft_set_hash nft_set_rbtree ax88179_178a uas plusb
usbnet input_leds usb_storage led_class joydev x86_pkg_temp_thermal
intel_powerclamp kvm_intel vhost_net tun vhost tap kvm bcache tpm_tis
irqbypass tpm_tis_core tpm wdat_wdt pcspkr lpc_ich mei_me mei rng_core
shpchp fan pinctrl_broxton pinctrl_intel msr algif_skcipher af_alg
crct10dif_pclmul crc32_pclmul efi_pstore ghash_clmulni_intel efivars
atkbd libps2 i915 video backlight button intel_gtt i2c_algo_bit
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfat
fat dm_integrity dm_bufio async_xor async_tx efivarfs [last unloaded:
tcp_bic]
CPU: 3 PID: 8839 Comm: nfsd Tainted: G      D W  O      4.17.2-2-itx #2
Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./J3455-ITX, BIOS P1.40 07/14/2017
RIP: 0010:kmem_cache_alloc+0x60/0x130
RSP: 0018:ffffb6e701663c80 EFLAGS: 00010282
RAX: 823bf2748e3216e0 RBX: 0000000000000000 RCX: 0000000000002160
RDX: 000000000000215f RSI: 00000000014080c0 RDI: 0000000000025620
RBP: ffff93726d0b0f00 R08: 823bf2748e3216e0 R09: 0000000000000000
R10: ffff936f00bca868 R11: 0000000000000000 R12: 823bf2748e3216e0
R13: 00000000014080c0 R14: ffff936f00bca840 R15: ffff937046515690
FS:  0000000000000000(0000) GS:ffff93727fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c42090d000 CR3: 00000003ce008000 CR4: 00000000003426e0
Call Trace:
 ? nfs4_free_openowner+0x10/0x10 [nfsd]
 nfs4_alloc_stid+0x1c/0xa0 [nfsd]
 nfsd4_process_open2+0xdec/0x1190 [nfsd]
 ? nfsd_permission+0x5e/0xf0 [nfsd]
 ? fh_verify+0x16a/0x550 [nfsd]
 ? nfsd4_process_open1+0x168/0x410 [nfsd]
 nfsd4_open+0x271/0x600 [nfsd]
 ? nfsd4_decode_notsupp+0x10/0x10 [nfsd]
 nfsd4_proc_compound+0x30e/0x620 [nfsd]
 nfsd_dispatch+0xae/0x1a0 [nfsd]
 svc_process_common.isra.5+0x406/0x5b0 [sunrpc]
 svc_process+0xd0/0xe0 [sunrpc]
 nfsd+0xde/0x140 [nfsd]
 kthread+0x106/0x120
 ? nfsd_destroy+0x50/0x50 [nfsd]
 ? kthread_flush_work_fn+0x10/0x10
 ret_from_fork+0x35/0x40
Code: 65 48 8b 50 08 65 48 03 05 26 70 e7 6d 4c 8b 20 4d 85 e4 0f 84
9f 00 00 00 44 8b 45 20 48 8d 4a 01 48 8b 7d 00 4c 89 e0 4d 01 e0 <4d>
8b 08 4c 89 c3 4c 33 8d 38 01 00 00 4c 31 cb 65 48 0f c7 0f
RIP: kmem_cache_alloc+0x60/0x130 RSP: ffffb6e701663c80
---[ end trace 335af70e482fcb15 ]---
audit: type=1006 audit(1530547779.784:1695): pid=575 uid=0
old-auid=4294967295 auid=1000 tty=(none) old-ses=4294967295 ses=182
res=1
