Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:53118 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445Ab2DRR4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2012 13:56:45 -0400
From: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
To: "'Myklebust, Trond'" <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
References: <9c0b78d1.00001bd8.00000533@aldep-VC.vmware.com> <1334765979.4701.27.camel@lade.trondhjem.org>
In-Reply-To: <1334765979.4701.27.camel@lade.trondhjem.org>
Subject: RE: [PATCH RFC] Performing direct I/O on sector-aligned requests
Date: Wed, 18 Apr 2012 10:56:44 -0700 (PDT)
Message-ID: <7ac2213f.00001bd8.00000539@aldep-VC.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I did not notice any slowdown when doing unaligned or aligned IO, when NFS 
was mounted in synchronous mode.
I can see possible performance issues with writes when NFS is mounted in 
asynchronous mode, or do you foresee any other problematic situations?
Thank you,

Alex

-----Original Message-----
From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
Sent: Wednesday, April 18, 2012 12:20 PM
To: Alexandre Depoutovitch
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] Performing direct I/O on sector-aligned requests

On Wed, 2012-04-18 at 07:18 -0700, Alexandre Depoutovitch wrote:
> NFS daemons always perform buffered IO on files. As a result, write
> requests that are not aligned on a file system block boundary take about
> 15 times more time to complete compared to the same writes that are file
> system block aligned. This patch fixes the problem by analyzing alignment
> of the IO request that comes to NFS daemon and using Direct I/O mechanism
> when all of the following are true:
> 1. Request is not aligned on a file system block boundary
> 2. Request is aligned on an underlying block device’s sector boundary.
> 3. Request size is a multiple of the sector size.
> In all other cases, buffered IO is performed as has been done before.
>
> After applying a patch, the resulting performance of all types of
> requests, except unaligned writes remains the same, while performance of
> unaligned writes improves 15 times.
> A new flag is exposed to users through /proc/fs/nfsd/direct_io node. The
> default value of 1 results in the above behavior. Writing 0 to the node
> turns off the optimization, and forces NFS daemon to always use buffered
> IO (as it has done before). Writing 2 to the node tells NFS daemon to use
> direct I/O even if request is file system block aligned.
>
> I have tested this patch by running concurrent NFS writes to an exported
>  file system and verifying locally that writes reached the disk.
>
<snip>
> +/*
> + Performs direct I/O for a given NFS write request
> +*/
> +static ssize_t nfsd_vfs_write_direct(struct file *file, const struct
> iovec *vec,
> +                                 unsigned long vlen, loff_t *pos) {
> +              ssize_t result = -EINVAL;
> +              unsigned int page_num;
> +              struct iovec *aligned_vec = NULL;
> +
> +              // Check size to be multiple of sectors
> +              size_t size = iov_length(vec, vlen);
> +
> +              if (size == 0)
> +                              return vfs_writev(file, (struct iovec
> __user *)vec, vlen, pos);
> +
> +              // Allocate necesary number of pages
> +              result = nfsd_allocate_paged_iovec(size, &page_num,
> &aligned_vec);
> +              if (result) {
> +                              printk(KERN_WARNING"Cannot allocate
> aligned_vec.");
> +                              goto out;
> +              }
> +
> +              // Copy data
> +              result = nfsd_copy_iovec(vec, vlen, aligned_vec, page_num,
> size);
> +              if(result) {
> +                              printk(KERN_WARNING"Wrong amount of data
> copied to aligned buffer.");
> +                              goto out;
> +              }
> +
> +              // Call further
> +              result = vfs_writev(file, (struct iovec __user
> *)aligned_vec, page_num, pos);
> +
> +out:
> +              nfsd_free_paged_iovec(page_num, aligned_vec);
> +              return result;
> +}
> +
> +

Can this be rewritten to use Dave Kleikamp's iov_iter interface with
asynchronous reads and writes? Otherwise I can't see how it is going to
avoid being mindnumbingly slow.

You can see the LWN description and link to his patches in
http://lwn.net/Articles/490114/

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

