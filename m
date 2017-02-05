Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37986 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdBEU4Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 15:56:24 -0500
Date: Sun, 5 Feb 2017 20:56:17 +0000
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
Message-ID: <20170205205617.GC13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170205015145.GB13195@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 05, 2017 at 01:51:49AM +0000, Al Viro wrote:

> IDGI.  Your request is marked aborted and should presumably fail, so
> that when request_wait_answer() wakes up and finds it screwed, fuse_readpage()
> would just return an error and filemap_fault() will return VM_FAULT_SIGBUS,
> with page left not uptodate and _not_ inserted into page tables.  What's
> leaking where?

Egads...  Do you mean that req->pages[] contents can be dropped by connection
abort right under fuse_copy_pages()?  Or is it that args[...].value can
end up freed under you?

<goes to look at the ->end() callbacks>

Both, apparently, plus the request initiator might have seen that
request has failed and buggered off, with args[...].value pointing to
what used to be initiator's stack frame.  Is that what you are talking about?


If so, why not mark request as "being handled by fuse_dev_do_{read,write}()"
for the duration, and leave the request_end() on such requests for
fuse_dev_do_{read,write}(), seeing that they will call request_end() for such
anyway?

Looks like your FR_LOCKED is not far from that already.  Why not stop
dropping/regaining FR_LOCKED in lock_request()/unlock_request() and simply
have your
                end_requests(fc, &to_end2);
in fuse_abort_conn() skip the actual calls of request_end()?
