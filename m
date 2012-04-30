Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755738Ab2D3SWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:22:34 -0400
From: Jeff Moyer <jmoyer@redhat.com>
To: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
Cc: <linux-nfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
References: <9c0b78d1.00001bd8.00000533@aldep-VC.vmware.com>
	<1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
Date: Mon, 30 Apr 2012 14:22:32 -0400
In-Reply-To: <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
	(Alexandre Depoutovitch's message of "Sun, 29 Apr 2012 14:03:41 -0700
	(PDT)")
Message-ID: <x49pqaphyfr.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Alexandre Depoutovitch" <adepoutovitch@vmware.com> writes:

> NFS daemons always perform buffered IO on files. As a result, write
> requests that are not aligned on a file system block boundary take about
> 15 times more time to complete compared to the same writes that are file
> system block aligned. This patch fixes the problem by analyzing alignment
> of the IO request that comes to NFS daemon and using Direct I/O mechanism
> when all of the following are true:
> 1. Request is not aligned on a file system block boundary
> 2. Request is aligned on an underlying block device's sector boundary.
> 3. Request size is a multiple of the sector size.

Why not add:

4. Request is a write

?  There is no read-modify-write cycle for a read.

> In all other cases, buffered IO is performed as has been done before.
>
> A new flag is exposed to users through /proc/fs/nfsd/direct_io node. The
> default value of 1 results in the above behavior. Writing 0 to the node
> turns off the direct I/O completely, and forces NFS daemon to always use
> buffered IO (as it has done before). Writing 2 to the node tells NFS
> daemon to use direct I/O whenever possible, even if  requests are aligned
> at file system block boundary.
>
> In order to test the patch, the following have been done: I've deployed 2
> Linux machines with 3.0 kernel and my modifications. One acted as an NFS
> server, the other acted as an NFS client. NFS volume was mounted in sync 
> mode.
> Number of NFS daemons was increased to 64 in order to have higher chances
> of catching concurrency issues. Volume was formatted using ext4 file
> system. Volume was located on a hardware RAID10 array with 8 10K 450GB SAS
> drives. Raid adapter was HP P410i.
>
> 1. During first set of experiments, the client machine created a 200 GB
> file by writing to it. Then it performed the following access patterns:
> Read, random, (4K)
> Write, random, (4K)
> Read, sequential (4K)
> Write, sequential (4K)
> Read, sequential (4K, first access at 512 offset)
> Write, sequential (4K, first access at 512 offset)
> Read, sequential (32K)
> Write, sequential (32K)
> Read, sequential (32K, first access at 512 offset)
> Write, sequential (32K, first access at 512 offset)
> Read, sequential (256K)
> Write, sequential (256K)
> All accesses where done with keeping 64 outstanding IO requests on a
> client. I compared performance of the above patterns on vanilla Linux and
> Linux with my changes. All numbers (IOPS, latency) where the same for all
> cases except for random writes, where IOPS increase was 14 times.

So you only tested the case where the file already exists on the file
system, is that right?  It would be a good idea to also test workloads
that create files.  In much the same vein, it would be a good idea to
run specsfs or other industry standard benchmark.

> In addition, I have done several correctness tests.
>
> 2. Allocated three 200GB files using (a) explicit writes to a file, (b)
> fallocate() system call, (c) seeking to the end of the file and writing
> one sector there.
> Then, did random and sequential writes to files. After that, I verified
> that files were indeed modified and contained the latest data. Test for
> each file ran for 2 hours.
>
> 3. Allocated 200GB file and started sequential reads to trigger read-ahead
> mechanism. Every 100 read operations, one file system unaligned write
> immediately after the current read position was requested in order to
> trigger a direct write. After that, read continued. All writes contained a
> predefined value, so that read can check for it. I have done this, in
> order to be sure that direct write correctly invalidates already in-memory
> cache.
>
>
> Current implementation performs synchronous direct I/O and may trigger
> higher latencies when NFS volume is mounted in asynchronous mode. In

It may also cause higher latencies for synchronously mounted file
systems.  It's never really a good idea to mix buffered and direct I/O.
In addition to exposing odd race conditions (which we think don't exist
anymore), each time you decide to perform direct I/O, you're going to
invalidate the page cache for the range of the file under I/O.

> order to avoid it, as per Trond Myklebust's suggestion, iov_iter
> interface with asynchronous reads and writes can be used. This is why
> currently, Direct I/O can be enabled or disabled at boot or run-time
> without NFS server restart through the /proc/fs/nfsd/direct_io node.

Not sure I understand that last part, but I really think you want to
layer this work on top of Dave Kleikamp's patch set:
    Subject: loop: Issue O_DIRECT aio using bio_vec

Also, instead of just telling us this is better, it would be good to
provide the benchmarks you ran and the raw results.

I've commented on random sections of the code below (not at all a full
review, just stuff that jumped out at me).

> diff -uNr linux-orig/fs/direct-io.c 
> linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c
> --- linux-orig/fs/direct-io.c   2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c   2012-04-25 
> 16:34:30.000000000 -0400
> @@ -152,11 +152,30 @@

Please use the '-p' switch to diff.

>     int nr_pages;
>
>     nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
> -   ret = get_user_pages_fast(
> -       dio->curr_user_address,     /* Where from? */
> -       nr_pages,           /* How many pages? */
> -       dio->rw == READ,        /* Write to memory? */
> -       &dio->pages[0]);        /* Put results here */
> +
> +   if (current->mm) {
> +       ret = get_user_pages_fast(
> +           dio->curr_user_address,     /* Where from? */
> +           nr_pages,           /* How many pages? */
> +           dio->rw == READ,        /* Write to memory? */
> +           &dio->pages[0]);        /* Put results here */
> +   } else {
> +       /* For kernel threads mm is NULL, so all we need is to increment
> +       page's reference count and add page to dio->pages array */
> +       int i;
> +       struct page* page;
> +       unsigned long start_pfn = virt_to_phys((void 
> *)dio->curr_user_address)

Your mailer is line-wrapping (and maybe munging white space in other
ways).  Also, is this a patch against 3.0?  Please update your sources
next time.

> +/*
> + Copies data between two iovec arrays. Individual array elements might have
> + different sizes, but total size of data described by the two arrays must
> + be the same
> +*/
> +static int nfsd_copy_iovec(const struct iovec* svec, const unsigned int 
> scount,
> +               struct iovec* dvec, const unsigned int dcount, size_t size) 
> {

Another data copy?  Ouch.

> +static int can_use_direct_io(const struct file *file,
> +       const struct super_block* sb,
> +       const loff_t offset, const unsigned long size) {
> +   unsigned int blkbits = 0;
> +   struct inode *inode;
> +   unsigned int fsblkbits = 0;
> +   unsigned int alignment  = io_alignment(offset, size);
> +
> +   if (alignment == 0)
> +       return 0;
> +
> +   if (file == NULL && sb == NULL)
> +       return 0;
> +
> +   if (nfsd_directio_mode == DIO_NEVER)
> +       return 0;

This check should be first, so we don't have to do alignment checks when
this is disabled.

Cheers,
Jeff
