From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 21:51:25 +0800
Message-ID: <20091005135125.GB17074@localhost>
References: <20091004030153.GA20327@localhost> <20091005071026.GA19262@localhost> <86DD3A52-EE5C-4378-BEB6-6336E17CFCD5@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	Chris Mason <chris.mason@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21827 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbZJENwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 09:52:14 -0400
In-Reply-To: <86DD3A52-EE5C-4378-BEB6-6336E17CFCD5@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 05, 2009 at 07:01:10PM +0800, Myklebust, Trond wrote:
> On Oct 5, 2009, at 3:11, "Wu Fengguang" <fengguang.wu@intel.com> wrote:
> 
> > Hi all,
> >
> > This version makes two standalone functions for easier reuse.
> >
> > Before patch, nr_writeback is near 1G on my 2GB laptop:
> >
> >     nr_writeback         nr_dirty      nr_unstable
> >           203994                2           154469
> >           203994                2           154469
> >
> > After patch, nr_writeback is limited to nfs_congestion_kb=42MB.
> >
> >     nr_writeback         nr_dirty      nr_unstable
> >            11180            34195            11754
> >             9865            36821             8234
> >            10137            36695             9338
> >
> > One minor problem I noticed is, NFS writeback is not very smooth.
> > This per 0.1s sampled trace shows that it can sometimes stuck for
> > up to 0.5s:
> >
> >     nr_writeback         nr_dirty      nr_unstable
> >            11055            37408             9599
> >            10311            37315            10529
> >            10869            35920            11459
> >            10869            35920            11459
> >            10869            35920            11459
> >            10869            35920            11459
> >            10869            35920            11459
> >            10838            35891            10042
> >            10466            35891            10414
> >            10900            34744            11437
> >            10249            34744            12088
> >            10249            34744            12088
> >            10249            34744            12088
> >            10249            34744            12088
> >            10249            34744            12088
> >            10249            34744            12088
> >            10133            34743            10663
> >            10505            34743            11035
> >            10970            34991            11345
> >            10691            34991            11593
> >            10691            34991            11593
> >            10691            34991            11593
> >            10691            34991            11593
> >            10691            34991            11593
> >
> > Trond, I guess nr_writeback/nr_unstable are decreased in async RPC
> > "complete" events. It is understandable that nr_dirty can sometimes
> > stuck on local waits, but the "local determined" nr_dirty and "remote
> > determined" nr_writeback/nr_unstable tend to stuck at the same time?
> > Did I miss something (that could be obvious to you)?
> 
> It looks (at 7am in the morning after getting up at 4:30am) as though  

Wow early bird!

> the number of unstable pages is remaining constant, which would mean  
> that we're sending a lot of COMMIT requests (see nfsstat). Since  
> COMMIT is essentially an fsync call, it means that the server is going  
> to be slower.

Here are the numbers:

Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 18007     3% 67        0% 1752      0% 2499      0% 109       0%
read         write        create       mkdir        symlink      mknod
1742      0% 518695   95% 77        0% 0         0% 0         0% 2         0%
remove       rmdir        rename       link         readdir      readdirplus
104       0% 0         0% 30        0% 40        0% 15        0% 178       0%
fsstat       fsinfo       pathconf     commit
140       0% 2         0% 1         0% 2461      0%


Server nfs v3:
null         getattr      setattr      lookup       access       readlink
2         0% 18000     3% 67        0% 1752      0% 2495      0% 109       0%
read         write        create       mkdir        symlink      mknod
1742      0% 518695   95% 77        0% 0         0% 0         0% 2         0%
remove       rmdir        rename       link         readdir      readdirplus
104       0% 0         0% 30        0% 40        0% 15        0% 178       0%
fsstat       fsinfo       pathconf     commit
140       0% 3         0% 1         0% 2461      0%


I noticed that dd often sleep in nfs_updatepage/nfs_wait_on_request,
is it because it's doing 512byte writes and thus have to wait on
subsequent in-page writes? I guess this may hurt performance on big
network latency?

[  268.020588] dd            D ffff880002735460  2608  3688   3534 0x00000000
[  268.020588]  ffff8800777c3a38 0000000000000046 0000000000000000 ffff880002735460
[  268.020588]  000000000000e388 ffff8800777c3fd8 ffff8800775346e0 ffffffff8192c8e0
[  268.020588]  ffff880077534a68 0000000000000082 00000000ffffc9fb ffff8800061d4758
[  268.020588] Call Trace:
[  268.020588]  [<ffffffff8109365d>] ? trace_hardirqs_on+0xd/0x10
[  268.020588]  [<ffffffff8123dc7a>] nfs_wait_bit_killable+0x2a/0x40
[  268.020588]  [<ffffffff81695a82>] __wait_on_bit+0x62/0x90
[  268.020588]  [<ffffffff8123dc50>] ? nfs_wait_bit_killable+0x0/0x40
[  268.020588]  [<ffffffff8123dc50>] ? nfs_wait_bit_killable+0x0/0x40
[  268.020588]  [<ffffffff81695b29>] out_of_line_wait_on_bit+0x79/0x90
[  268.020588]  [<ffffffff8107e2f0>] ? wake_bit_function+0x0/0x50
[  268.020588]  [<ffffffff81243aef>] nfs_wait_on_request+0x2f/0x40
[  268.020588]  [<ffffffff812490a6>] nfs_updatepage+0x2e6/0x540
[  268.020588]  [<ffffffff81239dc2>] nfs_write_end+0x62/0x2c0
[  268.020588]  [<ffffffff810fd469>] generic_file_buffered_write+0x179/0x2a0
[  268.020588]  [<ffffffff810935f5>] ? trace_hardirqs_on_caller+0x155/0x1b0
[  268.020588]  [<ffffffff810fd99d>] __generic_file_aio_write+0x26d/0x440
[  268.020588]  [<ffffffff810fdbbe>] ? generic_file_aio_write+0x4e/0xd0
[  268.020588]  [<ffffffff810fdbd4>] generic_file_aio_write+0x64/0xd0
[  268.020588]  [<ffffffff8123ae66>] nfs_file_write+0x136/0x210
[  268.020588]  [<ffffffff8114d1e9>] do_sync_write+0xf9/0x140
[  268.020588]  [<ffffffff8107e2b0>] ? autoremove_wake_function+0x0/0x40
[  268.020588]  [<ffffffff8111905c>] ? might_fault+0x5c/0xb0
[  268.020588]  [<ffffffff8114de3f>] vfs_write+0xcf/0x1c0
[  268.020588]  [<ffffffff8114e035>] sys_write+0x55/0x90
[  268.020588]  [<ffffffff8100c0b2>] system_call_fastpath+0x16/0x1b

Thanks,
Fengguang

