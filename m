Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:46039 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752564Ab1AXOlM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 09:41:12 -0500
Date: Mon, 24 Jan 2011 09:41:07 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: possible regression: BUG in client lockd with server reboot.
Message-ID: <20110124144107.GA3718@elliptictech.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We were just having some NFS server troubles, and my client machine
running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
hard (syslog output appended to this mail).

I'm not sure what the exact timeline was or how to reproduce this,
but the server was rebooted during all this.  Since I've never seen
this happen before, it is possibly a regression from previous kernel
releases.  However, I recently updated my nfs-utils (on the client) to
version 1.2.3, so that might be related as well.

Please let me know if any more information is required.

kernel: nfs: server elpfs1 not responding, still trying
kernel: ------------[ cut here ]------------
kernel: kernel BUG at /scratch_space/linux-2.6/fs/lockd/host.c:283!
kernel: invalid opcode: 0000 [#1] PREEMPT SMP 
kernel: last sysfs file: /sys/devices/virtual/vtconsole/vtcon1/uevent
kernel: CPU 0 
kernel: Modules linked in: nfs nfs_acl bridge stp llc autofs4 nfsd lockd exportfs sunrpc ipv6 iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc sg evdev usb_storage ext2 ehci_hcd sr_mod cdrom loop tun acpi_cpufreq mperf arc4 ecb crypto_blkcipher cryptomgr aead crypto_algapi rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib mac80211 cfg80211 eeprom_93cx6 e1000e
kernel: 
kernel: Pid: 2926, comm: lockd Not tainted 2.6.38-rc1-00137-g2b1caf6 #132 WG43M/Aspire X3810
kernel: RIP: 0010:[<ffffffffa02fb3c8>]  [<ffffffffa02fb3c8>] nlmclnt_release_host+0x6c/0xbc [lockd]
kernel: RSP: 0018:ffff88013e235d40  EFLAGS: 00010283
kernel: RAX: ffff8801394f91b0 RBX: ffff8801394f9000 RCX: 0000000000000000
kernel: RDX: 0000000000000001 RSI: ffffffffa0305780 RDI: ffff8801394f9000
kernel: RBP: ffff88013e235d50 R08: ffffffff81403d50 R09: 0000000000000003
kernel: R10: ffff88013e235cc0 R11: ffff88011f199688 R12: ffff88013b1f9800
kernel: R13: ffff8801394f9000 R14: ffff88013b1f9800 R15: ffff880139c9c014
kernel: FS:  0000000000000000(0000) GS:ffff8800b7a00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 00007f2fb2ec0000 CR3: 000000012dd39000 CR4: 00000000000406f0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process lockd (pid: 2926, threadinfo ffff88013e234000, task ffff88013b0e1650)
kernel: Stack:
kernel: ffff8801394f9000 ffff88013972ed00 ffff88013e235d80 ffffffffa02fb473
kernel: 0000000000000000 ffff88013e098000 ffff88013e098028 ffff88013e045f00
kernel: ffff88013e235df0 ffffffffa02fde5b ffff88013e235de0 ffffffffa02c169d
kernel: Call Trace:
kernel: [<ffffffffa02fb473>] nlm_host_rebooted+0x5b/0x85 [lockd]
kernel: [<ffffffffa02fde5b>] nlmsvc_proc_sm_notify+0xcd/0xdc [lockd]
kernel: [<ffffffffa02c169d>] ? svc_xprt_enqueue+0x1cc/0x1db [sunrpc]
kernel: [<ffffffffa02b9d3c>] ? svcauth_null_accept+0xfc/0x162 [sunrpc]
kernel: [<ffffffffa02b68a5>] svc_process+0x3d2/0x660 [sunrpc]
kernel: [<ffffffffa02fc516>] lockd+0x15d/0x1bb [lockd]
kernel: [<ffffffffa02fc3b9>] ? lockd+0x0/0x1bb [lockd]
kernel: [<ffffffff810505ce>] kthread+0x7d/0x85
kernel: [<ffffffff81003714>] kernel_thread_helper+0x4/0x10
kernel: [<ffffffff81050551>] ? kthread+0x0/0x85
kernel: [<ffffffff81003710>] ? kernel_thread_helper+0x0/0x10
kernel: Code: f6 83 36 01 00 00 02 74 04 0f 0b eb fe f0 ff 8b 7c 01 00 00 0f 94 c0 84 c0 74 5c 48 8d 83 b0 01 00 00 48 39 83 b0 01 00 00 74 04 <0f> 0b eb fe 48 8d 83 c8 01 00 00 48 39 83 c8 01 00 00 74 04 0f 
kernel: RIP  [<ffffffffa02fb3c8>] nlmclnt_release_host+0x6c/0xbc [lockd]
kernel: RSP <ffff88013e235d40>
kernel: ---[ end trace e0853600ed4dcc75 ]---
kernel: ------------[ cut here ]------------
kernel: kernel BUG at /scratch_space/linux-2.6/fs/lockd/host.c:279!
kernel: invalid opcode: 0000 [#2] PREEMPT SMP 
kernel: last sysfs file: /sys/devices/virtual/vtconsole/vtcon1/uevent
kernel: CPU 2 
kernel: Modules linked in: nfs nfs_acl bridge stp llc autofs4 nfsd lockd exportfs sunrpc ipv6 iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc sg evdev usb_storage ext2 ehci_hcd sr_mod cdrom loop tun acpi_cpufreq mperf arc4 ecb crypto_blkcipher cryptomgr aead crypto_algapi rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib mac80211 cfg80211 eeprom_93cx6 e1000e
kernel: 
kernel: Pid: 3792, comm: elpfs1-reclaim Tainted: G      D     2.6.38-rc1-00137-g2b1caf6 #132 WG43M/Aspire X3810
kernel: RIP: 0010:[<ffffffffa02fb399>]  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP: 0018:ffff8800b316fe70  EFLAGS: 00010286
kernel: RAX: 00000000ffffffff RBX: ffff8801394f9000 RCX: ffff8801394f9000
kernel: RDX: 0000000000000000 RSI: 000000000000004b RDI: ffff8801394f9000
kernel: RBP: ffff8800b316fe80 R08: 0000000000000000 R09: ffff8801394f9000
kernel: R10: ffff8800b7b0c470 R11: ffff8800b316f990 R12: ffffffffa0303ab0
kernel: R13: ffff8801394f91d8 R14: ffff8801394f91c8 R15: ffff8801394f9138
kernel: FS:  0000000000000000(0000) GS:ffff8800b7b00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 00007fa25f433020 CR3: 000000012dff8000 CR4: 00000000000406e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process elpfs1-reclaim (pid: 3792, threadinfo ffff8800b316e000, task ffff88011f19aca0)
kernel: Stack:
kernel: ffff8800b316fe80 ffff8801394f9000 ffff8800b316fee0 ffffffffa02f92a9
kernel: ffff88011f19aca0 0000004b1f19aca0 ffff8801394f9150 ffff8801394f91d8
kernel: ffff8800b316fee0 ffff88013e235c80 ffff8801394f9000 ffff8800b316ff00
kernel: Call Trace:
kernel: [<ffffffffa02f92a9>] reclaimer+0x21c/0x232 [lockd]
kernel: [<ffffffffa02f908d>] ? reclaimer+0x0/0x232 [lockd]
kernel: [<ffffffff810505ce>] kthread+0x7d/0x85
kernel: [<ffffffff81003714>] kernel_thread_helper+0x4/0x10
kernel: [<ffffffff81050551>] ? kthread+0x0/0x85
kernel: [<ffffffff81003710>] ? kernel_thread_helper+0x0/0x10
kernel: Code: 00 00 00 80 3d 94 2d fd ff 00 79 15 48 8b b7 28 01 00 00 31 c0 48 c7 c7 cd 20 30 a0 e8 d8 9d 00 e1 8b 83 7c 01 00 00 85 c0 79 04 <0f> 0b eb fe f6 83 36 01 00 00 02 74 04 0f 0b eb fe f0 ff 8b 7c 
kernel: RIP  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP <ffff8800b316fe70>
kernel: ---[ end trace e0853600ed4dcc76 ]---
kernel: ------------[ cut here ]------------
kernel: kernel BUG at /scratch_space/linux-2.6/fs/lockd/host.c:279!
kernel: invalid opcode: 0000 [#3] PREEMPT SMP 
kernel: last sysfs file: /sys/devices/virtual/vtconsole/vtcon1/uevent
kernel: CPU 3 
kernel: Modules linked in: nfs nfs_acl bridge stp llc autofs4 nfsd lockd exportfs sunrpc ipv6 iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc sg evdev usb_storage ext2 ehci_hcd sr_mod cdrom loop tun acpi_cpufreq mperf arc4 ecb crypto_blkcipher cryptomgr aead crypto_algapi rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib mac80211 cfg80211 eeprom_93cx6 e1000e
kernel: 
kernel: Pid: 3793, comm: elpfs1-reclaim Tainted: G      D     2.6.38-rc1-00137-g2b1caf6 #132 WG43M/Aspire X3810
kernel: RIP: 0010:[<ffffffffa02fb399>]  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP: 0018:ffff8800b3181e70  EFLAGS: 00010286
kernel: RAX: 00000000ffffffff RBX: ffff8801394f9000 RCX: ffff8801394f9000
kernel: RDX: 0000000000000000 RSI: 000000000000004b RDI: ffff8801394f9000
kernel: RBP: ffff8800b3181e80 R08: 0000000000000000 R09: ffff8801394f9000
kernel: R10: ffff8800b7b8c470 R11: ffff8800b3181990 R12: ffffffffa0303ab0
kernel: R13: ffff8801394f91d8 R14: ffff8801394f91c8 R15: ffff8801394f9138
kernel: FS:  0000000000000000(0000) GS:ffff8800b7b80000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 0000000000613e18 CR3: 000000011f038000 CR4: 00000000000406e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process elpfs1-reclaim (pid: 3793, threadinfo ffff8800b3180000, task ffff88011f19c2f0)
kernel: Stack:
kernel: ffff8800b3181e80 ffff8801394f9000 ffff8800b3181ee0 ffffffffa02f92a9
kernel: ffff88011f19c2f0 0000004b1f19c2f0 ffff8801394f9150 ffff8801394f91d8
kernel: ffff8800b3181ee0 ffff88013e235c80 ffff8801394f9000 ffff8800b3181f00
kernel: Call Trace:
kernel: [<ffffffffa02f92a9>] reclaimer+0x21c/0x232 [lockd]
kernel: [<ffffffffa02f908d>] ? reclaimer+0x0/0x232 [lockd]
kernel: [<ffffffff810505ce>] kthread+0x7d/0x85
kernel: [<ffffffff81003714>] kernel_thread_helper+0x4/0x10
kernel: [<ffffffff81050551>] ? kthread+0x0/0x85
kernel: [<ffffffff81003710>] ? kernel_thread_helper+0x0/0x10
kernel: Code: 00 00 00 80 3d 94 2d fd ff 00 79 15 48 8b b7 28 01 00 00 31 c0 48 c7 c7 cd 20 30 a0 e8 d8 9d 00 e1 8b 83 7c 01 00 00 85 c0 79 04 <0f> 0b eb fe f6 83 36 01 00 00 02 74 04 0f 0b eb fe f0 ff 8b 7c 
kernel: RIP  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP <ffff8800b3181e70>
kernel: ---[ end trace e0853600ed4dcc77 ]---
kernel: ------------[ cut here ]------------
kernel: kernel BUG at /scratch_space/linux-2.6/fs/lockd/host.c:279!
kernel: invalid opcode: 0000 [#4] PREEMPT SMP 
kernel: last sysfs file: /sys/devices/virtual/vtconsole/vtcon1/uevent
kernel: CPU 3 
kernel: Modules linked in: nfs nfs_acl bridge stp llc autofs4 nfsd lockd exportfs sunrpc ipv6 iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc sg evdev usb_storage ext2 ehci_hcd sr_mod cdrom loop tun acpi_cpufreq mperf arc4 ecb crypto_blkcipher cryptomgr aead crypto_algapi rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib mac80211 cfg80211 eeprom_93cx6 e1000e
kernel: 
kernel: Pid: 3794, comm: elpfs1-reclaim Tainted: G      D     2.6.38-rc1-00137-g2b1caf6 #132 WG43M/Aspire X3810
kernel: RIP: 0010:[<ffffffffa02fb399>]  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP: 0018:ffff8800b3183e70  EFLAGS: 00010286
kernel: RAX: 00000000ffffffff RBX: ffff8801394f9000 RCX: ffff8801394f9000
kernel: RDX: ffffffff00000001 RSI: 000000000000004b RDI: ffff8801394f9000
kernel: RBP: ffff8800b3183e80 R08: 0000000000000000 R09: ffff8801394f9000
kernel: R10: 0000000000000003 R11: ffff8800b3183990 R12: ffffffffa0303ab0
kernel: R13: ffff8801394f91d8 R14: ffff8801394f91c8 R15: ffff8801394f9138
kernel: FS:  0000000000000000(0000) GS:ffff8800b7b80000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 0000000000613e18 CR3: 000000011f038000 CR4: 00000000000406e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process elpfs1-reclaim (pid: 3794, threadinfo ffff8800b3182000, task ffff88011f199650)
kernel: Stack:
kernel: ffff8800b3183e80 ffff8801394f9000 ffff8800b3183ee0 ffffffffa02f92a9
kernel: ffff88011f199650 0000004b1f199650 ffff8801394f9150 ffff8801394f91d8
kernel: ffff8800b3183ee0 ffff88013e235c80 ffff8801394f9000 ffff8800b3183f00
kernel: Call Trace:
kernel: [<ffffffffa02f92a9>] reclaimer+0x21c/0x232 [lockd]
kernel: [<ffffffffa02f908d>] ? reclaimer+0x0/0x232 [lockd]
kernel: [<ffffffff810505ce>] kthread+0x7d/0x85
kernel: [<ffffffff81003714>] kernel_thread_helper+0x4/0x10
kernel: [<ffffffff81050551>] ? kthread+0x0/0x85
kernel: [<ffffffff81003710>] ? kernel_thread_helper+0x0/0x10
kernel: Code: 00 00 00 80 3d 94 2d fd ff 00 79 15 48 8b b7 28 01 00 00 31 c0 48 c7 c7 cd 20 30 a0 e8 d8 9d 00 e1 8b 83 7c 01 00 00 85 c0 79 04 <0f> 0b eb fe f6 83 36 01 00 00 02 74 04 0f 0b eb fe f0 ff 8b 7c 
kernel: RIP  [<ffffffffa02fb399>] nlmclnt_release_host+0x3d/0xbc [lockd]
kernel: RSP <ffff8800b3183e70>
kernel: ---[ end trace e0853600ed4dcc78 ]---
rpc.statd[2853]: process_notify_list: Can't callback emergent (100021,3), giving up
kernel: nfs: server elpfs1 OK

[The system is mostly dead at this point].

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
