Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:63471 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751507AbaEZVuV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 May 2014 17:50:21 -0400
Date: Tue, 27 May 2014 07:50:05 +1000
From: Dave Chinner <david@fromorbit.com>
To: Richard Weinberger <richard@nod.at>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com, NeilBrown <neilb@suse.de>,
        LKML <linux-kernel@vger.kernel.org>, David Gstir <david@sigma-star.at>
Subject: Re: NFS issue while copying huge file
Message-ID: <20140526215005.GA8554@dastard>
References: <CAFLxGvw_7=AuBqxNhAHpQAXq2aTqc8Afa6Z62=YCsFXcJx0Hug@mail.gmail.com>
 <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com>
 <20140523115655.GA14074@fieldses.org>
 <537F40C0.7030403@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537F40C0.7030403@nod.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 02:36:16PM +0200, Richard Weinberger wrote:
> Am 23.05.2014 13:56, schrieb J. Bruce Fields:
> > It's not a known issue, and finding out where the problem was introduced
> > could indeed by helpful.
> > 
> > I'm not sure how to interpret the statistics from the oom killer.  I'll
> > dig around.
> > 
> > Knowing where the nfsd threads are spinning might also be interesting.
> > "perf top" might give a quick idea?  Or maybe just "for p in $(pidof
> > nfsd); do echo $p; cat /proc/$p/stack; done"
> > 
> > --b.
> > 
> 
> Just booted 3.12.x on my client and sent a huge file to the NFS server (2.6.32-431.17.1.el6.x86_64)
> After a few minutes the load reached 8 on the NFS server and I saw more and more nfsd's in top.
> After some more time the nfsd's decreased but came again later.
> I see this pattern until the NFS clients aborts with -EIO.
> 
> I can try to upgrade the kernel on my NFS server.
> But as this is out main backup server in production I'd like to avoid it first.
> 
> Here the output of perf top and /proc/<pid>/stack on the server while many nfd's consumed 100%
> CPU for a while.
> 
> perf top:
>  19.81%  [kernel]             [k] _spin_lock
>  12.55%  [kernel]             [k] mem_cgroup_lru_del_list
>  10.73%  [kernel]             [k] shrink_page_list.clone.3
>   7.90%  [kernel]             [k] isolate_lru_pages.clone.0
>   7.28%  [kernel]             [k] __isolate_lru_page
>   6.99%  [kernel]             [k] shrink_inactive_list
>   3.82%  [kernel]             [k] page_waitqueue
>   3.29%  [kernel]             [k] unlock_page
>   2.84%  [kernel]             [k] mem_cgroup_lru_add_list
>   2.51%  [kernel]             [k] __list_add
>   2.36%  [kernel]             [k] page_evictable
>   2.33%  [kernel]             [k] __wake_up_bit
>   2.31%  [kernel]             [k] mem_cgroup_lru_del
>   2.00%  [kernel]             [k] release_pages
>   1.85%  [kernel]             [k] __mod_zone_page_state
>   1.51%  [kernel]             [k] list_del
>   1.40%  [kernel]             [k] lookup_page_cgroup
>   1.25%  [kernel]             [k] _spin_lock_irq
>   0.76%  [kernel]             [k] page_referenced
>   0.46%  [xor]                [k] xor_sse_4
>   0.36%  [kernel]             [k] _cond_resched
> 
> [root@gimli ~]# for p in $(pidof nfsd); do echo $p; cat /proc/$p/stack; done
> 1438
> [<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
> [<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
> [<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
> [<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
> [<ffffffff811898e6>] vfs_writev+0x46/0x60
> [<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
> [<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
> [<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
> [<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
> [<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
> [<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
> [<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
> [<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
> [<ffffffff8109ab56>] kthread+0x96/0xa0
> [<ffffffff8100c20a>] child_rip+0xa/0x20
> [<ffffffffffffffff>] 0xffffffffffffffff

There ain't no spinlocks in xfs_file_buffered_aio_write(). What you
see from the perf output above is all page cache and mem_cgroup work
being done - reclaim of pages from the cgroup LRU list and addition
of new pages to the cgroup LRU list. IOWs mem_cgroups are your
problem, not XFS or NFS.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
