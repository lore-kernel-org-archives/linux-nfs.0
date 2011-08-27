Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab1H0ACH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 20:02:07 -0400
Date: Fri, 26 Aug 2011 20:01:09 -0400 (EDT)
Message-Id: <20110826.200109.1784685596300352827.davem@davemloft.net>
To: ben@decadent.org.uk
Cc: bfields@fieldses.org, torvalds@linux-foundation.org, neilb@suse.de,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110826233258.GE24107@decadent.org.uk>
References: <20110808180658.GC29924@decadent.org.uk>
	<20110826220311.GA18140@fieldses.org>
	<20110826233258.GE24107@decadent.org.uk>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 27 Aug 2011 00:32:58 +0100

> On Fri, Aug 26, 2011 at 06:03:11PM -0400, J. Bruce Fields wrote:
> [...]
>> diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
>> index f566518..c9296ab 100644
>> --- a/arch/sparc/kernel/systbls_64.S
>> +++ b/arch/sparc/kernel/systbls_64.S
>> @@ -145,7 +145,7 @@ sys_call_table:
>>  	.word sys_fstatfs64, sys_llseek, sys_mlock, sys_munlock, sys_mlockall
>>  /*240*/	.word sys_munlockall, sys_sched_setparam, sys_sched_getparam, sys_sched_setscheduler, sys_sched_getscheduler
>>  	.word sys_sched_yield, sys_sched_get_priority_max, sys_sched_get_priority_min, sys_sched_rr_get_interval, sys_nanosleep
>> -/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nfsservctl
>> +/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nis_syscall
> [...]
>           	                                                                  ^
> This seems to be a typo for 'sys_ni_syscall'.

It's intentional, look at the sparc sources.
