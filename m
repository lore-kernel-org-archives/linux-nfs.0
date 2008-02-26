From: Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>
Subject: Kernel (2.6.24) crash on nfsd (BUG: soft lockup)
Date: Tue, 26 Feb 2008 16:48:34 +0100
Message-ID: <47C434D2.80601@byte.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070900000203010204080103"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw.c1.byte.nl ([82.94.214.64]:40375 "EHLO smtp.byte.nl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751887AbYBZQNl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 11:13:41 -0500
Received: from [192.168.1.145] (a82-95-102-2.adsl.xs4all.nl [82.95.102.2])
	by smtp.byte.nl (Postfix) with ESMTP id 810825E3F8
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 16:48:34 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070900000203010204080103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi!
One of our fileservers went down pretty hard yesterday. We recently 
upgraded the kernel to 2.6.24 because we suffered from the lockd-lockup 
with our previous kernel (2.6.18).
The server stopped responding completely to any requests (nfs, ssh, 
ping) and every few seconds a stacktrace was dumped on the console. The 
stacktraces hint at nfsd (Pid: 2716, comm: nfsd Not tainted 
(2.6.24.2-fwsh-byte #2) and various nfs-functions in the trace). I 
attached some of them to this message.

Do these stacktraces seem familiar to anyone? I couldn't find any 
similar crashes with google.

-- 

Met vriendelijke groet,

Gertjan Oude Lohuis
Byte Internet

W www.byte.nl
E support-DW70C6hi67U@public.gmane.org
F 020 6255 922

--------------070900000203010204080103
Content-Type: text/plain;
 name="stacktrace.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stacktrace.txt"

BUG: soft lockup - CPU#0 stuck for 11s! [nfsd:2716]

Pid: 2716, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 0
EIP is at find_get_pages_contig+0x67/0x73
EAX: 00000000 EBX: 00000001 ECX: c25cc520 EDX: c25cc520
ESI: 00000078 EDI: ca2fbdbc EBP: 00000001 ESP: dffb5c6c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7f5d000 CR3: 1fc45000 CR4: 000006f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c017c49c>] __generic_file_splice_read+0xa2/0x41e
 [<c0113b11>] sched_slice+0x15/0x6f
 [<c0131291>] getnstimeofday+0x31/0x105
 [<c0134301>] clockevents_program_event+0xbf/0x134
 [<c012ef49>] ktime_get_ts+0x15/0x47
 [<c01231ea>] run_timer_softirq+0x30/0x184
 [<c012a893>] __rcu_process_callbacks+0x76/0xbb
 [<c011f979>] tasklet_action+0x53/0x93
 [<c011f754>] __do_softirq+0xba/0xcf
 [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
 [<c01032e0>] apic_timer_interrupt+0x28/0x30
 [<c017c88d>] generic_file_splice_read+0x75/0xc9
 [<c017d083>] do_splice_to+0x6e/0x90
 [<c017d144>] splice_direct_to_actor+0x9f/0x166
 [<f8f2cf72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
 [<c017c818>] generic_file_splice_read+0x0/0xc9
 [<f8f2d309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
 [<f8f2b3b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
 [<c016014f>] dentry_open+0x34/0x64
 [<f8f2d73c>] nfsd_read+0xee/0xfb [nfsd]
 [<f8f33b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
 [<f8f354cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
 [<f8f29855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
 [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
 [<c0441ad1>] svc_process+0x4e9/0x6b4
 [<c01168e2>] default_wake_function+0x0/0x8
 [<f8f2963d>] nfsd+0x16a/0x290 [nfsd]
 [<f8f294d3>] nfsd+0x0/0x290 [nfsd]
 [<c0103463>] kernel_thread_helper+0x7/0x10
 =======================


BUG: soft lockup - CPU#0 stuck for 11s! [nfsd:2716]

Pid: 2716, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 0
EIP is at find_get_pages_contig+0x67/0x73
EAX: 00000000 EBX: 00000001 ECX: c25cc520 EDX: c25cc520
ESI: 00000078 EDI: ca2fbdbc EBP: 00000001 ESP: dffb5c6c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7f5d000 CR3: 1fc45000 CR4: 000006f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c017c49c>] __generic_file_splice_read+0xa2/0x41e
 [<c0132efc>] clocksource_get_next+0x3a/0x40
 [<c0113b11>] sched_slice+0x15/0x6f
 [<c0131291>] getnstimeofday+0x31/0x105
 [<c0134301>] clockevents_program_event+0xbf/0x134
 [<c012ef49>] ktime_get_ts+0x15/0x47
 [<c01231ea>] run_timer_softirq+0x30/0x184
 [<c012a893>] __rcu_process_callbacks+0x76/0xbb
 [<c011f979>] tasklet_action+0x53/0x93
 [<c011f754>] __do_softirq+0xba/0xcf
 [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
 [<c01032e0>] apic_timer_interrupt+0x28/0x30
 [<c017007b>] locks_show+0x0/0x67
 [<c017c88d>] generic_file_splice_read+0x75/0xc9
 [<c017d083>] do_splice_to+0x6e/0x90
 [<c017d144>] splice_direct_to_actor+0x9f/0x166
 [<f8f2cf72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
 [<c017c818>] generic_file_splice_read+0x0/0xc9
 [<f8f2d309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
 [<f8f2b3b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
 [<c016014f>] dentry_open+0x34/0x64
 [<f8f2d73c>] nfsd_read+0xee/0xfb [nfsd]
 [<f8f33b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
 [<f8f354cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
 [<f8f29855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
 [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
 [<c0441ad1>] svc_process+0x4e9/0x6b4
 [<c01168e2>] default_wake_function+0x0/0x8
 [<f8f2963d>] nfsd+0x16a/0x290 [nfsd]
 [<f8f294d3>] nfsd+0x0/0x290 [nfsd]
 [<c0103463>] kernel_thread_helper+0x7/0x10
 =======================


BUG: soft lockup - CPU#0 stuck for 11s! [nfsd:2716]

Pid: 2716, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
EIP: 0060:[<c017c88f>] EFLAGS: 00000246 CPU: 0
EIP is at generic_file_splice_read+0x77/0xc9
EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000000
ESI: 00000000 EDI: 00000000 EBP: 00001000 ESP: dffb5df0
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7f5d000 CR3: 1fc45000 CR4: 000006f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c017d083>] do_splice_to+0x6e/0x90
 [<c017d144>] splice_direct_to_actor+0x9f/0x166
 [<f8f2cf72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
 [<c017c818>] generic_file_splice_read+0x0/0xc9
 [<f8f2d309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
 [<f8f2b3b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
 [<c016014f>] dentry_open+0x34/0x64
 [<f8f2d73c>] nfsd_read+0xee/0xfb [nfsd]
 [<f8f33b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
 [<f8f354cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
 [<f8f29855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
 [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
 [<c0441ad1>] svc_process+0x4e9/0x6b4
 [<c01168e2>] default_wake_function+0x0/0x8
 [<f8f2963d>] nfsd+0x16a/0x290 [nfsd]
 [<f8f294d3>] nfsd+0x0/0x290 [nfsd]
 [<c0103463>] kernel_thread_helper+0x7/0x10
 ======================= 

--------------070900000203010204080103--
