Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35235 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753807AbdDMSAE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Apr 2017 14:00:04 -0400
Received: by mail-io0-f171.google.com with SMTP id r16so86742388ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Apr 2017 11:00:03 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 13 Apr 2017 14:00:02 -0400
Message-ID: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
Subject: RFC: fixing kernel oops on interrupted COMMIT from nfs_commit_file
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Looking for suggestions on how to fix a kernel oops.

It's possible that there is a ctrl-c when the COMMIT is send. In case
of the COPY, it calls
nfs_commit_file() which calls wait_on_commit() that is interrupted by
the crtl-c and frees the nfs_page request. So when asynchronous COMMIT
rpc comes back it tried to use the nfs_page request and gets the oops.

I think typical uses of nfs_commit_inode() are never interruptible at
least I wasn't able to trigger it.

The only way I can think of fixing the problem is to change
wait_on_commit() from a TASK_KILLABLE to TASK_UNINTERRUPTIBLE but I'm
not sure if this is the right solution

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a..aefff49 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1557,7 +1557,7 @@ static void nfs_writeback_result(struct rpc_task *task,
 static int wait_on_commit(struct nfs_mds_commit_info *cinfo)
 {
  return wait_on_atomic_t(&cinfo->rpcs_out,
- nfs_wait_atomic_killable, TASK_KILLABLE);
+ nfs_wait_atomic_killable, TASK_UNINTERRUPTIBLE);
 }

 static void nfs_commit_begin(struct nfs_mds_commit_info *cinfo)

[  207.717883] BUG: unable to handle kernel NULL pointer dereference
at           (null)
[  207.720748] IP: __list_del_entry_valid+0x29/0xd0
[  207.722079] PGD 0
[  207.722080]
[  207.723167] Oops: 0000 [#1] SMP
[  207.723988] Modules linked in: nfsv4 dns_resolver nfs rfcomm fuse
xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter
ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack
ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
libcrc32c iptable_mangle iptable_security iptable_raw ebtable_filter
ebtables ip6table_filter ip6_tables iptable_filter bnep
vmw_vsock_vmci_transport vsock dm_mirror dm_region_hash dm_log dm_mod
snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel pcbc btusb btrtl btbcm btintel snd_ens1371
aesni_intel snd_ac97_codec ppdev ac97_bus
[  207.741809]  crypto_simd snd_seq cryptd glue_helper bluetooth
uvcvideo vmw_balloon pcspkr snd_pcm videobuf2_vmalloc videobuf2_memops
videobuf2_v4l2 videobuf2_core videodev snd_rawmidi snd_timer nfit
snd_seq_device snd libnvdimm sg rfkill soundcore vmw_vmci shpchp
i2c_piix4 parport_pc parport nfsd acpi_cpufreq auth_rpcgss nfs_acl
lockd grace sunrpc ip_tables ext4 jbd2 mbcache sr_mod cdrom sd_mod
ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect
sysimgblt fb_sys_fops ttm drm ahci libahci ata_piix crc32c_intel
libata mptspi scsi_transport_spi serio_raw mptscsih e1000 mptbase
i2c_core
[  207.757915] CPU: 0 PID: 95 Comm: kworker/0:2 Not tainted 4.11.0-rc5+ #110
[  207.759797] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  207.762838] Workqueue: nfsiod rpc_async_release [sunrpc]
[  207.764355] task: ffff88007a7ada00 task.stack: ffffc90002c08000
[  207.766047] RIP: 0010:__list_del_entry_valid+0x29/0xd0
[  207.767516] RSP: 0018:ffffc90002c0bd98 EFLAGS: 00010207
[  207.769026] RAX: ffff88007472cc80 RBX: ffff88007472d500 RCX: ffff88007b61aae0
[  207.771273] RDX: dead000000000200 RSI: ffff880079782c40 RDI: ffff88007472d500
[  207.773887] RBP: ffffc90002c0bd98 R08: 0000000000000000 R09: ffff88007955b2b8
[  207.775276] R10: ffff88007955b2f0 R11: ffffea0001bf8200 R12: ffff880079782c00
[  207.776649] R13: 0000000000000000 R14: ffff880079782dd8 R15: ffff880079782dc8
[  207.778087] FS:  0000000000000000(0000) GS:ffff88007b600000(0000)
knlGS:0000000000000000
[  207.780238] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  207.781485] CR2: 0000000000000000 CR3: 0000000072c0b000 CR4: 00000000001406f0
[  207.782995] Call Trace:
[  207.783603]  nfs_commit_release_pages+0x98/0x240 [nfs]
[  207.784756]  nfs_commit_release+0x16/0x30 [nfs]
[  207.785687]  rpc_free_task+0x30/0x70 [sunrpc]
[  207.786580]  rpc_async_release+0x12/0x20 [sunrpc]
[  207.787747]  process_one_work+0x165/0x410
[  207.789456]  worker_thread+0x137/0x4c0
[  207.791053]  kthread+0x101/0x140
[  207.792164]  ? rescuer_thread+0x3b0/0x3b0
[  207.793345]  ? kthread_park+0x90/0x90
[  207.794407]  ret_from_fork+0x2c/0x40
[  207.795431] Code: 00 00 55 48 8b 07 48 ba 00 01 00 00 00 00 ad de
4c 8b 47 08 48 89 e5 48 39 d0 74 27 48 ba 00 02 00 00 00 00 ad de 49
39 d0 74 7e <4d> 8b 00 4c 39 c7 75 55 4c 8b 40 08 4c 39 c7 75 2b b8 01
00 00
[  207.800010] RIP: __list_del_entry_valid+0x29/0xd0 RSP: ffffc90002c0bd98
[  207.801524] CR2: 0000000000000000
[  207.802302] ---[ end trace 4b559c9b50350277 ]---
[  207.803242] Kernel panic - not syncing: Fatal exception
[  207.805361] Kernel Offset: disabled
[  207.806434] ---[ end Kernel panic - not syncing: Fatal exception
