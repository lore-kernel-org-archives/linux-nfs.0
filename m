Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:53826 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756863Ab2D3VjU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 17:39:20 -0400
Date: Mon, 30 Apr 2012 14:39:19 -0700 (PDT)
From: Alexandre Depoutovitch <adepoutovitch@vmware.com>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Message-ID: <864395031.4907153.1335821959925.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
In-Reply-To: <20120430195645.GC9022@parisc-linux.org>
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: "Matthew Wilcox" <matthew@wil.cx>
> To: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
> Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
> Sent: Monday, April 30, 2012 3:56:46 PM
> Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
> 
> On Sun, Apr 29, 2012 at 02:03:41PM -0700, Alexandre Depoutovitch
> wrote:
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
> > +           >> PAGE_SHIFT;
> > +       /* For kernel threads buffer must be in kernel memory */
> > +       BUG_ON(dio->curr_user_address < TASK_SIZE_MAX);
> 
> This is an assumption that isn't true for all architectures.  Better
> just
> delete this line.


Thank you, I will do this.

 
> > +       for (i = 0; i < nr_pages; i++) {
> > +           page = pfn_to_page(start_pfn + i);
> 
> Why are you messing about with pfns?  Why not just stay with virtual
> addresses and call virt_to_page() in this loop?  That would ensure
> that
> this works to vmapped pages as well as physically contiguous pages.


I have already changed this. Thanks.
 
> > +           page_cache_get(page);
> > +           dio->pages[i] = page;
> > +       }
> > +       /* No need to lock pages: this is kernel thread and the
> > pages are in
> > +         kernel as well */
> > +       ret = nr_pages;
> > +   }
> > 
> >     if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
> >         struct page *page = ZERO_PAGE(0);
> > @@ -972,7 +991,11 @@
> >                 break;
> >         }
> > 
> > -       /* Drop the ref which was taken in get_user_pages() */
> > +       /*
> > +        * Drop the ref which was taken in dio_refill_pages
> > +        * directly (for direct I/O) or by calling get_user_pages
> > +        * (for buffered IO)
> > +        */
> 
> I think your change to this comment actually makes it more confusing.


I will remove it if is confusing.
 
> > @@ -1348,6 +1351,58 @@
> >                             nfsd_max_blksize);
> >  }
> > 
> > +int nfsd_directio_mode = DIO_NEVER;
> > +
> > +/**
> > + * nfsd_directio_mode - sets conditions when direct IO is
> > activated
> > + *
> > + * Input:
> > + *         buf:        ignored
> > + *         size:       zero
> > + *
> > + * OR
> > + *
> > + * Input:
> > + *             buf:        C string containing an unsigned
> > + *                     integer value representing the new
> > + *                     NFS direct IO mode
> > + *         size:       non-zero length of C string in @buf
> > + * Output:
> > + * On success: passed-in buffer filled with '\n'-terminated C
> > string
> > + *         containing numeric value of the current direct IO mode
> > + *         return code is the size in bytes of the string
> > + *
> > + * Possible modes are:
> > + *     DIO_NEVER (0) - never use direct I/O
> > + *     DIO_FS_UNALIGNED (1) - use direct I/O only for requests
> > that FS
> > unaligned
> > + *         and block device aligned
> > + *     DIO_SECTOR_ALIGNED (3) - use direct I/O for all block
> > device aligned
> > IO
> > + * On error:   return code is zero or a negative errno value
> > + */
> 
> This is not correct kerneldoc formatting.



I copy/pasted it from the previous entry in the same file :(

 
> --
> Matthew Wilcox				Intel Open Source Technology Centre
> "Bill, look, we understand that you're interested in selling us this
> operating system, but compare it to ours.  We can't possibly take
> such
> a retrograde step."
> 
