Return-Path: linux-nfs-owner@vger.kernel.org
Received: from a.ns.miles-group.at ([95.130.255.143]:47834 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbaEWMnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 08:43:00 -0400
Message-ID: <537F40C0.7030403@nod.at>
Date: Fri, 23 May 2014 14:36:16 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com, NeilBrown <neilb@suse.de>,
        LKML <linux-kernel@vger.kernel.org>, David Gstir <david@sigma-star.at>
Subject: Re: NFS issue while copying huge file
References: <CAFLxGvw_7=AuBqxNhAHpQAXq2aTqc8Afa6Z62=YCsFXcJx0Hug@mail.gmail.com> <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com> <20140523115655.GA14074@fieldses.org>
In-Reply-To: <20140523115655.GA14074@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 23.05.2014 13:56, schrieb J. Bruce Fields:
> It's not a known issue, and finding out where the problem was introduced
> could indeed by helpful.
> 
> I'm not sure how to interpret the statistics from the oom killer.  I'll
> dig around.
> 
> Knowing where the nfsd threads are spinning might also be interesting.
> "perf top" might give a quick idea?  Or maybe just "for p in $(pidof
> nfsd); do echo $p; cat /proc/$p/stack; done"
> 
> --b.
> 

Just booted 3.12.x on my client and sent a huge file to the NFS server (2.6.32-431.17.1.el6.x86_64)
After a few minutes the load reached 8 on the NFS server and I saw more and more nfsd's in top.
After some more time the nfsd's decreased but came again later.
I see this pattern until the NFS clients aborts with -EIO.

I can try to upgrade the kernel on my NFS server.
But as this is out main backup server in production I'd like to avoid it first.

Here the output of perf top and /proc/<pid>/stack on the server while many nfd's consumed 100%
CPU for a while.

perf top:
 19.81%  [kernel]             [k] _spin_lock
 12.55%  [kernel]             [k] mem_cgroup_lru_del_list
 10.73%  [kernel]             [k] shrink_page_list.clone.3
  7.90%  [kernel]             [k] isolate_lru_pages.clone.0
  7.28%  [kernel]             [k] __isolate_lru_page
  6.99%  [kernel]             [k] shrink_inactive_list
  3.82%  [kernel]             [k] page_waitqueue
  3.29%  [kernel]             [k] unlock_page
  2.84%  [kernel]             [k] mem_cgroup_lru_add_list
  2.51%  [kernel]             [k] __list_add
  2.36%  [kernel]             [k] page_evictable
  2.33%  [kernel]             [k] __wake_up_bit
  2.31%  [kernel]             [k] mem_cgroup_lru_del
  2.00%  [kernel]             [k] release_pages
  1.85%  [kernel]             [k] __mod_zone_page_state
  1.51%  [kernel]             [k] list_del
  1.40%  [kernel]             [k] lookup_page_cgroup
  1.25%  [kernel]             [k] _spin_lock_irq
  0.76%  [kernel]             [k] page_referenced
  0.46%  [xor]                [k] xor_sse_4
  0.36%  [kernel]             [k] _cond_resched

[root@gimli ~]# for p in $(pidof nfsd); do echo $p; cat /proc/$p/stack; done
1438
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1437
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1436
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1435
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1434
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1433
[<ffffffffffffffff>] 0xffffffffffffffff
1432
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff
1431
[<ffffffffa02a5568>] xfs_file_buffered_aio_write+0x58/0x1b0 [xfs]
[<ffffffffa02a57bf>] xfs_file_aio_write+0xff/0x190 [xfs]
[<ffffffff811887fb>] do_sync_readv_writev+0xfb/0x140
[<ffffffff81189786>] do_readv_writev+0xd6/0x1f0
[<ffffffff811898e6>] vfs_writev+0x46/0x60
[<ffffffffa04f8085>] nfsd_vfs_write+0x105/0x430 [nfsd]
[<ffffffffa04fa0d9>] nfsd_write+0x99/0x100 [nfsd]
[<ffffffffa0505b20>] nfsd4_write+0x100/0x130 [nfsd]
[<ffffffffa0506458>] nfsd4_proc_compound+0x3d8/0x490 [nfsd]
[<ffffffffa04f3425>] nfsd_dispatch+0xe5/0x230 [nfsd]
[<ffffffffa047a844>] svc_process_common+0x344/0x640 [sunrpc]
[<ffffffffa047ae80>] svc_process+0x110/0x160 [sunrpc]
[<ffffffffa04f3b52>] nfsd+0xc2/0x160 [nfsd]
[<ffffffff8109ab56>] kthread+0x96/0xa0
[<ffffffff8100c20a>] child_rip+0xa/0x20
[<ffffffffffffffff>] 0xffffffffffffffff

To me this looks like a lock contention.
This time also the hung task detector triggered on my client:

INFO: task cat:2289 blocked for more than 120 seconds.
      Tainted: GF            3.12.17 #3
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
cat             D ffffffff81613440     0  2289   2266 0x00000080
 ffff880851c09978 0000000000000082 ffff880851c09fd8 0000000000012d40
 ffff880851c08010 0000000000012d40 0000000000012d40 0000000000012d40
 ffff880851c09fd8 0000000000012d40 ffff880851d5f500 ffff88087c610080
Call Trace:
 [<ffffffffa05c9d20>] ? nfs_wait_on_request+0x40/0x40 [nfs]
 [<ffffffff81561cb9>] schedule+0x29/0x70
 [<ffffffff81561d8c>] io_schedule+0x8c/0xd0
 [<ffffffffa05c9d2e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8155fa12>] __wait_on_bit+0x62/0x90
 [<ffffffffa05c9d20>] ? nfs_wait_on_request+0x40/0x40 [nfs]
 [<ffffffff8155fab8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff810709d0>] ? wake_atomic_t_function+0x40/0x40
 [<ffffffffa05c9d16>] nfs_wait_on_request+0x36/0x40 [nfs]
 [<ffffffffa05ceff3>] nfs_try_to_update_request+0x93/0x140 [nfs]
 [<ffffffffa05cf0f3>] nfs_setup_write_request+0x53/0x1a0 [nfs]
 [<ffffffffa05c2c90>] ? nfs_evict_inode+0x40/0x40 [nfs]
 [<ffffffffa05cf26f>] nfs_writepage_setup+0x2f/0x1f0 [nfs]
 [<ffffffff811210eb>] ? find_lock_page+0x3b/0x80
 [<ffffffffa05cf499>] nfs_updatepage+0x69/0x250 [nfs]
 [<ffffffffa05c10a1>] nfs_write_end+0x161/0x320 [nfs]
 [<ffffffff8111faea>] generic_perform_write+0x12a/0x200
 [<ffffffff8111fc23>] generic_file_buffered_write+0x63/0xa0
 [<ffffffff8112252f>] __generic_file_aio_write+0x1bf/0x3b0
 [<ffffffff81181d93>] ? __sb_end_write+0x33/0x70
 [<ffffffff81122784>] generic_file_aio_write+0x64/0xb0
 [<ffffffffa05c05a1>] nfs_file_write+0xc1/0x1d0 [nfs]
 [<ffffffff8117f2df>] do_sync_write+0x5f/0xa0
 [<ffffffff8117f6c8>] vfs_write+0xc8/0x170
 [<ffffffff8119c0a1>] ? fget_light+0x21/0xc0
 [<ffffffff8117fcdf>] SyS_write+0x5f/0xb0
 [<ffffffff8156be92>] system_call_fastpath+0x16/0x1b
nfs: server 10.42.0.1 not responding, timed out

Thanks,
//richard
