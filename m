Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49118 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdBCTId (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 14:08:33 -0500
Date: Fri, 3 Feb 2017 19:08:17 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>, lustre-devel@lists.lustre.org,
        V9FS Developers <v9fs-developer@lists.sourceforge.net>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170203190816.GK27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk>
 <1486040452.2812.6.camel@redhat.com>
 <20170203072952.GI27291@ZenIV.linux.org.uk>
 <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 03, 2017 at 10:29:23AM -0800, Linus Torvalds wrote:
> On Thu, Feb 2, 2017 at 11:29 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > get_user_pages() relies upon find_extend_vma() to reject kernel
> > addresses; the fast side of get_user_pages_fast() doesn't have anything
> > of that sort
> 
> It is *supposed* to have it.
> 
> See pte_allows_gup(), for example. In particular, it requires the
> _PAGE_USER bit in the PTE (and the devpte case should require
> _PAGE_BIT_DEVMAP).

On x86 it does.  I don't see anything equivalent in mm/gup.c one, and the
only kinda-sorta similar thing (access_ok() in __get_user_pages_fast()
there) is vulnerable to e.g. access via kernel_write().  The comment in
there
 * Before activating this code, please be aware that the following assumptions
 * are currently made:
 *
 *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
 *      pages containing page tables.
 *
 *  *) ptes can be read atomically by the architecture.
 *
 *  *) access_ok is sufficient to validate userspace address ranges.
 *
 * The last two assumptions can be relaxed by the addition of helper functions.

doesn't look promising - access_ok() is never sufficient.  Something like
_PAGE_USER tests in x86 one solves that problem, but if anything similar
works for HAVE_GENERIC_RCU_GUP I don't see it.  Thus the question re
what am I missing here...
