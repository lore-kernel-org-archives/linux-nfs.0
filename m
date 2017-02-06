Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34275 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752321AbdBFOSn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2017 09:18:43 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so10469541otj.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Feb 2017 06:18:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170206095706.GG13195@ZenIV.linux.org.uk>
References: <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk> <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk> <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
 <20170205220445.GE13195@ZenIV.linux.org.uk> <20170206030532.GF13195@ZenIV.linux.org.uk>
 <CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com> <20170206095706.GG13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 6 Feb 2017 15:18:42 +0100
Message-ID: <CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
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

On Mon, Feb 6, 2017 at 10:57 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Feb 06, 2017 at 10:08:06AM +0100, Miklos Szeredi wrote:
>
>> Yes, I think only page lock can be used to deadlock inside
>> fuse_dev_read/write().  So requests that don't have locked pages
>> should be okay  with just waiting until copy_to/from_user() finishes
>> and only then proceeding with the abort.
>
> Actually, looking at that some more, this might be not true.  Anything
> that takes ->mmap_sem exclusive and *not* killable makes for another
> source of deadlock.
>
> Initial page fault takes ->mmap_sem shared.  OK, request sent to
> server and server tries to read() it.  In the meanwhile, something
> has closed userfaultfd for the same mm_struct.  We have userfaultfd_release()
> block on attempt to take ->mmap_sem exclusive and from now on any attempt
> to grab ->mmap_sem shared will deadlock.  And get_user_pages(), as well
> as copy_to_user(), etc. can end up doing just that.  It doesn't have to
> be an mmap of the same file, BTW - any page fault would do.
>
> All you really need is to have server sharing address space with the
> process that steps into original page fault, plus an evicted page
> of any nature (anon mmap, whatever) being used as a destination of
> read() in server.
>
> down_read() inside down_read() is fine, unless there had been down_write()
> in between.  And there are unkillable down_write() on ->mmap_sem -
> userfaultfd_release() being one example of such.  Many of those can and
> probably should become down_write_killable(), but this one can't - there
> might be nothing to deliver the signal to, if the final close() happens
> e.g. from exit(2).
>
> Warning: the above might be completely bogus - I'm on way too large
> uptime at the moment and most of the last day had been spent digging
> through various convoluted code, so take the above with a cartload of
> salt.  _If_ it's true, that kind of deadlock won't be possible to
> break with killing anything or doing umount -f, though.

It's not bogus, the deadlock is there.

But I think it's breakable in the same way: if the deadlocked request
is aborted, the fault will release the page lock as well as mmap_sem,
and from there things will resolve themselves.

But you are definitely right about needing to clean up that mess in
fuse/dev.c and doing so by fixing up the arg refcounting for just the
read and write requests is going to be a lot simpler than having to do
that for all of them (which was my original plan).

So, I'll have a go at that sometime.

Thanks,
Miklos
