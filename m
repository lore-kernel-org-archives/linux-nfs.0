Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44833 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758848Ab2EKSg5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 14:36:57 -0400
Message-ID: <4FAD5C44.50407@gmail.com>
Date: Fri, 11 May 2012 11:36:52 -0700
From: Dean <seattleplus@gmail.com>
MIME-Version: 1.0
To: Alexandre Depoutovitch <adepoutovitch@vmware.com>
CC: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
References: <9c0b78d1.00001bd8.00000533@aldep-VC.vmware.com> <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
In-Reply-To: <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 4/29/12 2:03 PM, Alexandre Depoutovitch wrote:
> A new flag is exposed to users through /proc/fs/nfsd/direct_io node. The
> default value of 1 results in the above behavior. Writing 0 to the node
> turns off the direct I/O completely, and forces NFS daemon to always use
> buffered IO (as it has done before). Writing 2 to the node tells NFS
> daemon to use direct I/O whenever possible, even if  requests are aligned
> at file system block boundary.

Not sure if this was previously discussed, but I assume the default 
would remain the same (value 0)?

Dean


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
>
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
> order to avoid it, as per Trond Myklebust's suggestion, iov_iter interface
> with asynchronous reads and writes can be used. This is why currently,
> Direct I/O can
> be enabled or disabled at boot or run-time without NFS server restart
> through the /proc/fs/nfsd/direct_io node.
>
>
>
> --------------------------------------------------------------------------
>
> diff -uNr linux-orig/fs/direct-io.c
> linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c
> --- linux-orig/fs/direct-io.c   2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/direct-io.c   2012-04-25
> 16:34:30.000000000 -0400
> @@ -152,11 +152,30 @@
>      int nr_pages;
>
>      nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
> -   ret = get_user_pages_fast(
> -       dio->curr_user_address,     /* Where from? */
> -       nr_pages,           /* How many pages? */
> -       dio->rw == READ,        /* Write to memory? */
> -&dio->pages[0]);        /* Put results here */
> +
> +   if (current->mm) {
> +       ret = get_user_pages_fast(
> +           dio->curr_user_address,     /* Where from? */
> +           nr_pages,           /* How many pages? */
> +           dio->rw == READ,        /* Write to memory? */
> +&dio->pages[0]);        /* Put results here */
> +   } else {
> +       /* For kernel threads mm is NULL, so all we need is to increment
> +       page's reference count and add page to dio->pages array */
> +       int i;
> +       struct page* page;
> +       unsigned long start_pfn = virt_to_phys((void
> *)dio->curr_user_address)
> +>>  PAGE_SHIFT;
> +       /* For kernel threads buffer must be in kernel memory */
> +       BUG_ON(dio->curr_user_address<  TASK_SIZE_MAX);
> +
> +       for (i = 0; i<  nr_pages; i++) {
> +           page = pfn_to_page(start_pfn + i);
> +           page_cache_get(page);
> +           dio->pages[i] = page;
> +       }
> +       /* No need to lock pages: this is kernel thread and the pages are in
> +         kernel as well */
> +       ret = nr_pages;
> +   }
>
>      if (ret<  0&&  dio->blocks_available&&  (dio->rw&  WRITE)) {
>          struct page *page = ZERO_PAGE(0);
> @@ -972,7 +991,11 @@
>                  break;
>          }
>
> -       /* Drop the ref which was taken in get_user_pages() */
> +       /*
> +        * Drop the ref which was taken in dio_refill_pages
> +        * directly (for direct I/O) or by calling get_user_pages
> +        * (for buffered IO)
> +        */
>          page_cache_release(page);
>          block_in_page = 0;
>      }
> diff -uNr linux-orig/fs/nfsd/lockd.c
> linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/lockd.c
> --- linux-orig/fs/nfsd/lockd.c  2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/lockd.c  2012-03-28
> 15:40:29.000000000 -0400
> @@ -36,7 +36,7 @@
>      fh.fh_export = NULL;
>
>      exp_readlock();
> -   nfserr = nfsd_open(rqstp,&fh, S_IFREG, NFSD_MAY_LOCK, filp);
> +   nfserr = nfsd_open(rqstp,&fh, S_IFREG, NFSD_MAY_LOCK, filp, 0, 0);
>      fh_put(&fh);
>      exp_readunlock();
>      /* We return nlm error codes as nlm doesn't know
> diff -uNr linux-orig/fs/nfsd/nfs4state.c
> linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfs4state.c
> --- linux-orig/fs/nfsd/nfs4state.c  2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfs4state.c  2012-03-28
> 15:40:29.000000000 -0400
> @@ -2557,7 +2557,7 @@
>
>      if (!fp->fi_fds[oflag]) {
>          status = nfsd_open(rqstp, cur_fh, S_IFREG, access,
> -&fp->fi_fds[oflag]);
> +&fp->fi_fds[oflag], 0, 0);
>          if (status)
>              return status;
>      }
> @@ -3951,7 +3951,7 @@
>      struct file *file;
>      int err;
>
> -   err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,&file);
> +   err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,&file, 0, 0);
>      if (err)
>          return err;
>      err = vfs_test_lock(file, lock);
> diff -uNr linux-orig/fs/nfsd/nfsctl.c
> linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfsctl.c
> --- linux-orig/fs/nfsd/nfsctl.c 2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfsctl.c 2012-03-28
> 15:40:29.000000000 -0400
> @@ -46,6 +46,7 @@
>      NFSD_TempPorts,
>      NFSD_MaxBlkSize,
>      NFSD_SupportedEnctypes,
> +   NFSD_DirectIO,
>      /*
>       * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
>       * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
> @@ -78,6 +79,7 @@
>   static ssize_t write_ports(struct file *file, char *buf, size_t size);
>   static ssize_t write_temp_ports(struct file *file, char *buf, size_t size);
>   static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
> +static ssize_t write_directio(struct file *file, char *buf, size_t size);
>   #ifdef CONFIG_NFSD_V4
>   static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
>   static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
> @@ -103,6 +105,7 @@
>      [NFSD_Ports] = write_ports,
>      [NFSD_TempPorts] = write_temp_ports,
>      [NFSD_MaxBlkSize] = write_maxblksize,
> +   [NFSD_DirectIO] = write_directio,
>   #ifdef CONFIG_NFSD_V4
>      [NFSD_Leasetime] = write_leasetime,
>      [NFSD_Gracetime] = write_gracetime,
> @@ -1348,6 +1351,58 @@
>                              nfsd_max_blksize);
>   }
>
> +int nfsd_directio_mode = DIO_NEVER;
> +
> +/**
> + * nfsd_directio_mode - sets conditions when direct IO is activated
> + *
> + * Input:
> + *         buf:        ignored
> + *         size:       zero
> + *
> + * OR
> + *
> + * Input:
> + *             buf:        C string containing an unsigned
> + *                     integer value representing the new
> + *                     NFS direct IO mode
> + *         size:       non-zero length of C string in @buf
> + * Output:
> + * On success: passed-in buffer filled with '\n'-terminated C string
> + *         containing numeric value of the current direct IO mode
> + *         return code is the size in bytes of the string
> + *
> + * Possible modes are:
> + *     DIO_NEVER (0) - never use direct I/O
> + *     DIO_FS_UNALIGNED (1) - use direct I/O only for requests that FS
> unaligned
> + *         and block device aligned
> + *     DIO_SECTOR_ALIGNED (3) - use direct I/O for all block device aligned
> IO
> + * On error:   return code is zero or a negative errno value
> + */
> +static ssize_t write_directio(struct file *file, char *buf, size_t size)
> +{
> +   char *mesg = buf;
> +   if (size>  0) {
> +       int mode;
> +       int rv = get_int(&mesg,&mode);
> +       if (rv)
> +           return rv;
> +       if (mode<  DIO_NEVER || mode>  DIO_BDEV_ALIGNED)
> +           return -EINVAL;
> +       /*
> +       There is no need for synchronization here. No harm will happen
> +       even if mode was changed between opening a file and choosing whether
> +       to choose direct or buffered path. When we choosing a path we make
> sure
> +       that the file has been opened in the compatible mode
> +       */
> +       nfsd_directio_mode = mode;
> +       printk(KERN_WARNING"NFSD direct I/O mode changed to %d.",
> +           nfsd_directio_mode);
> +   }
> +
> +   return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
> nfsd_directio_mode);
> +}
> +
>   #ifdef CONFIG_NFSD_V4
>   static ssize_t __nfsd4_write_time(struct file *file, char *buf, size_t
> size, time_t *time)
>   {
> @@ -1525,6 +1580,7 @@
>          [NFSD_Ports] = {"portlist",&transaction_ops, S_IWUSR|S_IRUGO},
>          [NFSD_TempPorts] = {"tempportlist",&transaction_ops,
> S_IWUSR|S_IRUGO},
>          [NFSD_MaxBlkSize] = {"max_block_size",&transaction_ops,
> S_IWUSR|S_IRUGO},
> +       [NFSD_DirectIO] = {"direct_io",&transaction_ops, S_IWUSR|S_IRUGO},
>   #if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
>          [NFSD_SupportedEnctypes] = {"supported_krb5_enctypes",
> &supported_enctypes_ops, S_IRUGO},
>   #endif /* CONFIG_SUNRPC_GSS or CONFIG_SUNRPC_GSS_MODULE */
> diff -uNr linux-orig/fs/nfsd/nfsd.h
> linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfsd.h
> --- linux-orig/fs/nfsd/nfsd.h   2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/nfsd.h   2012-04-17
> 11:45:55.000000000 -0400
> @@ -68,6 +68,14 @@
>
>   extern int nfsd_max_blksize;
>
> +enum {
> +   DIO_NEVER = 0,// Never use Direct I/O. The first value
> +   DIO_FS_UNALIGNED = 1,   // Use Direct I/O when request is FS unaligned
> +   DIO_BDEV_ALIGNED =2, // Always use Direct I/O when possible. The last
> value
> +};
> +
> +extern int nfsd_directio_mode;
> +
>   static inline int nfsd_v4client(struct svc_rqst *rq)
>   {
>      return rq->rq_prog == NFS_PROGRAM&&  rq->rq_vers == 4;
> diff -uNr linux-orig/fs/nfsd/vfs.c linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/vfs.c
> --- linux-orig/fs/nfsd/vfs.c    2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/vfs.c    2012-04-25
> 14:21:38.000000000 -0400
> @@ -28,6 +28,7 @@
>   #include<asm/uaccess.h>
>   #include<linux/exportfs.h>
>   #include<linux/writeback.h>
> +#include<linux/blkdev.h>
>
>   #ifdef CONFIG_NFSD_V3
>   #include "xdr3.h"
> @@ -718,6 +719,255 @@
>      return break_lease(inode, mode | O_NONBLOCK);
>   }
>
> +/*
> + Copies data between two iovec arrays. Individual array elements might have
> + different sizes, but total size of data described by the two arrays must
> + be the same
> +*/
> +static int nfsd_copy_iovec(const struct iovec* svec, const unsigned int
> scount,
> +               struct iovec* dvec, const unsigned int dcount, size_t size)
> {
> +   size_t cur_size, soff, doff, tocopy, srem , drem ;
> +   unsigned int di, si;
> +
> +   cur_size = iov_length(svec, scount);
> +   if (cur_size != iov_length(dvec, dcount))
> +       return -EINVAL;
> +
> +   srem = drem = 0;
> +   di = si = 0;
> +   soff = doff = 0;
> +   while (cur_size>  0)    {
> +       if (si>= scount || di>= dcount)
> +           return -EFAULT;
> +
> +       srem = svec[si].iov_len - soff;
> +       drem = dvec[di].iov_len - doff;
> +       tocopy = (srem>  drem) ? drem : srem;
> +       memcpy((char*)(dvec[di].iov_base) + doff,
> (char*)(svec[si].iov_base) + soff, tocopy);
> +       cur_size -= tocopy;
> +       srem -= tocopy;
> +       drem -= tocopy;
> +       doff += tocopy;
> +       soff += tocopy;
> +       if (srem == 0) {
> +           si++;
> +           soff = 0;
> +       }
> +       if (drem == 0) {
> +           di++;
> +           doff = 0;
> +       }
> +   }
> +   if (si != scount || di != dcount || srem !=0 || drem != 0)
> +   {
> +       printk(KERN_WARNING"In copy_iovec: si=%lu, scount=%lu, di=%lu,
> dcount=%lu, srem=%lu, drem=%lu",
> +           (unsigned long)si, (unsigned long)scount, (unsigned long)di,
> +           (unsigned long)dcount, (unsigned long)srem, (unsigned
> long)drem);
> +       return -EFAULT;
> +   }
> +
> +   return 0;
> +}
> +
> +/*
> + Allocates iovec array where each element has memory page-aligned base
> address
> + and size of a page. Needed for DIRECT I/O to be possbile from this array
> + */
> +static int nfsd_allocate_paged_iovec(size_t size, unsigned int* pcount,
> +       struct iovec** pvec) {
> +   unsigned int i;
> +   unsigned int page_num = size / PAGE_SIZE;
> +   struct iovec * vec = NULL;
> +
> +   *pvec = NULL;
> +   *pcount = 0;
> +   if (page_num * PAGE_SIZE != size)
> +       page_num++;
> +
> +   vec = kmalloc(sizeof(struct iovec) * page_num, GFP_KERNEL);
> +   if (!vec)
> +       return -ENOMEM;
> +   memset(vec, 0, sizeof(struct iovec) * page_num);
> +   *pvec = vec;
> +   *pcount = page_num;
> +
> +   for (i = 0; i<  page_num; i++) {
> +       vec[i].iov_base = (void*)__get_free_page(GFP_KERNEL);
> +       if (!vec[i].iov_base)
> +           return -ENOMEM;
> +       vec[i].iov_len = PAGE_SIZE;
> +   }
> +
> +   if (size % PAGE_SIZE)
> +       vec[page_num - 1].iov_len = size % PAGE_SIZE;
> +
> +   return 0;
> +}
> +
> +/*
> + Deallocates iovec array, allocated by nfsd_allocate_paged_iovec
> +*/
> +static void nfsd_free_paged_iovec(unsigned int count, struct iovec* vec) {
> +   unsigned int i;
> +   if (vec) {
> +       for (i = 0; i<  count; i++)
> +           if (vec[i].iov_base)
> +               free_page((unsigned long)(vec[i].iov_base));
> +       kfree(vec);
> +   }
> +}
> +
> +/*
> + Performs direct I/O for a given NFS write request
> +*/
> +static ssize_t nfsd_vfs_write_direct(struct file *file, const struct iovec
> *vec,
> +          unsigned long vlen, loff_t *pos) {
> +   ssize_t result = -EINVAL;
> +   unsigned int page_num;
> +   struct iovec *aligned_vec = NULL;
> +
> +   // Check size to be multiple of sectors
> +   size_t size = iov_length(vec, vlen);
> +
> +   if (size == 0)
> +       return vfs_writev(file, (struct iovec __user *)vec, vlen, pos);
> +
> +   // Allocate necesary number of pages
> +   result = nfsd_allocate_paged_iovec(size,&page_num,&aligned_vec);
> +   if (result) {
> +       printk(KERN_WARNING"Cannot allocate aligned_vec.");
> +       goto out;
> +   }
> +
> +   // Copy data
> +   result = nfsd_copy_iovec(vec, vlen, aligned_vec, page_num, size);
> +   if(result) {
> +       printk(KERN_WARNING"Wrong amount of data copied to aligned
> buffer.");
> +       goto out;
> +   }
> +
> +   // Call further
> +   result = vfs_writev(file, (struct iovec __user *)aligned_vec, page_num,
> pos);
> +
> +out:
> +   nfsd_free_paged_iovec(page_num, aligned_vec);
> +   return result;
> +}
> +
> +
> +/*
> + Performs direct I/O for a given NFS read request
> +*/
> +static ssize_t nfsd_vfs_read_direct(struct file *file, struct iovec *vec,
> +          unsigned long vlen, loff_t *pos) {
> +   unsigned int page_num;
> +   struct iovec *aligned_vec = NULL;
> +   ssize_t result = -EINVAL;
> +   size_t size;
> +
> +   // Check size to be multiple of sectors
> +   size = iov_length(vec, vlen);
> +
> +   if (size == 0)
> +       return vfs_readv(file, (struct iovec __user *)vec, vlen, pos);
> +
> +   // Allocate necesary number of pages
> +   result = nfsd_allocate_paged_iovec(size,&page_num,&aligned_vec);
> +   if (result) {
> +       printk(KERN_WARNING"Cannot allocate aligned_vec.");
> +       goto out;
> +   }
> +
> +   // Call further
> +   result = vfs_readv(file, (struct iovec __user *)aligned_vec, page_num,
> pos);
> +   if (result<  0) {
> +       printk(KERN_WARNING"Error during read operation.");
> +       goto out;
> +   }
> +
> +   // Copy data
> +   if(nfsd_copy_iovec(aligned_vec, page_num, vec, vlen, size)) {
> +       printk(KERN_WARNING"Wrong amount of data copied from aligned
> buffer.");
> +       goto out;
> +   }
> +
> +out:
> +   nfsd_free_paged_iovec(page_num, aligned_vec);
> +
> +   return result;
> +}
> +
> +// Returns number of terminal zero bits for a given number (number
> alignment)
> +static unsigned int get_alignment(loff_t n) {
> +   unsigned int i=0;
> +   if (n == 0)
> +       return (unsigned int)-1; // 0 is alligned to any number
> +   while ((n&  1) == 0&&  n>  0) {
> +       n = n>>  1;
> +       i++;
> +   }
> +   return i;
> +}
> +
> +// Returns the alignment of I/O request
> +static unsigned int io_alignment(const loff_t offset,
> +       const unsigned long size) {
> +   unsigned int i1, i2;
> +
> +   i1 = get_alignment(offset);
> +   i2 = get_alignment(size);
> +
> +   return i1>  i2 ? i2 : i1;
> +}
> +
> +
> +/*
> + Based on the I/O request and file system parameters determines if
> + direct I/O can be used to perform the given request
> + Either file or sb are needed to retrieve file system and device
> + paramters
> +*/
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
> +   if (file == NULL&&  sb == NULL)
> +       return 0;
> +
> +   if (nfsd_directio_mode == DIO_NEVER)
> +       return 0;
> +
> +   if (file != NULL&&  sb == NULL) {
> +       inode = file->f_path.dentry->d_inode;
> +       sb = inode->i_sb;
> +       fsblkbits = inode->i_blkbits;
> +   }
> +
> +   if (sb !=NULL) {
> +       blkbits = sb->s_blocksize_bits;
> +       fsblkbits = sb->s_blocksize_bits;
> +       if (sb->s_bdev)
> +           blkbits = blksize_bits(bdev_logical_block_size(sb->s_bdev));
> +   } else
> +       blkbits = fsblkbits;
> +
> +   if (alignment>= fsblkbits&&  fsblkbits>  0&&  nfsd_directio_mode !=
> DIO_BDEV_ALIGNED)
> +       return 0;
> +
> +   if (alignment<  blkbits)
> +       return 0;
> +
> +   return 1;
> +}
> +
> +
>   /*
>    * Open an existing file or directory.
>    * The access argument indicates the type of open (read/write/lock)
> @@ -725,13 +975,15 @@
>    */
>   __be32
>   nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
> -           int access, struct file **filp)
> +           int access, struct file **filp,
> +           const loff_t offset, const unsigned long size)
>   {
>      struct dentry   *dentry;
>      struct inode    *inode;
>      int     flags = O_RDONLY|O_LARGEFILE;
>      __be32      err;
>      int     host_err = 0;
> +   struct super_block* sb;
>
>      validate_process_creds();
>
> @@ -774,6 +1026,11 @@
>          else
>              flags = O_WRONLY|O_LARGEFILE;
>      }
> +
> +   sb = fhp->fh_export->ex_path.mnt->mnt_sb;
> +   if (size&&  can_use_direct_io(NULL, sb, offset, size))
> +       flags |= O_DIRECT;
> +
>      *filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_path.mnt),
>                  flags, current_cred());
>      if (IS_ERR(*filp))
> @@ -885,8 +1142,10 @@
>      return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
>   }
>
> +
> +
>   static __be32
> -nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file
> *file,
> + nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file
> *file,
>                 loff_t offset, struct kvec *vec, int vlen, unsigned long
> *count)
>   {
>      mm_segment_t    oldfs;
> @@ -899,21 +1158,29 @@
>      if (rqstp->rq_vers>= 3)
>          file->f_flags |= O_NONBLOCK;
>
> -   if (file->f_op->splice_read&&  rqstp->rq_splice_ok) {
> -       struct splice_desc sd = {
> -           .len        = 0,
> -           .total_len  = *count,
> -           .pos        = offset,
> -           .u.data     = rqstp,
> -       };
> -
> -       rqstp->rq_resused = 1;
> -       host_err = splice_direct_to_actor(file,&sd,
> nfsd_direct_splice_actor);
> -   } else {
> +   if (file->f_flags&  O_DIRECT) {
> +       // So far we do not support splice IO, so always do regular
>          oldfs = get_fs();
>          set_fs(KERNEL_DS);
> -       host_err = vfs_readv(file, (struct iovec __user *)vec, vlen,
> &offset);
> +       host_err = nfsd_vfs_read_direct(file, (struct iovec*)vec, vlen,
> &offset);
>          set_fs(oldfs);
> +   } else {
> +       if (file->f_op->splice_read&&  rqstp->rq_splice_ok) {
> +           struct splice_desc sd = {
> +               .len        = 0,
> +               .total_len  = *count,
> +               .pos        = offset,
> +               .u.data     = rqstp,
> +           };
> +
> +           rqstp->rq_resused = 1;
> +           host_err = splice_direct_to_actor(file,&sd,
> nfsd_direct_splice_actor);
> +       } else {
> +           oldfs = get_fs();
> +           set_fs(KERNEL_DS);
> +           host_err = vfs_readv(file, (struct iovec __user *)vec, vlen,
> &offset);
> +           set_fs(oldfs);
> +       }
>      }
>
>      if (host_err>= 0) {
> @@ -1024,7 +1291,11 @@
>
>      /* Write the data. */
>      oldfs = get_fs(); set_fs(KERNEL_DS);
> -   host_err = vfs_writev(file, (struct iovec __user *)vec, vlen,&offset);
> +   if (file->f_flags&  O_DIRECT)
> +       host_err = nfsd_vfs_write_direct(file, (struct iovec*)vec, vlen,
> &offset);
> +   else
> +       host_err = vfs_writev(file, (struct iovec __user *)vec, vlen,
> &offset);
> +
>      set_fs(oldfs);
>      if (host_err<  0)
>          goto out_nfserr;
> @@ -1064,8 +1335,9 @@
>      struct inode *inode;
>      struct raparms  *ra;
>      __be32 err;
> +   unsigned long size = iov_length((struct iovec*)vec, vlen);
>
> -   err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,&file);
> +   err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,&file, offset,
> size);
>      if (err)
>          return err;
>
> @@ -1133,7 +1405,8 @@
>          err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
>                  stablep);
>      } else {
> -       err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE,&file);
> +       unsigned long size = iov_length((struct iovec*)vec, vlen);
> +       err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE,&file, offset,
> size);
>          if (err)
>              goto out;
>
> @@ -1173,7 +1446,7 @@
>      }
>
>      err = nfsd_open(rqstp, fhp, S_IFREG,
> -           NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE,&file);
> +           NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE,&file, 0, 0);
>      if (err)
>          goto out;
>      if (EX_ISSYNC(fhp->fh_export)) {
> @@ -2018,7 +2291,7 @@
>      struct file *file;
>      loff_t      offset = *offsetp;
>
> -   err = nfsd_open(rqstp, fhp, S_IFDIR, NFSD_MAY_READ,&file);
> +   err = nfsd_open(rqstp, fhp, S_IFDIR, NFSD_MAY_READ,&file, 0, 0);
>      if (err)
>          goto out;
>
> diff -uNr linux-orig/fs/nfsd/vfs.h linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/vfs.h
> --- linux-orig/fs/nfsd/vfs.h    2011-10-24 14:06:32.000000000 -0400
> +++ linux-3.0.7-0.7.2.8796.vmw/fs/nfsd/vfs.h    2012-03-28
> 15:40:29.000000000 -0400
> @@ -66,7 +66,7 @@
>                  loff_t, unsigned long);
>   #endif /* CONFIG_NFSD_V3 */
>   __be32     nfsd_open(struct svc_rqst *, struct svc_fh *, int,
> -               int, struct file **);
> +               int, struct file **, const loff_t, const unsigned long);
>   void       nfsd_close(struct file *);
>   __be32         nfsd_read(struct svc_rqst *, struct svc_fh *,
>                  loff_t, struct kvec *, int, unsigned long *);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
