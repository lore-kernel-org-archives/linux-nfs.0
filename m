Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:3601 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753301AbeDPGqH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Apr 2018 02:46:07 -0400
Subject: Re: 4.9.82 (Debian): rcu_sched self-detected stall on CPU
To: Harald Dunkel <harri@afaics.de>, linux-nfs@vger.kernel.org
References: <25bef31b-44c2-475e-6536-8a8ff639fe1e@afaics.de>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <6b9ac49a-cd0e-7760-e9df-ad5bd0427b9e@aixigo.de>
Date: Mon, 16 Apr 2018 08:46:05 +0200
MIME-Version: 1.0
In-Reply-To: <25bef31b-44c2-475e-6536-8a8ff639fe1e@afaics.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I have several (i.e. 8 of 56) hosts with this problem. Every helpful comment
is highly appreciated.

Harri

On 03/28/18 12:28, Harald Dunkel wrote:
> Hi folks,
> 
> using Debian's 4.9.82 kernel one of our PCs became unresponsive. The
> log file shows:
> 
> Mar 27 18:04:11 dpcl017 kernel: [895316.531487] INFO: rcu_sched self-detected stall on CPU
> Mar 27 18:04:11 dpcl017 kernel: [895316.531492]         1-...: (5248 ticks this GP) idle=7af/140000000000001/0 softirq=42169443/42169443 fqs=2624
> Mar 27 18:04:11 dpcl017 kernel: [895316.531494]          (t=5250 jiffies g=27560104 c=27560103 q=82482)
> Mar 27 18:04:11 dpcl017 kernel: [895316.531496] Task dump for CPU 
> Mar 27 18:04:11 dpcl017 kernel: [895316.531496] TaskSchedulerBa R  running task        0 29775      1 0x00000008
> Mar 27 18:04:11 dpcl017 kernel: [895316.531499]  ffffffffbbb18cc0 ffffffffbaea487b 0000000000000001 ffffffffbbb18cc0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531500]  ffffffffbaf7d54b ffff8f377f499680 ffffffffbba4fc00 0000000000000000
> Mar 27 18:04:11 dpcl017 kernel: [895316.531502]  ffffffffbbb18cc0 00000000ffffffff ffffffffbaee00ca 0000000000ca133f
> Mar 27 18:04:11 dpcl017 kernel: [895316.531504] Call Trace:
> Mar 27 18:04:11 dpcl017 kernel: [895316.531505]  <IRQ>
> Mar 27 18:04:11 dpcl017 kernel: [895316.531508]  [<ffffffffbaea487b>] ? sched_show_task+0xcb/0x130
> Mar 27 18:04:11 dpcl017 kernel: [895316.531510]  [<ffffffffbaf7d54b>] ? rcu_dump_cpu_stacks+0x92/0xb2
> Mar 27 18:04:11 dpcl017 kernel: [895316.531512]  [<ffffffffbaee00ca>] ? rcu_check_callbacks+0x75a/0x8b0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531514]  [<ffffffffbaeee738>] ? update_wall_time+0x498/0x7b0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531516]  [<ffffffffbaef6070>] ? tick_sched_handle.isra.12+0x50/0x50
> Mar 27 18:04:11 dpcl017 kernel: [895316.531517]  [<ffffffffbaee6c88>] ? update_process_times+0x28/0x50
> Mar 27 18:04:11 dpcl017 kernel: [895316.531519]  [<ffffffffbaef6040>] ? tick_sched_handle.isra.12+0x20/0x50
> Mar 27 18:04:11 dpcl017 kernel: [895316.531520]  [<ffffffffbaef60a8>] ? tick_sched_timer+0x38/0x70
> Mar 27 18:04:11 dpcl017 kernel: [895316.531521]  [<ffffffffbaee771e>] ? __hrtimer_run_queues+0xde/0x250
> Mar 27 18:04:11 dpcl017 kernel: [895316.531522]  [<ffffffffbaee7dfc>] ? hrtimer_interrupt+0x9c/0x1a0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531524]  [<ffffffffbb41489f>] ? smp_apic_timer_interrupt+0x3f/0x50
> Mar 27 18:04:11 dpcl017 kernel: [895316.531525]  [<ffffffffbb413196>] ? apic_timer_interrupt+0x96/0xa0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531525]  <EOI>
> Mar 27 18:04:11 dpcl017 kernel: [895316.531536]  [<ffffffffc19dadb8>] ? nfs_commit_end+0x8/0x20 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531541]  [<ffffffffc19dcf1c>] ? nfs_commit_inode+0xac/0x150 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531546]  [<ffffffffc19dd388>] ? nfs_wb_single_page+0x98/0x190 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531550]  [<ffffffffc19dd9a6>] ? nfs_updatepage+0x376/0x910 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531555]  [<ffffffffc19cdec0>] ? nfs_write_end+0x140/0x4f0 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531557]  [<ffffffffbaf7e6f2>] ? generic_perform_write+0x122/0x1d0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531562]  [<ffffffffc19cd0e5>] ? nfs_file_write+0xd5/0x200 [nfs]
> Mar 27 18:04:11 dpcl017 kernel: [895316.531564]  [<ffffffffbb0050a0>] ? new_sync_write+0xe0/0x130
> Mar 27 18:04:11 dpcl017 kernel: [895316.531565]  [<ffffffffbb005820>] ? vfs_write+0xb0/0x190
> Mar 27 18:04:11 dpcl017 kernel: [895316.531566]  [<ffffffffbb006e10>] ? SyS_pwrite64+0x90/0xb0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531568]  [<ffffffffbae03b7f>] ? do_syscall_64+0x8f/0xf0
> Mar 27 18:04:11 dpcl017 kernel: [895316.531570]  [<ffffffffbb4113b8>] ? entry_SYSCALL_64_after_swapgs+0x42/0xb0
> Mar 27 18:04:38 dpcl017 kernel: [895342.962258] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [TaskSchedulerBa:29775]
> Mar 27 18:04:38 dpcl017 kernel: [895342.962260] Modules linked in: cpuid fuse rfcomm pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) cpufreq_userspace vboxdrv(O) cpufreq_conservative cpufreq_powersave rpcsec_gs
> Mar 27 18:04:38 dpcl017 kernel: [895342.962289]  drm_kms_helper drm nvidia_modeset(PO) nvidia(PO) ip_tables x_tables autofs4 hid_generic usbhid hid ext4 crc16 jbd2 fscrypto ecb mbcache btrfs raid10 raid456 asyn
> Mar 27 18:04:38 dpcl017 kernel: [895342.962315] CPU: 1 PID: 29775 Comm: TaskSchedulerBa Tainted: P           O    4.9.0-6-amd64 #1 Debian 4.9.82-1+deb9u3
> Mar 27 18:04:38 dpcl017 kernel: [895342.962315] Hardware name: System manufacturer System Product Name/P8P67, BIOS 1503 03/10/2011
> Mar 27 18:04:38 dpcl017 kernel: [895342.962316] task: ffff8f3654f3d000 task.stack: ffffaf6348d10000
> Mar 27 18:04:38 dpcl017 kernel: [895342.962317] RIP: 0010:[<ffffffffbafc462b>]  [<ffffffffbafc462b>] page_mkclean+0x4b/0xc0
> Mar 27 18:04:38 dpcl017 kernel: [895342.962321] RSP: 0000:ffffaf6348d13be8  EFLAGS: 00000246
> Mar 27 18:04:38 dpcl017 kernel: [895342.962322] RAX: ffffaf6348d13bec RBX: ffffee2e0bc7d700 RCX: 0000000000000000
> Mar 27 18:04:38 dpcl017 kernel: [895342.962322] RDX: ffffee2e1092d420 RSI: 0000000000000000 RDI: ffffee2e0bc7d700
> Mar 27 18:04:38 dpcl017 kernel: [895342.962323] RBP: ffff8f354a94ab50 R08: 0000000000000101 R09: 0000000000000000
> Mar 27 18:04:38 dpcl017 kernel: [895342.962324] R10: 00000000033ac538 R11: 00000000034cdfd3 R12: ffff8f354a94ab50
> Mar 27 18:04:38 dpcl017 kernel: [895342.962324] R13: ffffaf6348d13c60 R14: 0000000000000000 R15: ffff8f354a94ab50
> Mar 27 18:04:38 dpcl017 kernel: [895342.962325] FS:  00007fd013827700(0000) GS:ffff8f377f480000(0000) knlGS:0000000000000000
> Mar 27 18:04:38 dpcl017 kernel: [895342.962326] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Mar 27 18:04:38 dpcl017 kernel: [895342.962327] CR2: 000015cb433c7208 CR3: 0000000320130000 CR4: 0000000000062670
> Mar 27 18:04:38 dpcl017 kernel: [895342.962327] Stack:
> Mar 27 18:04:38 dpcl017 kernel: [895342.962328]  00000000c19dcf1c ffffaf6348d13bec ffffffffbafc29e0 0000000000000000
> Mar 27 18:04:38 dpcl017 kernel: [895342.962330]  0000000000000000 0000000000000000 02a4b91511383e4f ffffee2e0bc7d700
> :
> :
> 
> 
> Full log is attached. Does this sound familiar?
> 
> 
> Every helpful comment is highly appreciated
> Harri
> 

