Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34576 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBDWL2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2017 17:11:28 -0500
Received: by mail-oi0-f66.google.com with SMTP id w144so4030419oiw.1
        for <linux-nfs@vger.kernel.org>; Sat, 04 Feb 2017 14:11:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170204030842.GL27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 4 Feb 2017 23:11:27 +0100
Message-ID: <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS list <linux-nfs@vger.kernel.org>, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 4, 2017 at 4:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Feb 02, 2017 at 09:51:25AM +0000, Al Viro wrote:
>
>>       * fuse_copy_fill().  I'm not at all sure that iov_iter_get_pages()
>> is a good idea there - fuse_copy_do() could bloody well just use
>> copy_{to,from}_iter().
>
> Miklos, could you explain why does lock_request() prohibit page faults until
> the matching unlock_request()?  All it does is setting FR_LOCKED on
> our request and the only thing that even looks at that is fuse_abort_conn(),
> which doesn't (AFAICS) wait for anything.
>
> Where does the deadlock come from, and if it's not a deadlock - what is
> it?  Or is that comment stale since "fuse: simplify request abort"?

Well, it's not historical; at least not yet.  The deadlock is there
alright: mmap fuse file to addr; read byte from mapped page -> page
locked; this triggeres read request served in same process but
separate thread; write addr-headerlen to fuse dev; trying to lock same
page -> deadlock.

The deadlock can be broken by aborting or force unmounting: return
error for original read request; page unlocked; device write can get
page lock and return.

The reason we need to prohibit pagefault while copying is that when
request is aborted and the caller returns the memory in the request
may become invalid (e.g. data from stack).

Another solution would be to copy all data and keep a ref on the copy
by the request even after being aborted.  This is the plan for the
future.

Thanks,
Miklos
