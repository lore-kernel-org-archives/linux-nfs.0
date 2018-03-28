Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mordac.selfhost.de ([82.98.82.6]:43017 "EHLO
        outgoing.selfhost.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750820AbeC1KfC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 06:35:02 -0400
To: linux-nfs@vger.kernel.org
From: Harald Dunkel <harri@afaics.de>
Subject: 4.9.82 (Debian): rcu_sched self-detected stall on CPU
Message-ID: <25bef31b-44c2-475e-6536-8a8ff639fe1e@afaics.de>
Date: Wed, 28 Mar 2018 12:28:19 +0200
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------20C8290D73BA9097DC0D69B0"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------20C8290D73BA9097DC0D69B0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hi folks,

using Debian's 4.9.82 kernel one of our PCs became unresponsive. The
log file shows:

Mar 27 18:04:11 dpcl017 kernel: [895316.531487] INFO: rcu_sched self-detected stall on CPU
Mar 27 18:04:11 dpcl017 kernel: [895316.531492]         1-...: (5248 ticks this GP) idle=7af/140000000000001/0 softirq=42169443/42169443 fqs=2624
Mar 27 18:04:11 dpcl017 kernel: [895316.531494]          (t=5250 jiffies g=27560104 c=27560103 q=82482)
Mar 27 18:04:11 dpcl017 kernel: [895316.531496] Task dump for CPU 1:
Mar 27 18:04:11 dpcl017 kernel: [895316.531496] TaskSchedulerBa R  running task        0 29775      1 0x00000008
Mar 27 18:04:11 dpcl017 kernel: [895316.531499]  ffffffffbbb18cc0 ffffffffbaea487b 0000000000000001 ffffffffbbb18cc0
Mar 27 18:04:11 dpcl017 kernel: [895316.531500]  ffffffffbaf7d54b ffff8f377f499680 ffffffffbba4fc00 0000000000000000
Mar 27 18:04:11 dpcl017 kernel: [895316.531502]  ffffffffbbb18cc0 00000000ffffffff ffffffffbaee00ca 0000000000ca133f
Mar 27 18:04:11 dpcl017 kernel: [895316.531504] Call Trace:
Mar 27 18:04:11 dpcl017 kernel: [895316.531505]  <IRQ>
Mar 27 18:04:11 dpcl017 kernel: [895316.531508]  [<ffffffffbaea487b>] ? sched_show_task+0xcb/0x130
Mar 27 18:04:11 dpcl017 kernel: [895316.531510]  [<ffffffffbaf7d54b>] ? rcu_dump_cpu_stacks+0x92/0xb2
Mar 27 18:04:11 dpcl017 kernel: [895316.531512]  [<ffffffffbaee00ca>] ? rcu_check_callbacks+0x75a/0x8b0
Mar 27 18:04:11 dpcl017 kernel: [895316.531514]  [<ffffffffbaeee738>] ? update_wall_time+0x498/0x7b0
Mar 27 18:04:11 dpcl017 kernel: [895316.531516]  [<ffffffffbaef6070>] ? tick_sched_handle.isra.12+0x50/0x50
Mar 27 18:04:11 dpcl017 kernel: [895316.531517]  [<ffffffffbaee6c88>] ? update_process_times+0x28/0x50
Mar 27 18:04:11 dpcl017 kernel: [895316.531519]  [<ffffffffbaef6040>] ? tick_sched_handle.isra.12+0x20/0x50
Mar 27 18:04:11 dpcl017 kernel: [895316.531520]  [<ffffffffbaef60a8>] ? tick_sched_timer+0x38/0x70
Mar 27 18:04:11 dpcl017 kernel: [895316.531521]  [<ffffffffbaee771e>] ? __hrtimer_run_queues+0xde/0x250
Mar 27 18:04:11 dpcl017 kernel: [895316.531522]  [<ffffffffbaee7dfc>] ? hrtimer_interrupt+0x9c/0x1a0
Mar 27 18:04:11 dpcl017 kernel: [895316.531524]  [<ffffffffbb41489f>] ? smp_apic_timer_interrupt+0x3f/0x50
Mar 27 18:04:11 dpcl017 kernel: [895316.531525]  [<ffffffffbb413196>] ? apic_timer_interrupt+0x96/0xa0
Mar 27 18:04:11 dpcl017 kernel: [895316.531525]  <EOI>
Mar 27 18:04:11 dpcl017 kernel: [895316.531536]  [<ffffffffc19dadb8>] ? nfs_commit_end+0x8/0x20 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531541]  [<ffffffffc19dcf1c>] ? nfs_commit_inode+0xac/0x150 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531546]  [<ffffffffc19dd388>] ? nfs_wb_single_page+0x98/0x190 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531550]  [<ffffffffc19dd9a6>] ? nfs_updatepage+0x376/0x910 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531555]  [<ffffffffc19cdec0>] ? nfs_write_end+0x140/0x4f0 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531557]  [<ffffffffbaf7e6f2>] ? generic_perform_write+0x122/0x1d0
Mar 27 18:04:11 dpcl017 kernel: [895316.531562]  [<ffffffffc19cd0e5>] ? nfs_file_write+0xd5/0x200 [nfs]
Mar 27 18:04:11 dpcl017 kernel: [895316.531564]  [<ffffffffbb0050a0>] ? new_sync_write+0xe0/0x130
Mar 27 18:04:11 dpcl017 kernel: [895316.531565]  [<ffffffffbb005820>] ? vfs_write+0xb0/0x190
Mar 27 18:04:11 dpcl017 kernel: [895316.531566]  [<ffffffffbb006e10>] ? SyS_pwrite64+0x90/0xb0
Mar 27 18:04:11 dpcl017 kernel: [895316.531568]  [<ffffffffbae03b7f>] ? do_syscall_64+0x8f/0xf0
Mar 27 18:04:11 dpcl017 kernel: [895316.531570]  [<ffffffffbb4113b8>] ? entry_SYSCALL_64_after_swapgs+0x42/0xb0
Mar 27 18:04:38 dpcl017 kernel: [895342.962258] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [TaskSchedulerBa:29775]
Mar 27 18:04:38 dpcl017 kernel: [895342.962260] Modules linked in: cpuid fuse rfcomm pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) cpufreq_userspace vboxdrv(O) cpufreq_conservative cpufreq_powersave rpcsec_gs
Mar 27 18:04:38 dpcl017 kernel: [895342.962289]  drm_kms_helper drm nvidia_modeset(PO) nvidia(PO) ip_tables x_tables autofs4 hid_generic usbhid hid ext4 crc16 jbd2 fscrypto ecb mbcache btrfs raid10 raid456 asyn
Mar 27 18:04:38 dpcl017 kernel: [895342.962315] CPU: 1 PID: 29775 Comm: TaskSchedulerBa Tainted: P           O    4.9.0-6-amd64 #1 Debian 4.9.82-1+deb9u3
Mar 27 18:04:38 dpcl017 kernel: [895342.962315] Hardware name: System manufacturer System Product Name/P8P67, BIOS 1503 03/10/2011
Mar 27 18:04:38 dpcl017 kernel: [895342.962316] task: ffff8f3654f3d000 task.stack: ffffaf6348d10000
Mar 27 18:04:38 dpcl017 kernel: [895342.962317] RIP: 0010:[<ffffffffbafc462b>]  [<ffffffffbafc462b>] page_mkclean+0x4b/0xc0
Mar 27 18:04:38 dpcl017 kernel: [895342.962321] RSP: 0000:ffffaf6348d13be8  EFLAGS: 00000246
Mar 27 18:04:38 dpcl017 kernel: [895342.962322] RAX: ffffaf6348d13bec RBX: ffffee2e0bc7d700 RCX: 0000000000000000
Mar 27 18:04:38 dpcl017 kernel: [895342.962322] RDX: ffffee2e1092d420 RSI: 0000000000000000 RDI: ffffee2e0bc7d700
Mar 27 18:04:38 dpcl017 kernel: [895342.962323] RBP: ffff8f354a94ab50 R08: 0000000000000101 R09: 0000000000000000
Mar 27 18:04:38 dpcl017 kernel: [895342.962324] R10: 00000000033ac538 R11: 00000000034cdfd3 R12: ffff8f354a94ab50
Mar 27 18:04:38 dpcl017 kernel: [895342.962324] R13: ffffaf6348d13c60 R14: 0000000000000000 R15: ffff8f354a94ab50
Mar 27 18:04:38 dpcl017 kernel: [895342.962325] FS:  00007fd013827700(0000) GS:ffff8f377f480000(0000) knlGS:0000000000000000
Mar 27 18:04:38 dpcl017 kernel: [895342.962326] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Mar 27 18:04:38 dpcl017 kernel: [895342.962327] CR2: 000015cb433c7208 CR3: 0000000320130000 CR4: 0000000000062670
Mar 27 18:04:38 dpcl017 kernel: [895342.962327] Stack:
Mar 27 18:04:38 dpcl017 kernel: [895342.962328]  00000000c19dcf1c ffffaf6348d13bec ffffffffbafc29e0 0000000000000000
Mar 27 18:04:38 dpcl017 kernel: [895342.962330]  0000000000000000 0000000000000000 02a4b91511383e4f ffffee2e0bc7d700
:
:


Full log is attached. Does this sound familiar?


Every helpful comment is highly appreciated
Harri

--------------20C8290D73BA9097DC0D69B0
Content-Type: application/gzip;
 name="kern.log.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="kern.log.gz"

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
AQA=
--------------20C8290D73BA9097DC0D69B0--
