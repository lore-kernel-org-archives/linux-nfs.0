Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4B3FC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 16:19:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A57DC20867
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 16:19:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A57DC20867
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726881AbeLAD26 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 22:28:58 -0500
Received: from foss.arm.com ([217.140.101.70]:60196 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726595AbeLAD26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 22:28:58 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 42A10A78;
        Fri, 30 Nov 2018 08:19:08 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9B3BC3F5AF;
        Fri, 30 Nov 2018 08:19:07 -0800 (PST)
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
 <20181109111930.idve77thgcnsg5u3@localhost>
 <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
 <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
Date:   Fri, 30 Nov 2018 16:19:06 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi

On 29/11/2018 19:56, Trond Myklebust wrote:
> On Thu, 2018-11-29 at 19:28 +0000, Cristian Marussi wrote:
>> Hi Trond, Catalin
[snip]
> 
> Question to you both: when this happens, does /proc/*/stack show any of
> the processes hanging in the socket or sunrpc code? If so, can you
> please send me examples of those stack traces (i.e. the contents of
> /proc/<pid>/stack for the processes that are hanging)

(using a reverse shell since starting ssh causes a lot of pain and traffic)

Looking at NFS traffic holes(30-40 secs) to detect Client side various HANGS
----------------------------------------------------------------------------

root@sqwt-ubuntu:/opt/lkp-tests# nc -lk -e /bin/bash -s 192.168.0.1 -p 1235 &
root@sqwt-ubuntu:/opt/lkp-tests# lkp run ./dbench-100%.yaml

$ nc 192.168.0.1 1235

cat /proc/2833/cmdline
ruby/opt/lkp-tests/bin/run-local./dbench-100%.yaml

HANG CLOSE
----------
cat /proc/2833/stack
[<0>] __switch_to+0x6c/0x90
[<0>] rpc_wait_bit_killable+0x2c/0xb0
[<0>] __rpc_wait_for_completion_task+0x3c/0x48
[<0>] nfs4_do_close+0x1ec/0x2b0
[<0>] __nfs4_close+0x130/0x198
[<0>] nfs4_close_sync+0x34/0x40
[<0>] nfs4_close_context+0x40/0x50
[<0>] __put_nfs_open_context+0xac/0x118
[<0>] nfs_file_clear_open_context+0x38/0x58
[<0>] nfs_file_release+0x7c/0x90
[<0>] __fput+0x94/0x1c0
[<0>] ____fput+0x20/0x30
[<0>] task_work_run+0x98/0xb8
[<0>] do_notify_resume+0x2d0/0x318
[<0>] work_pending+0x8/0x10
[<0>] 0xffffffffffffffff

HANG READ
---------
cat /proc/2833/stack
[<0>] __switch_to+0x6c/0x90
[<0>] io_schedule+0x20/0x40
[<0>] wait_on_page_bit_killable+0x164/0x260
[<0>] generic_file_read_iter+0x1c4/0x820
[<0>] nfs_file_read+0xa4/0x108
[<0>] __vfs_read+0x120/0x170
[<0>] vfs_read+0x94/0x150
[<0>] ksys_read+0x6c/0xd8
[<0>] __arm64_sys_read+0x24/0x30
[<0>] el0_svc_handler+0x7c/0x118
[<0>] el0_svc+0x8/0xc
[<0>] 0xffffffffffffffff


HANG STAT
---------
cat /proc/2833/stack
[<0>] __switch_to+0x6c/0x90
[<0>] rpc_wait_bit_killable+0x2c/0xb0
[<0>] __rpc_execute+0x1cc/0x528
[<0>] rpc_execute+0xe4/0x1b0
[<0>] rpc_run_task+0x130/0x168
[<0>] nfs4_call_sync_sequence+0x80/0xc8
[<0>] _nfs4_proc_getattr+0xc8/0xf8
[<0>] nfs4_proc_getattr+0x88/0x1d8
[<0>] __nfs_revalidate_inode+0x1f8/0x468
[<0>] nfs_getattr+0x14c/0x420
[<0>] vfs_getattr_nosec+0x7c/0x98
[<0>] vfs_getattr+0x48/0x58
[<0>] vfs_statx+0xb4/0x118
[<0>] __se_sys_newfstatat+0x58/0x98
[<0>] __arm64_sys_newfstatat+0x24/0x30
[<0>] el0_svc_handler+0x7c/0x118
[<0>] el0_svc+0x8/0xc
[<0>] 0xffffffffffffffff

....


Looking at a straced lkp to detect HANGS
----------------------------------------

cat /proc/2878/cmdline
ruby/opt/lkp-tests/bin/run-local./dbench-100%.yaml

HANG READ
----------
cat /proc/2878/stack
[<0>] __switch_to+0x6c/0x90
[<0>] io_schedule+0x20/0x40
[<0>] wait_on_page_bit_killable+0x164/0x260
[<0>] generic_file_read_iter+0x1c4/0x820
[<0>] nfs_file_read+0xa4/0x108
[<0>] __vfs_read+0x120/0x170
[<0>] vfs_read+0x94/0x150
[<0>] ksys_read+0x6c/0xd8
[<0>] __arm64_sys_read+0x24/0x30
[<0>] el0_svc_handler+0x7c/0x118
[<0>] el0_svc+0x8/0xc
[<0>] 0xffffffffffffffff

...

cat /proc/2878/status
Name:	ruby
Umask:	0022
State:	D (disk sleep)
Tgid:	2878
Ngid:	0
Pid:	2878
PPid:	2876
TracerPid:	2876
Uid:	0	0	0	0
Gid:	0	0	0	0
FDSize:	64
Groups:	
NStgid:	2878
NSpid:	2878
NSpgid:	2876
NSsid:	2822
VmPeak:	   24192 kB
VmSize:	   24192 kB
VmLck:	       0 kB
VmPin:	       0 kB
VmHWM:	   13376 kB
VmRSS:	   13376 kB
RssAnon:	    8768 kB
RssFile:	    4608 kB
RssShmem:	       0 kB
VmData:	    9792 kB
VmStk:	    8192 kB
VmExe:	      64 kB
VmLib:	    5888 kB
VmPTE:	     320 kB
VmSwap:	       0 kB
HugetlbPages:	       0 kB
CoreDumping:	0
Threads:	2
SigQ:	0/7534
SigPnd:	0000000000000000
ShdPnd:	0000000000000000
SigBlk:	0000000000000000
SigIgn:	0000000000000000
SigCgt:	00000001c2007e4f
CapInh:	0000000000000000
CapPrm:	0000003fffffffff
CapEff:	0000003fffffffff
CapBnd:	0000003fffffffff
CapAmb:	0000000000000000
NoNewPrivs:	0
Seccomp:	0
Speculation_Store_Bypass:	unknown
Cpus_allowed:	3f
Cpus_allowed_list:	0-5
Mems_allowed:	1
Mems_allowed_list:	0
voluntary_ctxt_switches:	7547
nonvoluntary_ctxt_switches:	564


Thanks

Cristian
