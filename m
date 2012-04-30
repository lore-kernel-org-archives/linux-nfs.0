Return-Path: linux-nfs-owner@vger.kernel.org
Received: from palinux.external.hp.com ([192.25.206.14]:34135 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab2D3T4s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 15:56:48 -0400
Date: Mon, 30 Apr 2012 13:56:46 -0600
From: Matthew Wilcox <matthew@wil.cx>
To: Alexandre Depoutovitch <adepoutovitch@vmware.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
Message-ID: <20120430195645.GC9022@parisc-linux.org>
References: <9c0b78d1.00001bd8.00000533@aldep-VC.vmware.com> <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 29, 2012 at 02:03:41PM -0700, Alexandre Depoutovitch wrote:
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
> +           >> PAGE_SHIFT;
> +       /* For kernel threads buffer must be in kernel memory */
> +       BUG_ON(dio->curr_user_address < TASK_SIZE_MAX);

This is an assumption that isn't true for all architectures.  Better just
delete this line.

> +       for (i = 0; i < nr_pages; i++) {
> +           page = pfn_to_page(start_pfn + i);

Why are you messing about with pfns?  Why not just stay with virtual
addresses and call virt_to_page() in this loop?  That would ensure that
this works to vmapped pages as well as physically contiguous pages.

> +           page_cache_get(page);
> +           dio->pages[i] = page;
> +       }
> +       /* No need to lock pages: this is kernel thread and the pages are in
> +         kernel as well */
> +       ret = nr_pages;
> +   }
> 
>     if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
>         struct page *page = ZERO_PAGE(0);
> @@ -972,7 +991,11 @@
>                 break;
>         }
> 
> -       /* Drop the ref which was taken in get_user_pages() */
> +       /*
> +        * Drop the ref which was taken in dio_refill_pages
> +        * directly (for direct I/O) or by calling get_user_pages
> +        * (for buffered IO)
> +        */

I think your change to this comment actually makes it more confusing.

> @@ -1348,6 +1351,58 @@
>                             nfsd_max_blksize);
>  }
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

This is not correct kerneldoc formatting.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
