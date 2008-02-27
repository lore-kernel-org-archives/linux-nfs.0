From: Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>
Subject: Re: Kernel (2.6.24) crash on nfsd (BUG: soft lockup)
Date: Wed, 27 Feb 2008 08:01:15 +0100
Message-ID: <47C50ABB.8050700@byte.nl>
References: <47C434D2.80601@byte.nl> <47C50754.5030107@byte.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090200000502080407010002"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw.c1.byte.nl ([82.94.214.64]:54629 "EHLO smtp.byte.nl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753910AbYB0HA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 02:00:59 -0500
Received: from [10.1.1.200] (5353B049.cable.casema.nl [83.83.176.73])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.byte.nl (Postfix) with ESMTP id 7CAD85E481
	for <linux-nfs@vger.kernel.org>; Wed, 27 Feb 2008 08:00:56 +0100 (CET)
In-Reply-To: <47C50754.5030107-DW70C6hi67U@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090200000502080407010002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Gertjan Oude Lohuis wrote:
> This morning the same server crashed again, with the same stacktrace 
> (at least to my eyes :-)). I think we'll be downgrading to 2.6.23 as 
> soon as possible. Is there anything I can do to get more debug 
> information? Now or when it crashes? When the server crashes, I'm able 
> to logging to it with the serial console, and reboot it with 'send 
> break -> b'.

This keeps getting weirder. When browsing the servers logfiles, I 
noticed that the server has exactly the same errors in /var/log/messages 
yesterday night, around 1:52 AM. However, the server did not crash then. 
We didn't notice earlier, because most notifications are suppressed 
during the night. Apparently, Linux can recover from this bug, given 
enough time.
What expert can help me understand this problem?

Regards,
Gertjan Oude Lohuis

--------------090200000502080407010002
Content-Type: text/plain;
 name="stacktrace2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stacktrace2.txt"

Feb 26 01:52:00 file1 kernel: BUG: soft lockup - CPU#3 stuck for 11s! [nfsd:2775]
Feb 26 01:52:00 file1 kernel:
Feb 26 01:52:00 file1 kernel: Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
Feb 26 01:52:00 file1 kernel: EIP: 0060:[<c0147be0>] EFLAGS: 00000246 CPU: 3
Feb 26 01:52:00 file1 kernel: EIP is at put_page+0x9/0x20
Feb 26 01:52:00 file1 kernel: EAX: 80000008 EBX: 00000000 ECX: 00000002 EDX: c2a71240
Feb 26 01:52:00 file1 kernel: ESI: 00000000 EDI: e6ee08fc EBP: 00000087 ESP: f604fc7c
Feb 26 01:52:00 file1 kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 01:52:00 file1 kernel: CR0: 8005003b CR2: 080a7070 CR3: 36cbd000 CR4: 000006f0
Feb 26 01:52:00 file1 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 01:52:00 file1 kernel: DR6: ffff0ff0 DR7: 00000400
Feb 26 01:52:00 file1 kernel: [<c017c6bc>] __generic_file_splice_read+0x2c2/0x41e
Feb 26 01:52:00 file1 kernel: [<c0113b11>] sched_slice+0x15/0x6f
Feb 26 01:52:00 file1 kernel: [<c0131291>] getnstimeofday+0x31/0x105
Feb 26 01:52:01 file1 kernel: [<c0134301>] clockevents_program_event+0xbf/0x134
Feb 26 01:52:01 file1 kernel: [<c012ef49>] ktime_get_ts+0x15/0x47
Feb 26 01:52:01 file1 kernel: [<c01231ea>] run_timer_softirq+0x30/0x184
Feb 26 01:52:01 file1 kernel: [<c012a893>] __rcu_process_callbacks+0x76/0xbb
Feb 26 01:52:01 file1 kernel: [<c011f979>] tasklet_action+0x53/0x93
Feb 26 01:52:01 file1 kernel: [<c011f754>] __do_softirq+0xba/0xcf
Feb 26 01:52:01 file1 kernel: [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
Feb 26 01:52:01 file1 kernel: [<c01032e0>] apic_timer_interrupt+0x28/0x30
Feb 26 01:52:01 file1 kernel: [<c017c88d>] generic_file_splice_read+0x75/0xc9
Feb 26 01:52:01 file1 kernel: [<c017d083>] do_splice_to+0x6e/0x90
Feb 26 01:52:01 file1 kernel: [<c017d144>] splice_direct_to_actor+0x9f/0x166
Feb 26 01:52:01 file1 kernel: [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
Feb 26 01:52:01 file1 kernel: [<c017c818>] generic_file_splice_read+0x0/0xc9
Feb 26 01:52:01 file1 kernel: [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
Feb 26 01:52:01 file1 kernel: [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
Feb 26 01:52:01 file1 kernel: [<c016014f>] dentry_open+0x34/0x64
Feb 26 01:52:01 file1 kernel: [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
Feb 26 01:52:01 file1 kernel: [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
Feb 26 01:52:01 file1 kernel: [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
Feb 26 01:52:01 file1 kernel: [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
Feb 26 01:52:01 file1 kernel: [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
Feb 26 01:52:02 file1 kernel: [<c0441ad1>] svc_process+0x4e9/0x6b4
Feb 26 01:52:02 file1 kernel: [<c01168e2>] default_wake_function+0x0/0x8
Feb 26 01:52:02 file1 kernel: [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
Feb 26 01:52:02 file1 kernel: [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
Feb 26 01:52:02 file1 kernel: [<c0103463>] kernel_thread_helper+0x7/0x10
Feb 26 01:52:02 file1 kernel: =======================
Feb 26 01:52:14 file1 kernel: BUG: soft lockup - CPU#3 stuck for 11s! [nfsd:2775]
Feb 26 01:52:14 file1 kernel:
Feb 26 01:52:14 file1 kernel: Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
Feb 26 01:52:14 file1 kernel: EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 3
Feb 26 01:52:14 file1 kernel: EIP is at find_get_pages_contig+0x67/0x73
Feb 26 01:52:14 file1 kernel: EAX: 00000000 EBX: 00000002 ECX: c2a71260 EDX: c2a71260
Feb 26 01:52:14 file1 kernel: ESI: 00000089 EDI: e6ee09ac EBP: 00000002 ESP: f604fc6c
Feb 26 01:52:14 file1 kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 01:52:14 file1 kernel: CR0: 8005003b CR2: 080a7070 CR3: 36cbd000 CR4: 000006f0
Feb 26 01:52:14 file1 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 01:52:14 file1 kernel: DR6: ffff0ff0 DR7: 00000400
Feb 26 01:52:14 file1 kernel: [<c017c49c>] __generic_file_splice_read+0xa2/0x41e
Feb 26 01:52:14 file1 kernel: [<c0113b11>] sched_slice+0x15/0x6f
Feb 26 01:52:14 file1 kernel: [<c0131291>] getnstimeofday+0x31/0x105
Feb 26 01:52:14 file1 kernel: [<c0134301>] clockevents_program_event+0xbf/0x134
Feb 26 01:52:14 file1 kernel: [<c012ef49>] ktime_get_ts+0x15/0x47
Feb 26 01:52:14 file1 kernel: [<c01231ea>] run_timer_softirq+0x30/0x184
Feb 26 01:52:14 file1 kernel: [<c012a893>] __rcu_process_callbacks+0x76/0xbb
Feb 26 01:52:14 file1 kernel: [<c011f979>] tasklet_action+0x53/0x93
Feb 26 01:52:14 file1 kernel: [<c011f754>] __do_softirq+0xba/0xcf
Feb 26 01:52:14 file1 kernel: [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
Feb 26 01:52:15 file1 kernel: [<c01032e0>] apic_timer_interrupt+0x28/0x30
Feb 26 01:52:15 file1 kernel: [<c017c88d>] generic_file_splice_read+0x75/0xc9
Feb 26 01:52:15 file1 kernel: [<c017d083>] do_splice_to+0x6e/0x90
Feb 26 01:52:15 file1 kernel: [<c017d144>] splice_direct_to_actor+0x9f/0x166
Feb 26 01:52:15 file1 kernel: [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
Feb 26 01:52:15 file1 kernel: [<c017c818>] generic_file_splice_read+0x0/0xc9
Feb 26 01:52:15 file1 kernel: [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
Feb 26 01:52:15 file1 kernel: [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
Feb 26 01:52:15 file1 kernel: [<c016014f>] dentry_open+0x34/0x64
Feb 26 01:52:15 file1 kernel: [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
Feb 26 01:52:15 file1 kernel: [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
Feb 26 01:52:15 file1 kernel: [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
Feb 26 01:52:15 file1 kernel: [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
Feb 26 01:52:15 file1 kernel: [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
Feb 26 01:52:15 file1 kernel: [<c0441ad1>] svc_process+0x4e9/0x6b4
Feb 26 01:52:15 file1 kernel: [<c01168e2>] default_wake_function+0x0/0x8
Feb 26 01:52:15 file1 kernel: [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
Feb 26 01:52:15 file1 kernel: [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
Feb 26 01:52:15 file1 kernel: [<c0103463>] kernel_thread_helper+0x7/0x10
Feb 26 01:52:15 file1 kernel: =======================
Feb 26 01:52:27 file1 kernel: BUG: soft lockup - CPU#3 stuck for 11s! [nfsd:2775]
Feb 26 01:52:27 file1 kernel:
Feb 26 01:52:27 file1 kernel: Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
Feb 26 01:52:27 file1 kernel: EIP: 0060:[<c014096a>] EFLAGS: 00000286 CPU: 3
Feb 26 01:52:27 file1 kernel: EIP is at find_get_pages_contig+0x6a/0x73
Feb 26 01:52:27 file1 kernel: EAX: 00000002 EBX: 00000002 ECX: c2a71260 EDX: c2a71260
Feb 26 01:52:28 file1 kernel: ESI: 00000089 EDI: e6ee09ac EBP: 00000002 ESP: f604fc70
Feb 26 01:52:28 file1 kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 01:52:28 file1 kernel: CR0: 8005003b CR2: 080a7070 CR3: 36cbd000 CR4: 000006f0
Feb 26 01:52:28 file1 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 01:52:28 file1 kernel: DR6: ffff0ff0 DR7: 00000400
Feb 26 01:52:28 file1 kernel: [<c017c49c>] __generic_file_splice_read+0xa2/0x41e
Feb 26 01:52:28 file1 kernel: [<c0113b11>] sched_slice+0x15/0x6f
Feb 26 01:52:28 file1 kernel: [<c0131291>] getnstimeofday+0x31/0x105
Feb 26 01:52:28 file1 kernel: [<c0134301>] clockevents_program_event+0xbf/0x134
Feb 26 01:52:28 file1 kernel: [<c012ef49>] ktime_get_ts+0x15/0x47
Feb 26 01:52:28 file1 kernel: [<c01231ea>] run_timer_softirq+0x30/0x184
Feb 26 01:52:28 file1 kernel: [<c012a893>] __rcu_process_callbacks+0x76/0xbb
Feb 26 01:52:28 file1 kernel: [<c011f979>] tasklet_action+0x53/0x93
Feb 26 01:52:28 file1 kernel: [<c011f754>] __do_softirq+0xba/0xcf
Feb 26 01:52:28 file1 kernel: [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
Feb 26 01:52:28 file1 kernel: [<c01032e0>] apic_timer_interrupt+0x28/0x30
Feb 26 01:52:28 file1 kernel: [<c01700d8>] locks_show+0x5d/0x67
Feb 26 01:52:28 file1 kernel: [<c017c88d>] generic_file_splice_read+0x75/0xc9
Feb 26 01:52:28 file1 kernel: [<c017d083>] do_splice_to+0x6e/0x90
Feb 26 01:52:28 file1 kernel: [<c017d144>] splice_direct_to_actor+0x9f/0x166
Feb 26 01:52:29 file1 kernel: [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
Feb 26 01:52:29 file1 kernel: [<c017c818>] generic_file_splice_read+0x0/0xc9
Feb 26 01:52:29 file1 kernel: [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
Feb 26 01:52:29 file1 kernel: [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
Feb 26 01:52:29 file1 kernel: [<c016014f>] dentry_open+0x34/0x64
Feb 26 01:52:29 file1 kernel: [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
Feb 26 01:52:29 file1 kernel: [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
Feb 26 01:52:29 file1 kernel: [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
Feb 26 01:52:29 file1 kernel: [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
Feb 26 01:52:29 file1 kernel: [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
Feb 26 01:52:29 file1 kernel: [<c0441ad1>] svc_process+0x4e9/0x6b4
Feb 26 01:52:29 file1 kernel: [<c01168e2>] default_wake_function+0x0/0x8
Feb 26 01:52:29 file1 kernel: [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
Feb 26 01:52:29 file1 kernel: [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
Feb 26 01:52:29 file1 kernel: [<c0103463>] kernel_thread_helper+0x7/0x10
Feb 26 01:52:29 file1 kernel: =======================
Feb 26 01:52:41 file1 kernel: BUG: soft lockup - CPU#3 stuck for 11s! [nfsd:2775]
Feb 26 01:52:41 file1 kernel:
Feb 26 01:52:41 file1 kernel: Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
Feb 26 01:52:41 file1 kernel: EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 3
Feb 26 01:52:41 file1 kernel: EIP is at find_get_pages_contig+0x67/0x73
Feb 26 01:52:41 file1 kernel: EAX: 00000000 EBX: 00000002 ECX: c2a71260 EDX: c2a71260
Feb 26 01:52:41 file1 kernel: ESI: 00000089 EDI: e6ee09ac EBP: 00000002 ESP: f604fc6c
Feb 26 01:52:41 file1 kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 01:52:41 file1 kernel: CR0: 8005003b CR2: 080a7070 CR3: 36cbd000 CR4: 000006f0
Feb 26 01:52:41 file1 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 01:52:42 file1 kernel: DR6: ffff0ff0 DR7: 00000400
Feb 26 01:52:42 file1 kernel: [<c017c49c>] __generic_file_splice_read+0xa2/0x41e
Feb 26 01:52:42 file1 kernel: [<c0113b11>] sched_slice+0x15/0x6f
Feb 26 01:52:42 file1 kernel: [<c0131291>] getnstimeofday+0x31/0x105
Feb 26 01:52:42 file1 kernel: [<c0134301>] clockevents_program_event+0xbf/0x134
Feb 26 01:52:42 file1 kernel: [<c012ef49>] ktime_get_ts+0x15/0x47
Feb 26 01:52:42 file1 kernel: [<c01231ea>] run_timer_softirq+0x30/0x184
Feb 26 01:52:42 file1 kernel: [<c012a893>] __rcu_process_callbacks+0x76/0xbb
Feb 26 01:52:42 file1 kernel: [<c011f979>] tasklet_action+0x53/0x93
Feb 26 01:52:42 file1 kernel: [<c011f754>] __do_softirq+0xba/0xcf
Feb 26 01:52:42 file1 kernel: [<c010e20e>] smp_apic_timer_interrupt+0x2c/0x35
Feb 26 01:52:42 file1 kernel: [<c01032e0>] apic_timer_interrupt+0x28/0x30
Feb 26 01:52:42 file1 kernel: [<c017c88d>] generic_file_splice_read+0x75/0xc9
Feb 26 01:52:42 file1 kernel: [<c017d083>] do_splice_to+0x6e/0x90
Feb 26 01:52:42 file1 kernel: [<c017d144>] splice_direct_to_actor+0x9f/0x166
Feb 26 01:52:42 file1 kernel: [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
Feb 26 01:52:42 file1 kernel: [<c017c818>] generic_file_splice_read+0x0/0xc9
Feb 26 01:52:42 file1 kernel: [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
Feb 26 01:52:42 file1 kernel: [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
Feb 26 01:52:42 file1 kernel: [<c016014f>] dentry_open+0x34/0x64
Feb 26 01:52:43 file1 kernel: [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
Feb 26 01:52:43 file1 kernel: [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
Feb 26 01:52:43 file1 kernel: [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
Feb 26 01:52:43 file1 kernel: [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
Feb 26 01:52:43 file1 kernel: [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
Feb 26 01:52:43 file1 kernel: [<c0441ad1>] svc_process+0x4e9/0x6b4
Feb 26 01:52:43 file1 kernel: [<c01168e2>] default_wake_function+0x0/0x8
Feb 26 01:52:43 file1 kernel: [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
Feb 26 01:52:43 file1 kernel: [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
Feb 26 01:52:43 file1 kernel: [<c0103463>] kernel_thread_helper+0x7/0x10
Feb 26 01:52:43 file1 kernel: =======================

--------------090200000502080407010002--
