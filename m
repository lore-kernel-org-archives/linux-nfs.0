Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:43189 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab3LRCMd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Dec 2013 21:12:33 -0500
Received: from mfilter9-d.gandi.net (mfilter9-d.gandi.net [217.70.178.138])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id 61CFFA80B1
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 03:12:30 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([217.70.183.195])
	by mfilter9-d.gandi.net (mfilter9-d.gandi.net [10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id rmIK+tkJTeOc for <linux-nfs@vger.kernel.org>;
	Wed, 18 Dec 2013 03:12:28 +0100 (CET)
Received: from [192.168.1.100] (108-197-34-253.lightspeed.sndgca.sbcglobal.net [108.197.34.253])
	(Authenticated sender: alex@alexforencich.com)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 427A6A808E
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 03:12:25 +0100 (CET)
Message-ID: <52B10487.8080804@alexforencich.com>
Date: Tue, 17 Dec 2013 18:12:23 -0800
From: Alex Forencich <alex@alexforencich.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS unmount causes system hang
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I may have found a bug in NFS unmount that causes a system hang. 

I have a home server that I just set up recently that runs Arch linux. 
It exports a couple of external hard drives via NFS.  I have been
mouting them with autofs on my laptop.  However, after several hours the
entire system completely hangs up.  I originally thought it had
something to do with the rpc-gssd daemon that the Arch Linux NFS wiki
page recommends running as it was dying in a strange way and I thought
that may have been related to the hang ups.  After implementing a
different workaround (blacklist rpcsec_gss_krb5) and disabling rpc-gssd,
I am still having the same hang issue. 

Here is what happens:

I boot up my computer, start Firefox, Thunderbird, various terminals,
etc.  I mount the NFS share with autofs by opening up the
/media/net/atomic/qx2_data directory.  After a while, the NFS mounts in
Thunar start disappering momentarily and then reappearing.  Then a
little while later the system completely hangs and requires a hard
reboot.  The end of the log from journalctl is posted below. 

Right now I have disabled autofs and I will only mount the drives on the
server via SFTP to avoid this problem, but I would really like to get
this debugged.  Also, this is not likely related to any sort of a
connection issue as both computers are hardwired to the same Gigabit
Ethernet switch. 

I posted this to the Arch Linux forum here:
https://bbs.archlinux.org/viewtopic.php?pid=1361402 and a user replied
saying this is a bug in NFS unmount.  I can add try to collect more
debug information if necessary. 

/etc/autofs/auto.net:

|atomic -fstype=nfs4,rw,async,sec=sys,bg,intr atomic.local:/|

uname -a:

|Linux watatsumi 3.12.5-1-ARCH #1 SMP PREEMPT Thu Dec 12 12:57:31 CET 2013 x86_64 GNU/Linux|

Log:

|Dec 17 16:33:35 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:34:51 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:36:07 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:37:23 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:38:35 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:39:51 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:41:07 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:42:23 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:43:39 watatsumi automount[19747]: key ".hidden" not found in map source(s).
Dec 17 16:45:16 watatsumi kernel: BUG: soft lockup - CPU#5 stuck for 23s! [htop:2505]
Dec 17 16:45:16 watatsumi kernel: Modules linked in: usbtmc auth_rpcgss oid_registry nfsv4 tun joydev snd_hda_codec_hdmi x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crct10dif_common crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd fuse nvidia(PO) iTCO_wdt iTCO_vendor_support uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core snd_usb_audio videodev snd_usbmidi_lib snd_rawmidi media snd_seq_device arc4 evdev microcode psmouse serio_raw iwldvm mac80211 snd_hda_codec_realtek iwlwifi snd_hda_intel snd_hda_codec cfg80211 snd_hwdep drm snd_pcm jme jmb38x_ms rfkill mii snd_page_alloc memstick snd_timer i2c_i801 mei_me snd i2c_core soundcore mei thermal shpchp wmi lpc_ich processor battery ac button video pcspkr nfs lockd
Dec 17 16:45:16 watatsumi kernel:  sunrpc fscache ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci firewire_ohci sdhci_pci xhci_hcd scsi_mod ehci_hcd sdhci firewire_core crc_itu_t mmc_core usbcore usb_common
Dec 17 16:45:16 watatsumi kernel: CPU: 5 PID: 2505 Comm: htop Tainted: P           O 3.12.5-1-ARCH #1
Dec 17 16:45:16 watatsumi kernel: Hardware name: CLEVO                             P150HMx/P150HMx, BIOS 4.6.4 08/09/2011
Dec 17 16:45:16 watatsumi kernel: task: ffff880801678000 ti: ffff8807dcbec000 task.ti: ffff8807dcbec000
Dec 17 16:45:16 watatsumi kernel: RIP: 0010:[<ffffffff814f4f8e>]  [<ffffffff814f4f8e>] _raw_spin_lock+0x2e/0x40
Dec 17 16:45:16 watatsumi kernel: RSP: 0018:ffff8807dcbedd88  EFLAGS: 00000297
Dec 17 16:45:16 watatsumi kernel: RAX: 0000000000000082 RBX: ffffffff81299133 RCX: 0000000000000000
Dec 17 16:45:16 watatsumi kernel: RDX: 0000000000000083 RSI: ffffffff8172447b RDI: ffffffff818063c0
Dec 17 16:45:16 watatsumi kernel: RBP: ffff8807dcbedd88 R08: 0000000000017b80 R09: ffff88080e83ce00
Dec 17 16:45:16 watatsumi kernel: R10: ffff8807dcbedfd8 R11: ffffffff81209fbd R12: ffff8807dcbedea0
Dec 17 16:45:16 watatsumi kernel: R13: ffff8807dcbede93 R14: ffffffff812981f2 R15: ffff8807dcbedcf8
Dec 17 16:45:16 watatsumi kernel: FS:  00007f52ddf3c700(0000) GS:ffff88082f540000(0000) knlGS:0000000000000000
Dec 17 16:45:16 watatsumi kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 17 16:45:16 watatsumi kernel: CR2: 00007f52ddf7d000 CR3: 00000007cb1d2000 CR4: 00000000000407e0
Dec 17 16:45:16 watatsumi kernel: Stack:
Dec 17 16:45:16 watatsumi kernel:  ffff8807dcbedda0 ffffffff811bdee9 ffff88077db89c18 ffff8807dcbeddb8
Dec 17 16:45:16 watatsumi kernel:  ffffffff811c0089 ffff88064dd7d9c0 ffff8807dcbedde8 ffffffff8120d9db
Dec 17 16:45:16 watatsumi kernel:  ffff88064dd7d9c0 0000000000000005 ffff8807ba6dc480 ffffffff8120df90
Dec 17 16:45:16 watatsumi kernel: Call Trace:
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811bdee9>] inode_sb_list_add+0x19/0x60
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811c0089>] new_inode+0x29/0x30
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff8120d9db>] proc_pid_make_inode+0x1b/0x100
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff8120df90>] ? proc_map_files_lookup+0x160/0x160
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff8120dfab>] proc_task_instantiate+0x1b/0xc0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff8120e28f>] proc_fill_cache+0xbf/0xe0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff8120ea1d>] proc_task_readdir+0x18d/0x3b0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811b75ad>] iterate_dir+0xad/0xe0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811b79e2>] SyS_getdents+0x92/0x120
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811b76c0>] ? fillonedir+0xe0/0xe0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff814fcfed>] system_call_fastpath+0x1a/0x1f
Dec 17 16:45:16 watatsumi kernel: Code: 66 90 55 65 48 8b 04 25 70 c7 00 00 48 89 e5 83 80 44 e0 ff ff 01 b8 00 01 00 00 f0 66 0f c1 07 0f b6 d4 38 c2 75 04 5d c3 f3 90 <0f> b6 07 38 d0 75 f7 5d c3 66 0f 1f 84 00 00 00 00 00 66 66 66 
Dec 17 16:45:16 watatsumi kernel: BUG: soft lockup - CPU#6 stuck for 23s! [umount.nfs4:30556]
Dec 17 16:45:16 watatsumi kernel: Modules linked in: usbtmc auth_rpcgss oid_registry nfsv4 tun joydev snd_hda_codec_hdmi x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crct10dif_common crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd fuse nvidia(PO) iTCO_wdt iTCO_vendor_support uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core snd_usb_audio videodev snd_usbmidi_lib snd_rawmidi media snd_seq_device arc4 evdev microcode psmouse serio_raw iwldvm mac80211 snd_hda_codec_realtek iwlwifi snd_hda_intel snd_hda_codec cfg80211 snd_hwdep drm snd_pcm jme jmb38x_ms rfkill mii snd_page_alloc memstick snd_timer i2c_i801 mei_me snd i2c_core soundcore mei thermal shpchp wmi lpc_ich processor battery ac button video pcspkr nfs lockd
Dec 17 16:45:16 watatsumi kernel:  sunrpc fscache ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci firewire_ohci sdhci_pci xhci_hcd scsi_mod ehci_hcd sdhci firewire_core crc_itu_t mmc_core usbcore usb_common
Dec 17 16:45:16 watatsumi kernel: CPU: 6 PID: 30556 Comm: umount.nfs4 Tainted: P           O 3.12.5-1-ARCH #1
Dec 17 16:45:16 watatsumi kernel: Hardware name: CLEVO                             P150HMx/P150HMx, BIOS 4.6.4 08/09/2011
Dec 17 16:45:16 watatsumi kernel: task: ffff8807c902e840 ti: ffff88064fe5c000 task.ti: ffff88064fe5c000
Dec 17 16:45:16 watatsumi kernel: RIP: 0010:[<ffffffff814f4f83>]  [<ffffffff814f4f83>] _raw_spin_lock+0x23/0x40
Dec 17 16:45:16 watatsumi kernel: RSP: 0018:ffff88064fe5ddb0  EFLAGS: 00000202
Dec 17 16:45:16 watatsumi kernel: RAX: 0000000000002c2c RBX: f97a1072bc3dd003 RCX: ffffffff818c01e0
Dec 17 16:45:16 watatsumi kernel: RDX: 000000000000002b RSI: 0000000000000001 RDI: ffff880667e6d438
Dec 17 16:45:16 watatsumi kernel: RBP: ffff88064fe5ddb0 R08: 0000000000000000 R09: 0667f127400c0000
Dec 17 16:45:16 watatsumi kernel: R10: f97a1072bc3dd003 R11: 0000000000000001 R12: ffff88064fe5dd30
Dec 17 16:45:16 watatsumi kernel: R13: ffff88064fe5ddb0 R14: ffff880667f12730 R15: ffff880667f126a8
Dec 17 16:45:16 watatsumi kernel: FS:  00007fdbfd3b3780(0000) GS:ffff88082f580000(0000) knlGS:0000000000000000
Dec 17 16:45:16 watatsumi kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 17 16:45:16 watatsumi kernel: CR2: 00007f63631ff000 CR3: 00000006a0de3000 CR4: 00000000000407e0
Dec 17 16:45:16 watatsumi kernel: Stack:
Dec 17 16:45:16 watatsumi kernel:  ffff88064fe5ddf8 ffffffff811e612c ffff880667f12730 0000000000000000
Dec 17 16:45:16 watatsumi kernel:  ffff8807d797e000 ffff8807d797e0a0 ffffffffa143fe40 ffff880099c279c0
Dec 17 16:45:16 watatsumi kernel:  ffff880674e30620 ffff88064fe5de20 ffffffff811a6a60 0000000000000025
Dec 17 16:45:16 watatsumi kernel: Call Trace:
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811e612c>] fsnotify_unmount_inodes+0x11c/0x1b0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811a6a60>] generic_shutdown_super+0x40/0xf0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811a6cd2>] kill_anon_super+0x12/0x20
Dec 17 16:45:16 watatsumi kernel:  [<ffffffffa03eb18b>] nfs_kill_super+0x1b/0x30 [nfs]
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811a70bd>] deactivate_locked_super+0x3d/0x60
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811a76a6>] deactivate_super+0x46/0x60
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811c350f>] mntput_no_expire+0xef/0x150
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811c3596>] mntput+0x26/0x40
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811c36ad>] namespace_unlock+0xfd/0x110
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff811c4803>] SyS_umount+0x1c3/0x3a0
Dec 17 16:45:16 watatsumi kernel:  [<ffffffff814fcfed>] system_call_fastpath+0x1a/0x1f
Dec 17 16:45:16 watatsumi kernel: Code: 05 e8 52 84 da ff 5d c3 66 66 66 66 90 55 65 48 8b 04 25 70 c7 00 00 48 89 e5 83 80 44 e0 ff ff 01 b8 00 01 00 00 f0 66 0f c1 07 <0f> b6 d4 38 c2 75 04 5d c3 f3 90 0f b6 07 38 d0 75 f7 5d c3 66 
Dec 17 16:45:16 watatsumi kernel: BUG: soft lockup - CPU#7 stuck for 23s! [ifconfig:30557]

Thanks

Alex Forencich

|

