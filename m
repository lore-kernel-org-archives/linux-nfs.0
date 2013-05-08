Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:61527 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab3EHTDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 15:03:02 -0400
Received: from mailout-de.gmx.net ([10.1.76.35]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0Mg20J-1UxcJN3TOf-00NRSl for
 <linux-nfs@vger.kernel.org>; Wed, 08 May 2013 21:03:00 +0200
Message-ID: <518AA163.2060906@gmx.de>
Date: Wed, 08 May 2013 21:02:59 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: NFSD: unable to generate recoverydir name (-2).
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Got this at a host (3.9.1) while fuzzying a user mode linux image with trinity.
Trinity runs on the UML guest, the victims files where on a share which os mounted
via nfsv4 from the host onto a guest mount point. Guest and host are 32 bit stable Gentoo,
guest runs linux-v3.9-11574-gd5db936, host 3.9.1

At the guest I just got :

2013-05-08T20:51:56.500+02:00 trinity kernel: nfs: server n22 not responding, timed out
2013-05-08T20:51:56.500+02:00 trinity kernel: nfs: server n22 not responding, timed out

whilst the host gave :

2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: unable to generate recoverydir name (-2).
2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: disabling legacy clientid tracking. Reboot recovery will not function correctly!
2013-05-08T20:43:19.416+02:00 n22 kernel: BUG: unable to handle kernel NULL pointer dereference at 000003c8
2013-05-08T20:43:19.416+02:00 n22 kernel: IP: [<f90a3d91>] nfsd4_client_tracking_exit+0x11/0x50 [nfsd]
2013-05-08T20:43:19.416+02:00 n22 kernel: *pdpt = 000000002ba33001 *pde = 0000000000000000 
2013-05-08T20:43:19.416+02:00 n22 kernel: Oops: 0000 [#1] SMP 
2013-05-08T20:43:19.416+02:00 n22 kernel: Modules linked in: loop nfsd auth_rpcgss ipt_MASQUERADE xt_owner xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack nf_conntrack_ftp xt_limit xt_LOG iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc tun arc4 iwldvm mac80211 coretemp kvm_intel uvcvideo sdhci_pci sdhci mmc_core videobuf2_vmalloc videobuf2_memops usblp videobuf2_core i915 iwlwifi psmouse videodev cfg80211 kvm fbcon bitblit cfbfillrect acpi_cpufreq mperf evdev softcursor font cfbimgblt i2c_algo_bit cfbcopyarea intel_agp intel_gtt drm_kms_helper snd_hda_codec_conexant drm agpgart fb fbdev tpm_tis thinkpad_acpi tpm nvram e1000e rfkill thermal ptp wmi pps_core tpm_bios 8250_pci processor 8250 ac snd_hda_intel snd_hda_codec snd_pcm battery video i2c_i801 snd_page_alloc snd_timer button serial_core i2c_core snd soundcore thermal_sys hwmon aesni_intel ablk_h!
 elper cryp
td lrw aes_i586 xts gf128mul cbc fuse nfs lockd sunrpc dm_crypt dm_mod hid_monterey hid_microsoft hid_logitech hid_ezkey hid_cypress hid_chicony hid_cherry hid_belkin hid_apple hid_a4tech hid_generic usbhid hid sr_mod cdrom sg [last unloaded: microcode]
2013-05-08T20:43:19.416+02:00 n22 kernel: Pid: 6374, comm: nfsd Not tainted 3.9.1 #6 LENOVO 4180F65/4180F65
2013-05-08T20:43:19.416+02:00 n22 kernel: EIP: 0060:[<f90a3d91>] EFLAGS: 00010202 CPU: 0
2013-05-08T20:43:19.416+02:00 n22 kernel: EIP is at nfsd4_client_tracking_exit+0x11/0x50 [nfsd]
2013-05-08T20:43:19.417+02:00 n22 kernel: EAX: 00000000 EBX: fffffffe ECX: 00000007 EDX: 00000007
2013-05-08T20:43:19.417+02:00 n22 kernel: ESI: eb9dcb00 EDI: eb2991c0 EBP: eb2bde38 ESP: eb2bde34
2013-05-08T20:43:19.417+02:00 n22 kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
2013-05-08T20:43:19.417+02:00 n22 kernel: CR0: 80050033 CR2: 000003c8 CR3: 2ba80000 CR4: 000407f0
2013-05-08T20:43:19.417+02:00 n22 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
2013-05-08T20:43:19.417+02:00 n22 kernel: DR6: ffff0ff0 DR7: 00000400
2013-05-08T20:43:19.417+02:00 n22 kernel: Process nfsd (pid: 6374, ti=eb2bc000 task=eb2711c0 task.ti=eb2bc000)
2013-05-08T20:43:19.417+02:00 n22 kernel: Stack:
2013-05-08T20:43:19.417+02:00 n22 kernel: fffffffe eb2bde4c f90a3e0c f90a7754 fffffffe eb0a9c00 eb2bdea0 f90a41ed
2013-05-08T20:43:19.417+02:00 n22 kernel: eb2991c0 1b270000 eb2991c0 eb2bde7c f9099ce9 eb2bde98 0129a020 eb29a020
2013-05-08T20:43:19.419+02:00 n22 kernel: eb2bdecc eb2991c0 eb2bdea8 f9099da5 00000000 eb9dcb00 00000001 67822f08
2013-05-08T20:43:19.419+02:00 n22 kernel: Call Trace:
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f90a3e0c>] legacy_recdir_name_error+0x3c/0x40 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f90a41ed>] nfsd4_create_clid_dir+0x15d/0x1c0 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f9099ce9>] ? nfsd4_lookup_stateid+0x99/0xd0 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f9099da5>] ? nfs4_preprocess_seqid_op+0x85/0x100 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f90a4287>] nfsd4_client_record_create+0x37/0x50 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f909d6ce>] nfsd4_open_confirm+0xfe/0x130 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f90980b1>] ? nfsd4_encode_operation+0x61/0x90 [nfsd]
2013-05-08T20:43:19.419+02:00 n22 kernel: [<f909d5d0>] ? nfsd4_free_stateid+0xc0/0xc0 [nfsd]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<f908fd0b>] nfsd4_proc_compound+0x41b/0x530 [nfsd]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<f9081b7b>] nfsd_dispatch+0x8b/0x1a0 [nfsd]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<f857b85d>] svc_process+0x3dd/0x640 [sunrpc]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<f908165d>] nfsd+0xad/0x110 [nfsd]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<f90815b0>] ? nfsd_destroy+0x70/0x70 [nfsd]
2013-05-08T20:43:19.420+02:00 n22 kernel: [<c1054824>] kthread+0x94/0xa0
2013-05-08T20:43:19.420+02:00 n22 kernel: [<c1486937>] ret_from_kernel_thread+0x1b/0x28
2013-05-08T20:43:19.420+02:00 n22 kernel: [<c1054790>] ? flush_kthread_work+0xd0/0xd0
2013-05-08T20:43:19.420+02:00 n22 kernel: Code: 86 b0 00 00 00 90 c5 0a f9 c7 04 24 70 76 0a f9 e8 74 a9 3d c8 eb ba 8d 76 00 55 89 e5 53 66 66 66 66 90 8b 15 68 c7 0a f9 85 d2 <8b> 88 c8 03 00 00 74 2c 3b 11 77 28 8b 5c 91 08 85 db 74 22 8b
2013-05-08T20:43:19.420+02:00 n22 kernel: EIP: [<f90a3d91>] nfsd4_client_tracking_exit+0x11/0x50 [nfsd] SS:ESP 0068:eb2bde34
2013-05-08T20:43:19.421+02:00 n22 kernel: CR2: 00000000000003c8
2013-05-08T20:43:19.421+02:00 n22 kernel: ---[ end trace 09e54015d145c9c6 ]---
2

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
