From: Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>
Subject: Re: Kernel (2.6.24) crash on nfsd (BUG: soft lockup)
Date: Wed, 27 Feb 2008 07:46:44 +0100
Message-ID: <47C50754.5030107@byte.nl>
References: <47C434D2.80601@byte.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050006050200080600030509"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw.c1.byte.nl ([82.94.214.64]:51508 "EHLO smtp.byte.nl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752223AbYB0Gqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 01:46:32 -0500
Received: from [10.1.1.200] (5353B049.cable.casema.nl [83.83.176.73])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.byte.nl (Postfix) with ESMTP id D47EF62187
	for <linux-nfs@vger.kernel.org>; Wed, 27 Feb 2008 07:46:30 +0100 (CET)
In-Reply-To: <47C434D2.80601-DW70C6hi67U@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050006050200080600030509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Gertjan Oude Lohuis wrote:
> One of our fileservers went down pretty hard yesterday. We recently 
> upgraded the kernel to 2.6.24 because we suffered from the 
> lockd-lockup with our previous kernel (2.6.18).
> The server stopped responding completely to any requests (nfs, ssh, 
> ping) and every few seconds a stacktrace was dumped on the console. 
> The stacktraces hint at nfsd (Pid: 2716, comm: nfsd Not tainted 
> (2.6.24.2-fwsh-byte #2) and various nfs-functions in the trace). I 
> attached some of them to this message.

This morning the same server crashed again, with the same stacktrace (at 
least to my eyes :-)). I think we'll be downgrading to 2.6.23 as soon as 
possible. Is there anything I can do to get more debug information? Now 
or when it crashes? When the server crashes, I'm able to logging to it 
with the serial console, and reboot it with 'send break -> b'.

Regards,
Gertjan Oude Lohuis


--------------050006050200080600030509
Content-Type: text/plain;
 name="stacktrace.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stacktrace.txt"

BUG: soft lockup - CPU#2 stuck for 11s! [nfsd:2775]

Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 2
EIP is at find_get_pages_contig+0x67/0x73
EAX: 00000000 EBX: 00000002 ECX: c235c8e0 EDX: c235c8e0
ESI: 00000110 EDI: d7f2c69c EBP: 00000002 ESP: f604fc6c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7fb8000 CR3: 355be000 CR4: 000006f0
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
 [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
 [<c017c818>] generic_file_splice_read+0x0/0xc9
 [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
 [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
 [<c016014f>] dentry_open+0x34/0x64
 [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
 [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
 [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
 [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
 [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
 [<c0441ad1>] svc_process+0x4e9/0x6b4
 [<c01168e2>] default_wake_function+0x0/0x8
 [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
 [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
 [<c0103463>] kernel_thread_helper+0x7/0x10
 =======================

BUG: soft lockup - CPU#2 stuck for 11s! [nfsd:2775]

Pid: 2775, comm: nfsd Not tainted (2.6.24.2-fwsh-byte #2)
EIP: 0060:[<c0140967>] EFLAGS: 00000286 CPU: 2
EIP is at find_get_pages_contig+0x67/0x73
EAX: 00000000 EBX: 00000002 ECX: c235c8e0 EDX: c235c8e0
ESI: 00000110 EDI: d7f2c69c EBP: 00000002 ESP: f604fc6c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7fb8000 CR3: 355be000 CR4: 000006f0
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
 [<f8f32f72>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
 [<c017c818>] generic_file_splice_read+0x0/0xc9
 [<f8f33309>] nfsd_vfs_read+0x38d/0x3b1 [nfsd]
 [<f8f313b8>] nfsd_acceptable+0x0/0xd1 [nfsd]
 [<c016014f>] dentry_open+0x34/0x64
 [<f8f3373c>] nfsd_read+0xee/0xfb [nfsd]
 [<f8f39b8b>] nfsd3_proc_read+0xfe/0x186 [nfsd]
 [<f8f3b4cb>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
 [<f8f2f855>] nfsd_dispatch+0xc5/0x1ac [nfsd]
 [<c0445ab2>] svcauth_unix_set_client+0x116/0x165
 [<c0441ad1>] svc_process+0x4e9/0x6b4
 [<c01168e2>] default_wake_function+0x0/0x8
 [<f8f2f63d>] nfsd+0x16a/0x290 [nfsd]
 [<f8f2f4d3>] nfsd+0x0/0x290 [nfsd]
 [<c0103463>] kernel_thread_helper+0x7/0x10
 =======================


--------------050006050200080600030509--
