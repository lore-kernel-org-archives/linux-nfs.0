From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel 2.6.23.17 crash (Was: Kernel (2.6.24) crash on nfsd
	(BUG: soft lockup))
Date: Sat, 1 Mar 2008 11:39:44 -0500
Message-ID: <20080301163944.GC19927@fieldses.org>
References: <47C434D2.80601@byte.nl> <47C50754.5030107@byte.nl> <47C50ABB.8050700@byte.nl> <Pine.LNX.4.62.0802281153040.31013@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, "Nilssen, Rune" <rune.nilssen-FJFKJQU35qU@public.gmane.org>,
	Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>
To: Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41670 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbYCAQjr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Mar 2008 11:39:47 -0500
In-Reply-To: <Pine.LNX.4.62.0802281153040.31013-FHjt3+7qfYHBZBx2VKNGNcSTQT6m/s+e@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2008 at 11:56:51AM +0100, Allard Hoeve wrote:
> After trying 2.6.23.17, the same happened. The stacktrace is a bit  
> different, but they are comparable.
>
> Is this an NFS problem in the first place? Where could we go for help 
> with this problem?

Thanks for the reports!

So, the summary: several people are reporting soft lockup warnings with
_generic_file_splice_read as the latest or next-to-latest function on
the stack.  Sounds like 2.6.18 is good, various kernels around 2.6.23
and 2.6.24 are reported bad.  Is it possible this was a regression
introduced by the splice changes?

--b.

>
> Regards,
>
> Allard Hoeve
>
>
>
> Pid: 2643, comm:                 nfsd
> EIP: 0060:[<c0179a3a>] CPU: 3
> EIP is at __generic_file_splice_read+0x12c/0x418
>  EFLAGS: 00000206    Not tainted  (2.6.23.17-fwsh-byte #3)
> EAX: f6e9dddc EBX: 00001000 ECX: 00000001 EDX: 00000000
> ESI: 00000000 EDI: f6e9dcd0 EBP: 00000095 DS: 007b ES: 007b FS: 00d8
> CR0: 8005003b CR2: b7e72cc0 CR3: 00622000 CR4: 000006f0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
>  [<c0113cbb>] __check_preempt_curr_fair+0x4b/0x7d
>  [<c0113dcb>] entity_tick+0x47/0x54
>  [<c013006b>] getnstimeofday+0x37/0x111
>  [<c0132fb6>] clockevents_program_event+0xac/0xcc
>  [<c0122996>] run_timer_softirq+0x30/0x184
>  [<c012f36f>] hrtimer_interrupt+0x132/0x1c4
>  [<c011f0e0>] __do_softirq+0xba/0xcf
>  [<c010da6a>] smp_apic_timer_interrupt+0x2c/0x35
>  [<c01032bc>] apic_timer_interrupt+0x28/0x30
>  [<c0179da7>] generic_file_splice_read+0x81/0xd5
>  [<c017a6b0>] do_splice_to+0x75/0x97
>  [<c017a771>] splice_direct_to_actor+0x9f/0x166
>  [<f8f2a494>] nfsd_acceptable+0x0/0xd1 [nfsd]
>  [<f8f2c247>] nfsd_direct_splice_actor+0x0/0xa [nfsd]
>  [<f8f2c5ea>] nfsd_vfs_read+0x399/0x3bd [nfsd]
>  [<c015d57f>] dentry_open+0x34/0x64
>  [<f8f2ca1d>] nfsd_read+0xee/0xfb [nfsd]
>  [<f8f332ab>] nfsd3_proc_read+0xfe/0x186 [nfsd]
>  [<f8f34cd9>] nfs3svc_decode_readargs+0x0/0xeb [nfsd]
>  [<f8f28847>] nfsd_dispatch+0xc5/0x1ca [nfsd]
>  [<c043ab82>] svcauth_unix_set_client+0x116/0x165
>  [<c0436b96>] svc_process+0x4fb/0x6d4
>  [<c01164ad>] default_wake_function+0x0/0xc
>  [<f8f2863d>] nfsd+0x16a/0x282 [nfsd]
>  [<f8f284d3>] nfsd+0x0/0x282 [nfsd]
>  [<c010343f>] kernel_thread_helper+0x7/0x10
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
