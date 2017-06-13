Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:60391 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751834AbdFMIym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 04:54:42 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 966C2280713
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 10:54:40 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 142F7103D
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 10:54:38 +0200 (MEST)
Date: Tue, 13 Jun 2017 10:54:38 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1979869655.13995414.1497344078055.JavaMail.zimbra@desy.de>
Subject: kernel reports BUG
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I was running long load test, which have prodiced OOM. Kernel
have decided to kill my server. Related or not, this is what I got
in the log file:


[84638.461109] ------------[ cut here ]------------
[84638.461113] kernel BUG at fs/inode.c:566!
[84638.461118] invalid opcode: 0000 [#1] SMP
[84638.461141] Modules linked in: bnep nfnetlink_queue nfnetlink_log bluetooth ecdh_generic nfs_layout_nfsv41_files nfsv3 nfs_acl nfs_layout_flexfiles rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache xt_multiport nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_raw ip6table_mangle ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_raw iptable_mangle iptable_security ebtable_filter ebtables ip6table_filter ip6_tables binfmt_misc sunrpc snd_hda_codec_hdmi intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp arc4 kvm_intel kvm iwldvm
[84638.461354]  btrfs snd_hda_codec_idt mac80211 snd_hda_codec_generic irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_cstate intel_uncore xor iTCO_wdt mei_wdt iTCO_vendor_support ppdev dell_wmi sparse_keymap uvcvideo iwlwifi snd_hda_intel dell_rbtn snd_hda_codec videobuf2_vmalloc dell_laptop dell_smbios videobuf2_memops dcdbas snd_hda_core videobuf2_v4l2 dell_smm_hwmon cfg80211 snd_hwdep videobuf2_core snd_seq videodev snd_seq_device snd_pcm media snd_timer intel_rapl_perf raid6_pq joydev pcspkr i2c_i801 lpc_ich snd rfkill mei_me parport_pc soundcore mei parport 8250_pci tpm_tis shpchp dell_smo8800 tpm_tis_core tpm i915 nouveau mxm_wmi ttm i2c_algo_bit drm_kms_helper crc32c_intel e1000e drm serio_raw sdhci_pci firewire_ohci sdhci firewire_core mmc_core crc_itu_t ptp pps_core wmi video
[84638.461574] CPU: 1 PID: 32600 Comm: umount.nfs4 Not tainted 4.12.0-0.rc4.git3.1.vanilla.knurd.1.fc25.x86_64 #1
[84638.461604] Hardware name: Dell Inc. Latitude E6520/0J4TFW, BIOS A06 07/11/2011
[84638.461626] task: ffff91bb7a4b25c0 task.stack: ffffb7678ae4c000
[84638.461647] RIP: 0010:evict+0x1b0/0x1c0
[84638.461660] RSP: 0018:ffffb7678ae4fd70 EFLAGS: 00010202
[84638.461677] RAX: 0000000000000000 RBX: ffff91b97cfe4ef0 RCX: 0000000000000000
[84638.461698] RDX: ffffffffb7e05e40 RSI: ffff91b97cfe4f90 RDI: ffffffffb7e05e38
[84638.461719] RBP: ffffb7678ae4fd88 R08: ffff91b94c86bc80 R09: 00000001802a0022
[84638.461740] R10: ffffb7678ae4fc68 R11: 0000000000000000 R12: ffff91b97cfe5010
[84638.461761] R13: ffffffffc0efa8e0 R14: ffff91bb60ae2000 R15: ffff91b97cfe4ef0
[84638.461784] FS:  00007f9ae918ad00(0000) GS:ffff91bb7d240000(0000) knlGS:0000000000000000
[84638.461807] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[84638.461824] CR2: 00007ffcc6dff4f8 CR3: 0000000200b61000 CR4: 00000000000406e0
[84638.461846] Call Trace:
[84638.461858]  dispose_list+0x4d/0x70
[84638.461871]  evict_inodes+0x178/0x1a0
[84638.461885]  generic_shutdown_super+0x44/0x110
[84638.461909]  nfs_kill_super+0x21/0x40 [nfs]
[84638.461923]  deactivate_locked_super+0x43/0x70
[84638.461937]  deactivate_super+0x4e/0x60
[84638.461951]  cleanup_mnt+0x3f/0x80
[84638.461963]  __cleanup_mnt+0x12/0x20
[84638.461977]  task_work_run+0x80/0xa0
[84638.461990]  exit_to_usermode_loop+0xaa/0xb0
[84638.462004]  syscall_return_slowpath+0x8f/0xa0
[84638.462020]  entry_SYSCALL_64_fastpath+0xa3/0xa5
[84638.462035] RIP: 0033:0x7f9ae885cfe7
[84638.462047] RSP: 002b:00007ffcc6e01b88 EFLAGS: 00000246 ORIG_RAX: 00000000000000a6
[84638.462070] RAX: 0000000000000000 RBX: 0000556fa6373010 RCX: 00007f9ae885cfe7
[84638.462091] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000556fa637b120
[84638.462113] RBP: 0000556fa637b120 R08: 0000000000000000 R09: 0000000000000000
[84638.462133] R10: 00000000000000f7 R11: 0000000000000246 R12: 00007f9ae8d63184
[84638.462155] R13: 0000000000000000 R14: 0000556fa63731f0 R15: 0000556fa63750a0
[84638.462177] Code: ff 48 89 df e8 e2 5d fe ff e9 43 ff ff ff 48 8d bb 78 01 00 00 e8 c1 9b f5 ff 48 89 df e8 b9 ee ff ff e9 0f ff ff ff 0f 0b 0f 0b <0f> 0b 0f 1f 40 00 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 
[84638.462247] RIP: evict+0x1b0/0x1c0 RSP: ffffb7678ae4fd70
[84638.472950] ---[ end trace d844913b3c2a9664 ]---


Regards,
   Tigran.
