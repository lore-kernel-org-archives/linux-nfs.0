Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34091 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdBCS3Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 13:29:24 -0500
MIME-Version: 1.0
In-Reply-To: <20170203072952.GI27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk> <1486040452.2812.6.camel@redhat.com>
 <20170203072952.GI27291@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Feb 2017 10:29:23 -0800
Message-ID: <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>, lustre-devel@lists.lustre.org,
        V9FS Developers <v9fs-developer@lists.sourceforge.net>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 2, 2017 at 11:29 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> get_user_pages() relies upon find_extend_vma() to reject kernel
> addresses; the fast side of get_user_pages_fast() doesn't have anything
> of that sort

It is *supposed* to have it.

See pte_allows_gup(), for example. In particular, it requires the
_PAGE_USER bit in the PTE (and the devpte case should require
_PAGE_BIT_DEVMAP).

So no, get_user_pages_fast() can not look up kernel pages. If it does,
that would be a bug.

              Linus
