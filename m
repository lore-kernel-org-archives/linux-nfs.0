From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: [2.6.34-rc2 NFS4 oops] open error path failure...
Date: Mon, 29 Mar 2010 19:36:45 +0100
Message-ID: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:36236 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab0C2Sgr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Mar 2010 14:36:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

When open fails and should return EPERM [1], instead we see an oops
[2]. I see this on 2.6.34-rc1 and -rc2 mainline; NFS4 server is
mainline 2.6.33.1.

Let me know if you can't reproduce it and I'll provide some analysis
from this end.

Thanks,
  Daniel

--- [1]

$ touch /tmp/foo
$ sudo chmod 0 /tmp/foo
$ cat /tmp/foo
cat: /tmp/foo: Permission denied

$ touch /net/users/daniel/foo
$ sudo chmod 0 /net/users/daniel/foo
$ cat /net/users/daniel/foo
Killed

--- [2]

BUG: unable to handle kernel NULL pointer dereference at 000000000000000b
IP: [<ffffffff8115036e>] nameidata_to_filp+0x1e/0x70
PGD 840d3067 PUD 841eb067 PMD 0
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
CPU 4
Modules linked in: usb_storage nls_iso8859_1 nls_cp437 vfat fat
binfmt_misc rfcomm sco bnep l2cap kvm_intel kvm microcode btusb
bluetooth arc4 ecb uvcvideo iwlagn videodev iwlcore v4l1_compat
v4l2_compat_ioctl32 mac80211

Pid: 20644, comm: perf Tainted: G        W  2.6.34-rc2-317cd #2
0KM426/Studio 1557
RIP: 0010:[<ffffffff8115036e>]  [<ffffffff8115036e>] nameidata_to_filp+0x1e/0x70
RSP: 0018:ffff88008fd31d38  EFLAGS: 00010292
RAX: ffff88012c1825a0 RBX: fffffffffffffff3 RCX: 0000000000000041
RDX: 0000000000008000 RSI: 0000000000000024 RDI: ffff88008fd31e18
RBP: ffff88008fd31d48 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000008000
R13: 0000000000000000 R14: 0000000000000000 R15: ffff88012f8c3180
FS:  00007fd781585700(0000) GS:ffff880010800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000000000b CR3: 00000000842a3000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process perf (pid: 20644, threadinfo ffff88008fd30000, task ffff88012c1825a0)
Stack:
 ffff88008fd31e18 ffff88008fd31e18 ffff88008fd31da8 ffffffff8115e7f8
<0> ffff88008fd31d88 ffffffff81301018 ffff88012a121500 000000242a121500
<0> ffff88013250b6c0 ffff88008fd31e18 0000000000000000 ffff88012f8c3180
Call Trace:
 [<ffffffff8115e7f8>] do_last+0x348/0x740
 [<ffffffff81301018>] ? __raw_spin_lock_init+0x38/0x70
 [<ffffffff81160de9>] do_filp_open+0x219/0x690
 [<ffffffff816e59b9>] ? sub_preempt_count+0xa9/0xe0
 [<ffffffff8116c912>] ? alloc_fd+0x132/0x1b0
 [<ffffffff8114fcd9>] do_sys_open+0x69/0x140
 [<ffffffff816e0d92>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8114fdf0>] sys_open+0x20/0x30
 [<ffffffff81003172>] system_call_fastpath+0x16/0x1b
Code: cc 58 00 48 c7 c0 ea ff ff ff eb 82 90 55 48 89 e5 53 48 83 ec
08 0f 1f 44 00 00 48 8b 9f 90 00 00 00 65 48 8b 04 25 40 b5 00 00 <48>
83 7b 18 00 4c 8b 80 18 06 00 00 74 14 e8 2f c4 00 00 48 89
RIP  [<ffffffff8115036e>] nameidata_to_filp+0x1e/0x70
 RSP <ffff88008fd31d38>
CR2: 000000000000000b
---[ end trace 525ed01cba1a212e ]---
-- 
Daniel J Blueman
