Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33522 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753645Ab1HZXdE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 19:33:04 -0400
Date: Sat, 27 Aug 2011 00:32:58 +0100
From: Ben Hutchings <ben@decadent.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Message-ID: <20110826233258.GE24107@decadent.org.uk>
References: <1312810169.2591.1153.camel@deadeye>
 <20110808155538.GB904@fieldses.org>
 <20110808180658.GC29924@decadent.org.uk>
 <20110826220311.GA18140@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110826220311.GA18140@fieldses.org>
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 26, 2011 at 06:03:11PM -0400, J. Bruce Fields wrote:
[...]
> diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
> index f566518..c9296ab 100644
> --- a/arch/sparc/kernel/systbls_64.S
> +++ b/arch/sparc/kernel/systbls_64.S
> @@ -145,7 +145,7 @@ sys_call_table:
>  	.word sys_fstatfs64, sys_llseek, sys_mlock, sys_munlock, sys_mlockall
>  /*240*/	.word sys_munlockall, sys_sched_setparam, sys_sched_getparam, sys_sched_setscheduler, sys_sched_getscheduler
>  	.word sys_sched_yield, sys_sched_get_priority_max, sys_sched_get_priority_min, sys_sched_rr_get_interval, sys_nanosleep
> -/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nfsservctl
> +/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nis_syscall
[...]
          	                                                                  ^
This seems to be a typo for 'sys_ni_syscall'.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
