From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Subject: [PATCH] sunrpc: cleanup pipefs child entries before we call
 rmdir
Date: Fri, 08 Jan 2010 00:44:23 +0530
Message-ID: <4B46328F.3030001@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60174 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570Ab0AGTO3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 14:14:29 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id F3C8E8E8CC
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jan 2010 20:14:27 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a reported kernel BUG being triggered when the NFS server shuts down
while having a krb5p mount on 2.6.31 (but it seems the code in question hasn't
changed):

Oct 19 00:25:36 localhost kernel: [22216.254674] BUG: Dentry e30d9114{i=b5,n=krb5} still in use (1) [unmount of rpc_pipefs rpc_pipefs]
Oct 19 00:25:36 localhost kernel: [22216.254769] ------------[ cut here ]------------
Oct 19 00:25:36 localhost kernel: [22216.254786] kernel BUG at /usr/src/packages/BUILD/kernel-desktop-2.6.31.3/linux-2.6.31/fs/dcache.c:669!
Oct 19 00:25:36 localhost kernel: [22216.254807] invalid opcode: 0000 [#1] PREEMPT SMP Oct 19 00:25:36 localhost kernel: [22216.254825] last sysfs file: /sys/devices/pci0000:00/0000:00:07.0/0000:3f:00.0/net/eth0/type
Oct 19 00:25:36 localhost kernel: [22216.254842] Modules linked in: zl10353 zl10036 ves1x93 ves1820 tua6100 tda826x tda8261 tda8083 tda10086 tda1004x tda10048 tda10023 tda10021 stv6110 stv0900 stv0299 stv0297 stv0288 stb6100 stb6000 stb0899 sp887x sp8870 si21xx s5h1411 s5h1409 or51211 or51132 nxt6000 nxt200x mt352 mt312 lnbp21 lgs8gl5 lgdt330x lgdt3305 l64781 isl6405 dvb_pll dib7000p dib7000m dib3000mc dibx000_common dib3000mb dib0070 cx24116 cx24110 cx22702 cx22700 bcm3510 au8522 af9013 dvb_ttpci nvidia(P) md5 des_generic cbc cryptomgr aead pcompress crypto_blkcipher crypto_hash crypto_algapi nls_utf8 ipt_LOG xt_limit ipt_REJECT xt_tcpudp xt_state iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables autofs4 snd_pcm_oss snd_mixer
 _oss snd_seq snd_seq_device rpcsec_gss_krb5 nfs lockd fscache nfs_acl auth_rpcgss sunrpc cpufreq_conservative cpufreq_userspace cpufreq_powersave powernow_k8 v4l2_common saa7146_vv videodev 
v4l1_compat saa7146 videobuf_dma_sg vide
Oct 19 00:25:36 localhost kernel: obuf_core ttpci_eeprom fuse loop dm_mod itd1000 isl6421 snd_hda_codec_realtek ppdev b2c2_flexcop_pci b2c2_flexcop dvb_core cx24123 parport_pc snd_hda_intel sr_mod cx24113 wmi parport sg floppy i2c_piix4 cdrom s5h1420 ati_agp snd_hda_codec tg3 snd_hwdep button serio_raw pcspkr snd_pcm snd_timer snd snd_page_alloc kvm k8temp edd pata_acpi sata_sil reiserfs fan processor ide_pci_generic atiixp ide_core ata_generic thermal thermal_sys pata_atiixp [last unloaded: nvidia]
Oct 19 00:25:36 localhost kernel: [22216.255260] Oct 19 00:25:36 localhost kernel: [22216.255260] Pid: 32767, comm: umount Tainted: P           (2.6.31.3-1-desktop #1) HP Compaq dc5750 Microtower
Oct 19 00:25:36 localhost kernel: [22216.255260] EIP: 0060:[<c0326e71>] EFLAGS: 00010246 CPU: 1
Oct 19 00:25:36 localhost kernel: [22216.255260] EIP is at shrink_dcache_for_umount_subtree+0x211/0x220
Oct 19 00:25:36 localhost kernel: [22216.255260] EAX: 0000006b EBX: e30d9114 ECX: c022d4a0 EDX: 00000000
Oct 19 00:25:36 localhost kernel: [22216.255260] ESI: 00000001 EDI: f8d9ac8c EBP: f25e3ef8 ESP: f25e3ec8
Oct 19 00:25:36 localhost kernel: [22216.255260]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Oct 19 00:25:36 localhost kernel: [22216.255260] Process umount (pid: 32767, ti=f25e2000 task=f1d82d40 task.ti=f25e2000)
Oct 19 00:25:36 localhost kernel: [22216.255260] Stack:
Oct 19 00:25:36 localhost kernel: [22216.255260]  c07c64dc e30d9114 000000b5 e30d9170 00000001 f8d9ac8c f24e6578 e30d9170
Oct 19 00:25:36 localhost kernel: [22216.255260] <0> 97801773 f24e6400 f8db1b60 c035cac0 f25e3f08 c0326eb6 97801773 f24e6400
Oct 19 00:25:36 localhost kernel: [22216.255260] <0> f25e3f24 c0314ec6 c0690ac1 97801773 97801773 00000014 f8db1b40 f25e3f34
Oct 19 00:25:36 localhost kernel: [22216.255260] Call Trace:
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c0326eb6>] shrink_dcache_for_umount+0x36/0x70
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c0314ec6>] generic_shutdown_super+0x26/0xf0
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c031500b>] kill_anon_super+0x1b/0x70
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c0315087>] kill_litter_super+0x27/0x40
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c0315d25>] deactivate_super+0x75/0xb0
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c032d14f>] mntput_no_expire+0x8f/0xf0
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c032d7e1>] sys_umount+0x51/0xb0
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c032d864>] sys_oldumount+0x24/0x40
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<c02040f3>] sysenter_do_call+0x12/0x28
Oct 19 00:25:36 localhost kernel: [22216.255260]  [<ffffe424>] 0xffffe424
Oct 19 00:25:36 localhost kernel: [22216.255260] Code: 78 01 00 00 89 54 24 18 8b 55 ec 89 7c 24 14 89 74 24 10 89 5c 24 04 89 54 24 0c 89 44 24 08 c7 04 24 dc 64 7c c0 e8 49 6a 36 00 <0f> 0b eb fe 0f 0b eb fe e8 22 98 f2 ff 66 90 55 89 e5 53 89 c3 Oct 19 00:25:36 localhost kernel: [22216.255260] EIP: [<c0326e71>] shrink_dcache_for_umount_subtree+0x211/0x220 SS:ESP 0068:f25e3ec8
Oct 19 00:25:36 localhost kernel: [22216.256395] ---[ end trace 30fff389148267ac ]---

It appears to be a dentry reference counting problem reproducible when we
have krb5 mounts. The patch below appears to have fixed the issue by making
sure we cleanup pipefs child entries. However, I'm not too sure about this
fix and would appreciate more eyeballs.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 net/sunrpc/rpc_pipe.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 49278f8..a2330c8 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,7 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/dcache.h>
  #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -533,6 +534,7 @@ static int __rpc_rmdir(struct inode *dir, struct dentry *dentry)
 	int ret;
  	dget(dentry);
+	shrink_dcache_parent(dentry);
 	ret = simple_rmdir(dir, dentry);
 	d_delete(dentry);
 	dput(dentry);

