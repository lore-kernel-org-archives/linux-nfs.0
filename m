From: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Subject: NFS/AFS/Selinux issues with 2.26.29
Date: Wed, 25 Mar 2009 15:09:31 -0700
Message-ID: <49CAAB9B.5070104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:39298 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbZCYWJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 18:09:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


1) 2.6.29 NFS clients can no longer lock files:
   #strace -f lockfile fubar
   ...
   uname({sys="Linux", node="gothic-ave", ...}) = 0
   lstat64("_V0H.jaqyJB.gothic-ave", 0xbfdac9ec) = -1 ENOENT (No such file or directory)
   open("_V0H.jaqyJB.gothic-ave", O_WRONLY|O_CREAT|O_EXCL|O_LARGEFILE, 0444) = -1 EINVAL (Invalid argument)
   write(2, "lockfile: ", 10lockfile: )              = 10
   write(2, "Try praying", 11Try praying)             = 11
   write(2, ", giving up on \"", 16, giving up on ")       = 16
   write(2, "fubar", 5fubar)                    = 5
   write(2, "\"\n", 2"

   clients still on 2.6.28 and lower work fine ... the server *is* 2.26.29

2) SeLinux and (AFS or NFS) Oops:
---- NFS ---
Mar 24 21:09:20 el-ghor kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
Mar 24 21:09:20 el-ghor kernel: IP: [<ffffffff803628b7>] inode_has_perm+0x2c/0x72
Mar 24 21:09:20 el-ghor kernel: PGD 107d59067 PUD 1148e5067 PMD 0
Mar 24 21:09:20 el-ghor kernel: Oops: 0000 [#1] SMP
Mar 24 21:09:20 el-ghor kernel: last sysfs file: /sys/devices/platform/coretemp.1/temp1_label
Mar 24 21:09:20 el-ghor kernel: CPU 0
Mar 24 21:09:20 el-ghor kernel: Modules linked in: i915 drm i2c_algo_bit binfmt_misc ppdev lp openafs(P) rfcomm l2cap bluetooth kvm_intel kvm autofs4 battery acpi_cpufreq cpufreq_
Mar 24 21:09:20 el-ghor kernel: spkr serio_raw container button evdev snd_page_alloc dm_mirror dm_region_hash dm_log dm_snapshot sg usbhid usb_storage tg3 libphy uhci_hcd sr_mod c
Mar 24 21:09:20 el-ghor kernel: Pid: 10470, comm: nfsd Tainted: P           2.6.29 #20 8810D3U
Mar 24 21:09:20 el-ghor kernel: RIP: 0010:[<ffffffff803628b7>]  [<ffffffff803628b7>] inode_has_perm+0x2c/0x72
Mar 24 21:09:20 el-ghor kernel: RSP: 0000:ffff880078517c20  EFLAGS: 00010246
Mar 24 21:09:20 el-ghor kernel: RAX: 0000000000000000 RBX: 0000000000000004 RCX: 0000000000000000
Mar 24 21:09:20 el-ghor kernel: RDX: 0000000000000000 RSI: ffff880006a53560 RDI: 0000000000000000
Mar 24 21:09:20 el-ghor kernel: RBP: ffff880078517c80 R08: ffff88002d24cd40 R09: 0000000000000000
Mar 24 21:09:20 el-ghor kernel: R10: ffff880112ac1408 R11: 0000000000000004 R12: ffff880051fb3bc0
Mar 24 21:09:20 el-ghor kernel: R13: ffff880006a53560 R14: ffff88002d24cd40 R15: ffff880132a50180
Mar 24 21:09:20 el-ghor kernel: FS:  0000000000000000(0000) GS:ffffffff807be000(0000) knlGS:0000000000000000
Mar 24 21:09:20 el-ghor kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Mar 24 21:09:20 el-ghor kernel: CR2: 0000000000000004 CR3: 00000000bb07f000 CR4: 00000000000026e0
Mar 24 21:09:20 el-ghor kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 24 21:09:20 el-ghor kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 24 21:09:20 el-ghor kernel: Process nfsd (pid: 10470, threadinfo ffff880078516000, task ffff8800781842c0)
Mar 24 21:09:20 el-ghor kernel: Stack:
Mar 24 21:09:20 el-ghor kernel: 0000000000000000 ffff880078517c40 0000000000000286 0000000000000282
Mar 24 21:09:20 el-ghor kernel: ffff880078517c80 ffffffff802342fe ffff880112ac1408 0000000000000000
Mar 24 21:09:20 el-ghor kernel: ffff880112ac1408 ffffffff8054a010 ffff880078517cb0 0000000000000246
Mar 24 21:09:20 el-ghor kernel: Call Trace:
Mar 24 21:09:20 el-ghor kernel: [<ffffffff802342fe>] ? __wake_up+0x43/0x4f
Mar 24 21:09:20 el-ghor kernel: [<ffffffff803652ab>] selinux_dentry_open+0xe6/0xef
Mar 24 21:09:20 el-ghor kernel: [<ffffffff8035dd71>] security_dentry_open+0x11/0x13
Mar 24 21:09:20 el-ghor kernel: [<ffffffff802adbb5>] __dentry_open+0x12c/0x270
Mar 24 21:09:20 el-ghor kernel: [<ffffffff802add7c>] dentry_open+0x83/0x8c
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa037a33c>] nfsd_open+0x181/0x1b7 [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa037a5f4>] nfsd_write+0x8b/0xd9 [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa038166b>] nfsd3_proc_write+0xf0/0x110 [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa037525b>] nfsd_dispatch+0xe9/0x1ca [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa02ed208>] svc_process+0x3fd/0x723 [sunrpc]
Mar 24 21:09:20 el-ghor kernel: [<ffffffff8023a9f7>] ? default_wake_function+0x0/0xf
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa0375849>] nfsd+0x1c1/0x290 [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffffa0375688>] ? nfsd+0x0/0x290 [nfsd]
Mar 24 21:09:20 el-ghor kernel: [<ffffffff80254a43>] kthread+0x49/0x76
Mar 24 21:09:20 el-ghor kernel: [<ffffffff80211a9a>] child_rip+0xa/0x20
Mar 24 21:09:20 el-ghor kernel: [<ffffffff802549fa>] ? kthread+0x0/0x76
Mar 24 21:09:20 el-ghor kernel: [<ffffffff80211a90>] ? child_rip+0x0/0x20
Mar 24 21:09:20 el-ghor kernel: Code: 49 89 f8 48 89 e5 41 89 d3 48 83 ec 60 31 d2 8b 86 48 02 00 00 48 89 cf 41 89 c1 41 81 e1 00 02 00 00 75 49 49 8b 40 68 48 85 c9 <44> 8b 50 0
Mar 24 21:09:20 el-ghor kernel: RIP  [<ffffffff803628b7>] inode_has_perm+0x2c/0x72
Mar 24 21:09:20 el-ghor kernel: RSP <ffff880078517c20>
Mar 24 21:09:20 el-ghor kernel: CR2: 0000000000000004
Mar 24 21:09:20 el-ghor kernel: ---[ end trace 521b60133f9e33fc ]---

-- AFS --
Mar 24 14:33:54 bandit-hall kernel: BUG: unable to handle kernel NULL pointer dereference at 00000010
Mar 24 14:33:54 bandit-hall kernel: IP: [<c021ba99>] selinux_key_alloc+0x26/0x3b
Mar 24 14:33:54 bandit-hall kernel: *pde = 00000000
Mar 24 14:33:54 bandit-hall kernel: Oops: 0000 [#1] PREEMPT SMP
Mar 24 14:33:54 bandit-hall kernel: last sysfs file: /sys/class/power_supply/BAT0/energy_full
Mar 24 14:33:54 bandit-hall kernel: Modules linked in: radeon drm binfmt_misc ppdev lp openafs(P) bnep rfcomm l2cap ipt_ULOG nsc_irc
Mar 24 14:33:54 bandit-hall kernel: snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi irtty_sir snd_seq_midi_event ipw2100 thinkpad
Mar 24 14:33:54 bandit-hall kernel:
Mar 24 14:33:54 bandit-hall kernel: Pid: 20144, comm: ckpasswd Tainted: P           (2.6.29 #2) 2373MU3
Mar 24 14:33:54 bandit-hall kernel: EIP: 0060:[<c021ba99>] EFLAGS: 00010286 CPU: 0
Mar 24 14:33:54 bandit-hall kernel: EIP is at selinux_key_alloc+0x26/0x3b
Mar 24 14:33:54 bandit-hall kernel: EAX: fffffff4 EBX: ce673170 ECX: dd6232a0 EDX: 00000000
Mar 24 14:33:54 bandit-hall kernel: ESI: f66fb9c0 EDI: f66fba14 EBP: dd645d94 ESP: dd645d8c
Mar 24 14:33:54 bandit-hall kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Mar 24 14:33:54 bandit-hall kernel: Process ckpasswd (pid: 20144, ti=dd644000 task=ce673170 task.ti=dd644000)
Mar 24 14:33:54 bandit-hall kernel: Stack:
Mar 24 14:33:54 bandit-hall kernel: c0495f78 d5cf63c0 dd645da0 c0217eff f66fb9c0 dd645dd4 c02130e6 00000009
Mar 24 14:33:54 bandit-hall kernel: dd645df4 c0495898 0000000a 00000000 0000000b 0000001b 00004e20 ce673170
Mar 24 14:33:54 bandit-hall kernel: 00000009 00000009 dd645e14 f887a658 00000009 ce673170 1f3f0000 00000000
Mar 24 14:33:54 bandit-hall kernel: Call Trace:
Mar 24 14:33:54 bandit-hall kernel: [<c0217eff>] ? security_key_alloc+0x10/0x13
Mar 24 14:33:54 bandit-hall kernel: [<c02130e6>] ? key_alloc+0x185/0x2e6
Mar 24 14:33:54 bandit-hall kernel: [<f887a658>] ? setpag+0xa1/0x17d [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<f884a3f0>] ? AddPag+0x1d/0x22 [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<f884a4f2>] ? afs_setpag+0x9b/0xcd [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<f888289f>] ? afs_syscall+0x15d/0x14b6 [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<c013bb6c>] ? sched_clock_cpu+0x145/0x152
Mar 24 14:33:54 bandit-hall kernel: [<c021a469>] ? avc_has_perm+0x39/0x43
Mar 24 14:33:54 bandit-hall kernel: [<f887b508>] ? afs_unlocked_ioctl+0x42/0x4e [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<c01b4ad1>] ? proc_reg_unlocked_ioctl+0x62/0xad
Mar 24 14:33:54 bandit-hall kernel: [<f887b4c6>] ? afs_unlocked_ioctl+0x0/0x4e [openafs]
Mar 24 14:33:54 bandit-hall kernel: [<c01b4a6f>] ? proc_reg_unlocked_ioctl+0x0/0xad
Mar 24 14:33:54 bandit-hall kernel: [<c018e0af>] ? vfs_ioctl+0x22/0x69
Mar 24 14:33:54 bandit-hall kernel: [<c018e5e7>] ? do_vfs_ioctl+0x42d/0x466
Mar 24 14:33:54 bandit-hall kernel: [<c021b7f6>] ? selinux_file_ioctl+0x3e/0x42
Mar 24 14:33:54 bandit-hall kernel: [<c018e660>] ? sys_ioctl+0x40/0x5a
Mar 24 14:33:54 bandit-hall kernel: [<c0102ead>] ? sysenter_do_call+0x12/0x21
Mar 24 14:33:54 bandit-hall kernel: [<c0370000>] ? get_cpu_leaves+0xaa/0x15d
Mar 24 14:33:54 bandit-hall kernel: Code: 42 f6 ff 5d c3 55 89 e5 56 89 c6 a1 cc 3b 49 c0 53 89 d3 ba d0 80 00 00 e8 b1 47 f6 ff 89
Mar 24 14:33:54 bandit-hall kernel: EIP: [<c021ba99>] selinux_key_alloc+0x26/0x3b SS:ESP 0068:dd645d8c
Mar 24 14:33:54 bandit-hall kernel: ---[ end trace 826618641bc2453e ]---

-- 
Richard A Nelson (Rick)    cowboy@((linux.)?vnet|us).ibm.com
Phone: 1.408.463.5584      Fax: 1.408.463.3873
COBOL Development          IBM Silicon Valley Laboratory
http://www.ibm.com/software/awdtools/cobol/
