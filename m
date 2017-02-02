Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60955 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750879AbdBBOsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Feb 2017 09:48:22 -0500
Date: Thu, 2 Feb 2017 15:48:17 +0100
From: Jan Kara <jack@suse.cz>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170202144817.GB15545@quack2.suse.cz>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 02-02-17 09:51:25, Al Viro wrote:
> I'm massaging that code (along with a lot of RTFS); the interesting questions
> related to VM side of things are
> 	* what are the relative costs of doing small vs. large batches?  Some
> of get_user_pages_fast() instances have comments along the lines of "we ought
> to limit the batch size, but then nobody's doing more than 64 pages at a time
> anyway".

Well, I believe it's only about the cost of setting up page table walk and
walking down those several levels of page tables. It is cheaper to copy
several PTE entries from the leaf level than doing the full walk every
time. But I didn't ever profile it to get actual numbers.

Large batches are only a problem because of possible soft-lockups and irq
latencies AFAIK. So the batch just should not be insanely large...

> 	* Not a question: any ->fault() that returns VM_FAULT_RETRY when
> *not* passed FAULT_FLAG_ALLOW_RETRY in flags ought to be shot.  cxlflash one
> sure as hell is.

Yep.

> 	* drivers/gpu/drm/vgem/vgem_drv.c:vgem_gem_fault() is bloody odd -
> shmem_read_mapping_page() can't return -EBUSY, AFAICS.  vm_insert_page()
> used to (and back then vgem_gem_fault() used to be broken), but these days
> it looks like dead code...

Looks like that.

> 	* ->page_mkwrite() instances sometimes return VM_FAULT_RETRY; AFAICS,
> it's only (ab)used there as 'not zero, but doesn't contain any error bits';
> VM_FAULT_RETRY from that source does *not* reach handle_mm_fault() callers,
> right?

I can see only Lustre doing it and IMHO it is abuse. VM_FAULT_RETRY is used
for mmap_sem latency reduction when paging in pages and so not everybody
handles it. If a handler wants to simply retry the fault, returning
VM_FAULT_NOPAGE is a more common way to do that...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
