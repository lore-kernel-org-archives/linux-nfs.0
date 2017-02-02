Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45186 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdBBS2I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2017 13:28:08 -0500
Date: Thu, 2 Feb 2017 18:28:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jan Kara <jack@suse.cz>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170202182802.GH27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202144817.GB15545@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170202144817.GB15545@quack2.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:48:17PM +0100, Jan Kara wrote:

> > 	* ->page_mkwrite() instances sometimes return VM_FAULT_RETRY; AFAICS,
> > it's only (ab)used there as 'not zero, but doesn't contain any error bits';
> > VM_FAULT_RETRY from that source does *not* reach handle_mm_fault() callers,
> > right?
> 
> I can see only Lustre doing it and IMHO it is abuse. VM_FAULT_RETRY is used
> for mmap_sem latency reduction when paging in pages and so not everybody
> handles it. If a handler wants to simply retry the fault, returning
> VM_FAULT_NOPAGE is a more common way to do that...

/* Convert errno to return value from ->page_mkwrite() call */
static inline int block_page_mkwrite_return(int err)
{
        if (err == 0)
                return VM_FAULT_LOCKED;
        if (err == -EFAULT)
                return VM_FAULT_NOPAGE;
        if (err == -ENOMEM)
                return VM_FAULT_OOM;
        if (err == -EAGAIN)
                return VM_FAULT_RETRY;
        /* -ENOSPC, -EDQUOT, -EIO ... */
        return VM_FAULT_SIGBUS;
}

and a bunch of ->page_mkwrite() instances using that.  However, the only
callers of ->page_mkwrite() are wp_page_shared()->do_page_mkwrite() and
do_shared_fault()->do_page_mkwrite().  do_page_mkwrite() treates
VM_FAULT_RETRY as "lock page and return VM_FAULT_RETRY|VM_FAULT_LOCKED".
Both callers do the same check -
                if (unlikely(!tmp || (tmp &
                                      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
and the return value if that predicate is false.  FWIW, use of VM_FAULT_RETRY
comes from your patch back in 2011 and AFAICS the same analysis used to
apply back then, except for the open-coded method calls where we use
do_page_mkwrite() these days...
