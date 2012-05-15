Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:38581 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932419Ab2EOSuF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:50:05 -0400
Date: Tue, 15 May 2012 11:50:05 -0700 (PDT)
From: Alexandre Depoutovitch <adepoutovitch@vmware.com>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Message-ID: <1862886070.5701097.1337107805033.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
In-Reply-To: <x49pqaphyfr.fsf@segfault.boston.devel.redhat.com>
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Jeff Moyer" <jmoyer@redhat.com>
> To: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
> Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
> Sent: Monday, April 30, 2012 2:22:32 PM
> Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
> 
> "Alexandre Depoutovitch" <adepoutovitch@vmware.com> writes:
> 
> > NFS daemons always perform buffered IO on files. As a result, write
> > requests that are not aligned on a file system block boundary take
> > about
> > 15 times more time to complete compared to the same writes that are
> > file
> > system block aligned. This patch fixes the problem by analyzing
> > alignment
> > of the IO request that comes to NFS daemon and using Direct I/O
> > mechanism
> > when all of the following are true:
> > 1. Request is not aligned on a file system block boundary
> > 2. Request is aligned on an underlying block device's sector
> > boundary.
> > 3. Request size is a multiple of the sector size.
> 
> Why not add:
> 
> 4. Request is a write
> 
> ?  There is no read-modify-write cycle for a read.

Yes, this makes sense. Thanks.

 
> > In order to test the patch, the following have been done: I've
> > deployed 2
> > Linux machines with 3.0 kernel and my modifications. One acted as
> > an NFS
> > server, the other acted as an NFS client. NFS volume was mounted in
> > sync
> > mode.
> > Number of NFS daemons was increased to 64 in order to have higher
> > chances
> > of catching concurrency issues. Volume was formatted using ext4
> > file
> > system. Volume was located on a hardware RAID10 array with 8 10K
> > 450GB SAS
> > drives. Raid adapter was HP P410i.
> >
> > 1. During first set of experiments, the client machine created a
> > 200 GB
> > file by writing to it. Then it performed the following access
> > patterns:
> > Read, random, (4K)
> > Write, random, (4K)
> > Read, sequential (4K)
> > Write, sequential (4K)
> > Read, sequential (4K, first access at 512 offset)
> > Write, sequential (4K, first access at 512 offset)
> > Read, sequential (32K)
> > Write, sequential (32K)
> > Read, sequential (32K, first access at 512 offset)
> > Write, sequential (32K, first access at 512 offset)
> > Read, sequential (256K)
> > Write, sequential (256K)
> > All accesses where done with keeping 64 outstanding IO requests on
> > a
> > client. I compared performance of the above patterns on vanilla
> > Linux and
> > Linux with my changes. All numbers (IOPS, latency) where the same
> > for all
> > cases except for random writes, where IOPS increase was 14 times.
> 
> So you only tested the case where the file already exists on the file
> system, is that right?  It would be a good idea to also test
> workloads
> that create files.  In much the same vein, it would be a good idea to
> run specsfs or other industry standard benchmark.


I will do this.

 
> > In addition, I have done several correctness tests.
> >
> > 2. Allocated three 200GB files using (a) explicit writes to a file,
> > (b)
> > fallocate() system call, (c) seeking to the end of the file and
> > writing
> > one sector there.
> > Then, did random and sequential writes to files. After that, I
> > verified
> > that files were indeed modified and contained the latest data. Test
> > for
> > each file ran for 2 hours.
> >
> > 3. Allocated 200GB file and started sequential reads to trigger
> > read-ahead
> > mechanism. Every 100 read operations, one file system unaligned
> > write
> > immediately after the current read position was requested in order
> > to
> > trigger a direct write. After that, read continued. All writes
> > contained a
> > predefined value, so that read can check for it. I have done this,
> > in
> > order to be sure that direct write correctly invalidates already
> > in-memory
> > cache.
> >
> >
> > Current implementation performs synchronous direct I/O and may
> > trigger
> > higher latencies when NFS volume is mounted in asynchronous mode.
> > In
> 
> It may also cause higher latencies for synchronously mounted file
> systems.  It's never really a good idea to mix buffered and direct
> I/O.
> In addition to exposing odd race conditions (which we think don't
> exist
> anymore), each time you decide to perform direct I/O, you're going to
> invalidate the page cache for the range of the file under I/O.

If there is an unknown bug in Direct I/O code, sure there will be a problem. But I specifically tested for many hours trying to trigger unknown race conditions (Test 2 and 3). As for cache invalidation, this may cause some performance degradation only when workload writes and reads to data cached in memory which has a low possibility for large randomly accessed data sets. As for small data sets, I suggest the direct I/O only as an optimization mode that must be explicitly turned on by the user

> > order to avoid it, as per Trond Myklebust's suggestion, iov_iter
> > interface with asynchronous reads and writes can be used. This is
> > why
> > currently, Direct I/O can be enabled or disabled at boot or
> > run-time
> > without NFS server restart through the /proc/fs/nfsd/direct_io
> > node.
> 
> Not sure I understand that last part, but I really think you want to
> layer this work on top of Dave Kleikamp's patch set:
>     Subject: loop: Issue O_DIRECT aio using bio_vec

Unless I got it wrong, Dave Kleikamp's work allows asynchronous I/O from the kernel. In the proposed NFS direct I/O patch all I/O is done synchronously (as it is done now). What benefit will we get from Dave's patch?

> 
> Also, instead of just telling us this is better, it would be good to
> provide the benchmarks you ran and the raw results.

                                  Buffered NFS              Direct I/O for unaligned   Difference
                               IOPS    MB/s Latency(ms)    IOPS   MB/s  Latency (ms)
Read, random (4K OIO=64)       1670    6.5     38          1700   6.8     37           4.62%
Write, random (4K OIO=64)      150     0.6     500         2200   8.5     29           1300.00%
Read, sequential (4K OIO=64)   22,000  87     2.8          22000  86      2.9          -1.15%
Write, sequential (4K OIO=64)  10,000  40      6           11000  42      6            5.00%
Read, sequential (32K OIO=1)   1900    59     0.5          2000   62      0.5          5.08%
Write, sequential (32K OIO=1)  1100    35     0.9          1100   35      0.9          0.00%
Read, sequential (32K OIO=64)  5000    156    13           5100   160     12           2.56%
Write, sequential (32K OIO=64) 5700    180    11           5600   175     11           -2.78%
Read, sequential (256K OIO=64) 560     140    110          550    140     120          0.00%
Write, sequential (256K OIO=64)580     150    110          600    150     100          0.00%



> I've commented on random sections of the code below (not at all a
> full
> review, just stuff that jumped out at me).

Thanks!

> 
> > diff -uNr linux-orig/fs/direct-io.c
> > linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c
> > --- linux-orig/fs/direct-io.c   2011-10-24 14:06:32.000000000 -0400
> > +++ linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c   2012-04-25
> > 16:34:30.000000000 -0400
> > @@ -152,11 +152,30 @@
> 
> Please use the '-p' switch to diff.

Will do.

 
> >     int nr_pages;
> >
> >     nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
> > -   ret = get_user_pages_fast(
> > -       dio->curr_user_address,     /* Where from? */
> > -       nr_pages,           /* How many pages? */
> > -       dio->rw == READ,        /* Write to memory? */
> > -       &dio->pages[0]);        /* Put results here */
> > +
> > +   if (current->mm) {
> > +       ret = get_user_pages_fast(
> > +           dio->curr_user_address,     /* Where from? */
> > +           nr_pages,           /* How many pages? */
> > +           dio->rw == READ,        /* Write to memory? */
> > +           &dio->pages[0]);        /* Put results here */
> > +   } else {
> > +       /* For kernel threads mm is NULL, so all we need is to
> > increment
> > +       page's reference count and add page to dio->pages array */
> > +       int i;
> > +       struct page* page;
> > +       unsigned long start_pfn = virt_to_phys((void
> > *)dio->curr_user_address)
> 
> Your mailer is line-wrapping (and maybe munging white space in other
> ways).  Also, is this a patch against 3.0?  Please update your
> sources
> next time.

I will.

> > +/*
> > + Copies data between two iovec arrays. Individual array elements
> > might have
> > + different sizes, but total size of data described by the two
> > arrays must
> > + be the same
> > +*/
> > +static int nfsd_copy_iovec(const struct iovec* svec, const
> > unsigned int
> > scount,
> > +               struct iovec* dvec, const unsigned int dcount,
> > size_t size)
> > {
> 
> Another data copy?  Ouch.

I could not find any easy way to avoid it. The copy is done only in the case when direct I/O is involved.
> 
> > +static int can_use_direct_io(const struct file *file,
> > +       const struct super_block* sb,
> > +       const loff_t offset, const unsigned long size) {
> > +   unsigned int blkbits = 0;
> > +   struct inode *inode;
> > +   unsigned int fsblkbits = 0;
> > +   unsigned int alignment  = io_alignment(offset, size);
> > +
> > +   if (alignment == 0)
> > +       return 0;
> > +
> > +   if (file == NULL && sb == NULL)
> > +       return 0;
> > +
> > +   if (nfsd_directio_mode == DIO_NEVER)
> > +       return 0;
> 
> This check should be first, so we don't have to do alignment checks
> when
> this is disabled.
> 

I will change this.
