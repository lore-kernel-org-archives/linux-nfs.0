Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38096 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdBEVBy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 16:01:54 -0500
Date: Sun, 5 Feb 2017 21:01:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS list <linux-nfs@vger.kernel.org>, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170205210151.GD13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk>
 <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 05, 2017 at 09:15:24PM +0100, Miklos Szeredi wrote:

> That case is fine.   But nothing guarantees that fuse_abort_conn()
> won't be called (in the non-deadlock case) when data is being copied
> to the request args.  Ending the request at such a point could easily
> lead to use after free,

So why not leave ending it to your fuse_dev_do_write()/fuse_dev_do_read()?
See the reply I'd just sent (your mail arrived while I'd been writing that
one - saw it only after I'd sent mine).

Basically, what if we keep FR_LOCKED through *all* fuse_dev_do_{read,write}(),
rather than dropping and regaining it many times and have fuse_abort_conn()
skip request_end() on FR_LOCKED ones?
