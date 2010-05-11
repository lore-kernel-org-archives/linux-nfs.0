From: Jeff Layton <jlayton@redhat.com>
Subject: Re: should unstable pages be committed on close() ?
Date: Tue, 11 May 2010 05:40:22 -0400
Message-ID: <20100511054022.0cf6caf3@tlielax.poochiereds.net>
References: <20100427162133.227cc6dd@tlielax.poochiereds.net>
	<1272403086.3067.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, branto@redhat.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714Ab0EKJkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 05:40:51 -0400
In-Reply-To: <1272403086.3067.35.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Apr 2010 17:18:06 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2010-04-27 at 16:21 -0400, Jeff Layton wrote: 
> > I've got a bug report about a possible regression from one of our QA
> > people. They were testing some of the recent write_inode/COMMIT changes
> > with this script:
> > 
> > ----------------[snip]-----------------
> > #! /usr/bin/env bash
> > servers="server:/export"
> > nfsstat -c -3
> > 
> > for SRV in $servers
> > do
> >  mount $SRV /media -o nfsvers=3
> >  rm -f /media/tmp.file
> >  time dd if=/dev/zero bs=1024k count=2000 of=/media/tmp.file
> >  umount /media
> >  nfsstat -c -3
> > done
> > ----------------[snip]-----------------
> > 
> > The changes have definitely reduced the number of commit calls, but
> > frequently we see these errors pop and the filesystem isn't unmounted.
> > 
> > umount.nfs: /media: device is busy
> > umount.nfs: /media: device is busy
> > 
> > ...if I call /bin/sync just before the umount, then it works fine. I
> > added a cat /proc/meminfo just before the umount and see this:
> > 
> > MemTotal:         980376 kB
> > MemFree:           12364 kB
> > Buffers:            3804 kB
> > Cached:           803584 kB
> > SwapCached:            0 kB
> > Active:           172376 kB
> > Inactive:         650252 kB
> > Active(anon):       5592 kB
> > Inactive(anon):     9808 kB
> > Active(file):     166784 kB
> > Inactive(file):   640444 kB
> > Unevictable:           0 kB
> > Mlocked:               0 kB
> > SwapTotal:       2064376 kB
> > SwapFree:        2064376 kB
> > Dirty:                 0 kB
> > Writeback:             0 kB
> > AnonPages:         15240 kB
> > Mapped:             9008 kB
> > Shmem:               160 kB
> > Slab:             123572 kB
> > SReclaimable:      28096 kB
> > SUnreclaim:        95476 kB
> > KernelStack:        1016 kB
> > PageTables:         2428 kB
> > NFS_Unstable:      90384 kB
> > Bounce:                0 kB
> > WritebackTmp:          0 kB
> > CommitLimit:     2554564 kB
> > Committed_AS:      80836 kB
> > VmallocTotal:   34359738367 kB
> > VmallocUsed:       41980 kB
> > VmallocChunk:   34359685244 kB
> > HardwareCorrupted:     0 kB
> > AnonHugePages:         0 kB
> > HugePages_Total:       0
> > HugePages_Free:        0
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > Hugepagesize:       2048 kB
> > DirectMap4k:        8128 kB
> > DirectMap2M:     1040384 kB
> > 
> > ...note that Dirty and Writeback are 0, but NFS_Unstable is still at
> > 90M or so. So, I think the problem is likely that the unstable pages
> > are preventing the umount.
> > 
> > I've not done much investigation beyond this yet, but figured I'd toss
> > the bug report out here in case anyone has thoughts on the cause and
> > how it should be fixed. I can reproduce this fairly easily on my
> > virtualized test rig in case anyone has patches that they want me to
> > test.
> 
> I'm aware of at least one race in mainline that can result in the above
> behaviour. There is a proposed fix in the 'bugfixes' branch on
> linux-nfs.org. See
> 
>   http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=commit;h=71d0a6112a363e703e383ae5b12c492485c39701
> 
> Cheers
>   Trond

Thanks Trond,

Sorry for the late response. That patch does indeed fix the problem.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
