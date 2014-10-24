Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:46452 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaJXIOm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 04:14:42 -0400
Received: by mail-wi0-f170.google.com with SMTP id n3so580789wiv.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 01:14:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141022130814.GA26501@infradead.org>
References: <20141020173658.GA7552@infradead.org>
	<20141022114649.GA2567@infradead.org>
	<CAABAsM44E-Ly=qPFBA2iBvgkCvA3GE5NRGi=d1hD+Pvk1xzevA@mail.gmail.com>
	<20141022130814.GA26501@infradead.org>
Date: Fri, 24 Oct 2014 11:14:40 +0300
Message-ID: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
Subject: Re: xfstests generic/075 failure on recent Linus' tree
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>,
        Jeffrey Layton <jeff.layton@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2014 at 4:08 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Oct 22, 2014 at 03:00:27PM +0300, Trond Myklebust wrote:
>> Does the NFS client show a TCP connection to port 2049 on 127.0.0.1?
>
> From netstat -a
>
> tcp        0 262352 localhost:nfs           localhost:684       ESTABLISHED
> tcp        0      0 localhost:684           localhost:nfs       ESTABLISHED
>
>
> Note that about 1/4 to 1/3 of the hangs show a backtrace like:
>
> [  480.293522] INFO: task fsx:14631 blocked for more than 120 seconds.
> [  480.296181]       Not tainted 3.18.0-rc1+ #1519
> [  480.299073] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  480.304028] fsx             D ffffffff81dcbd90     0 14631  14430 0x00000004
> [  480.307132]  ffff88007a457b08 0000000000000046 ffff880072db0b50 0000000000013dc0
> [  480.310401]  ffff88007a457fd8 0000000000013dc0 ffff88007d524310 ffff880072db0b50
> [  480.312772]  0000000000000000 0000000000000002 0000000000000001 0000000000000001
> [  480.315200] Call Trace:
> [  480.315946]  [<ffffffff81dcbd90>] ? bit_wait_timeout+0x60/0x60
> [  480.317358]  [<ffffffff810f906a>] ? mark_held_locks+0x6a/0x90
> [  480.318818]  [<ffffffff8111ef25>] ? ktime_get+0x105/0x140
> [  480.320167]  [<ffffffff810830af>] ? kvm_clock_read+0x1f/0x30
> [  480.321537]  [<ffffffff810830c9>] ? kvm_clock_get_cycles+0x9/0x10
> [  480.322871]  [<ffffffff8111eec5>] ? ktime_get+0xa5/0x140
> [  480.324360]  [<ffffffff811405ee>] ? __delayacct_blkio_start+0x1e/0x30
> [  480.325829]  [<ffffffff81dcbd90>] ? bit_wait_timeout+0x60/0x60
> [  480.327252]  [<ffffffff81dcb7a4>] schedule+0x24/0x70
> [  480.328471]  [<ffffffff81dcb87a>] io_schedule+0x8a/0xd0
> [  480.329683]  [<ffffffff81dcbdb6>] bit_wait_io+0x26/0x40
> [  480.330902]  [<ffffffff81dcbe7e>] __wait_on_bit_lock+0x6e/0xb0
> [  480.332189]  [<ffffffff81178de2>] ? find_get_entries+0x22/0x160
> [  480.336273]  [<ffffffff8117653c>] ? find_get_entry+0x8c/0xc0
> [  480.337719]  [<ffffffff811764b0>] ? find_get_pages_contig+0x1a0/0x1a0
> [  480.339280]  [<ffffffff81176755>] __lock_page+0x95/0xa0
> [  480.340518]  [<ffffffff810ee160>] ? wake_atomic_t_function+0x30/0x30
> [  480.342066]  [<ffffffff81184e66>] truncate_inode_pages_range+0x3c6/0x710
> [  480.343853]  [<ffffffff81185230>] truncate_inode_pages+0x10/0x20
> [  480.345306]  [<ffffffff81185286>] truncate_pagecache+0x46/0x70
> [  480.346481]  [<ffffffff81345e5e>] nfs_setattr_update_inode+0x9e/0x120
> [  480.348372]  [<ffffffff813682f8>] nfs4_proc_setattr+0xb8/0x100
> [  480.349751]  [<ffffffff813477b6>] nfs_setattr+0xd6/0x1d0
> [  480.350741]  [<ffffffff811deb10>] notify_change+0x160/0x3c0
> [  480.351748]  [<ffffffff81200afb>] ? fsnotify+0x7b/0x310
> [  480.353260]  [<ffffffff811c0671>] do_truncate+0x61/0xa0
> [  480.354829]  [<ffffffff811c09f4>] do_sys_ftruncate.constprop.16+0x104/0x160
> [  480.356754]  [<ffffffff8178760e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  480.358561]  [<ffffffff811c0a79>] SyS_ftruncate+0x9/0x10
> [  480.360054]  [<ffffffff81dd0fe9>] system_call_fastpath+0x12/0x17
> [  480.361744] 2 locks held by fsx/14631:
> [  480.362844]  #0:  (sb_writers#9){.+.+.+}, at: [<ffffffff811c09bf>] do_sys_ftruncate.constprop.16+0xcf/0x160
> [  480.366248]  #1:  (&sb->s_type->i_mutex_key#11){+.+.+.}, at: [<ffffffff811c0663>] do_truncate+0x53/0xa0
>
OK. So If this is NFSv4.1, and the connection is between the client
and server is still established, then I suspect the problem is with
knfsd dropping a request. According to the rules in RFC3530 and
RFC5661, it isn't allowed to do that unless the connection is broken.

Jeff, could you please take a look?

Thanks
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
