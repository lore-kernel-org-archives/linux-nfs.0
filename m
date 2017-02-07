Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52084 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGHTQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 02:19:16 -0500
Date: Tue, 7 Feb 2017 07:19:09 +0000
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
Message-ID: <20170207071909.GI13195@ZenIV.linux.org.uk>
References: <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk>
 <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk>
 <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
 <20170205220445.GE13195@ZenIV.linux.org.uk>
 <20170206030532.GF13195@ZenIV.linux.org.uk>
 <CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
 <20170206095706.GG13195@ZenIV.linux.org.uk>
 <CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 06, 2017 at 03:18:42PM +0100, Miklos Szeredi wrote:

> But I think it's breakable in the same way: if the deadlocked request
> is aborted, the fault will release the page lock as well as mmap_sem,
> and from there things will resolve themselves.

Right you are - original holder of ->mmap_sem is waiting for request and
abort will wake it up...

> But you are definitely right about needing to clean up that mess in
> fuse/dev.c and doing so by fixing up the arg refcounting for just the
> read and write requests is going to be a lot simpler than having to do
> that for all of them (which was my original plan).

Speaking of refcounting - what's going on with fuse_file one?  My reading
of that code is that you have 4 states of that thing:
	* new (just created, fallback request allocated, use fuse_file_free()
to kill).  Refcount is 0.
	* intermediate - in fact it's already opened, but still not
put into ->private_data.  Refcount is still 0.  Use fuse_sync_release() to kill.
	* live - normal refcounting (fuse_file_get()/fuse_file_put()).
	* shutdown - refcount has reached 0.  Can't happen until ->release()
(obviously - ->private_data holds a counting reference), some pieces of
fuse_sync_release() correspond to some stuff in fuse_release_common(), some -
to final fuse_file_put().

To make it even more convoluted, cuse is using fuse_sync_release() and
apparently relies upon no references being grabbed after fuse_do_open(),
so that thing can be called with refcount 0 *or* refcount 1.

Another thing: what guarantees that places in writepages-related paths
where we store a reference into req->ff won't hit a request with already
non-NULL ->ff?
