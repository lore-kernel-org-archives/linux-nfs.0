Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33497 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBEUP0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 15:15:26 -0500
Received: by mail-oi0-f65.google.com with SMTP id j15so5170128oih.0
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 12:15:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170205015145.GB13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com> <20170205015145.GB13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 5 Feb 2017 21:15:24 +0100
Message-ID: <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
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

On Sun, Feb 5, 2017 at 2:51 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sat, Feb 04, 2017 at 11:11:27PM +0100, Miklos Szeredi wrote:
>
>> Well, it's not historical; at least not yet.  The deadlock is there
>> alright: mmap fuse file to addr; read byte from mapped page -> page
>> locked; this triggeres read request served in same process but
>> separate thread; write addr-headerlen to fuse dev; trying to lock same
>> page -> deadlock.
>
> Let me see if I got it straight - you have the same fuse file mmapped
> in two processes, one of them being fuse server (either sharing the
> entire address space, or the same area mapped in both).  Another process
> faults the sucker in; filemap_fault() locks the page and goes
> fuse_readpage() -> fuse_do_readpage() -> fuse_send_read() ->
> -> fuse_request_send() -> __fuse_request_send() which puts request into
> queue and goes to sleep in request_wait_answer().  Eventually, read()
> on /dev/fuse (or splice(), whatever) by server picks that request and reply
> is formed and fed back into /dev/fuse.  There we (in fuse_do_dev_write())
> call copy_out_args(), which tries to copy into our (still locked) page
> a piece of data coming from server-supplied iovec.  As it is, you
> are calling get_user_pages_fast(), triggering handle_mm_fault().  Since that
> malicous FPOS of a server tried to feed you the _same_ mmapped file, you
> hit a deadlock.  In server's context.  Correct?

Yes.

> Convoluted, but possible.  But.  Why the hell do we care whether that deadlock
> hits in get_user_pages_fast() or in copy_from_user()?  Put it another way,
> what difference does it make whether we take that fault with or without
> FR_LOCKED in req->flags?

The difference is that if the page fault happens without FR_LOCKED,
then we can abort the request then and there (done by moving the
request to to_end1 and calling request_end() on it).

If abort happens with FR_LOCKED, we can't end the request now, because
data is possibly being copied to/from the request args.  But we are
guaranteed that the request will end shortly, because no sleeping
under FR_LOCKED is allowed.

But with copy_from_user() page fault and copy aren't separated and so
we don't know whether it's safe to abort or not.

Maybe I'm missing something obvious, but I don't see a simple way out of this.

>> The deadlock can be broken by aborting or force unmounting: return
>> error for original read request; page unlocked; device write can get
>> page lock and return.
>>
>> The reason we need to prohibit pagefault while copying is that when
>> request is aborted and the caller returns the memory in the request
>> may become invalid (e.g. data from stack).
>
> ???
>
> IDGI.  Your request is marked aborted and should presumably fail, so
> that when request_wait_answer() wakes up and finds it screwed, fuse_readpage()
> would just return an error and filemap_fault() will return VM_FAULT_SIGBUS,
> with page left not uptodate and _not_ inserted into page tables.  What's
> leaking where?

That case is fine.   But nothing guarantees that fuse_abort_conn()
won't be called (in the non-deadlock case) when data is being copied
to the request args.  Ending the request at such a point could easily
lead to use after free,

Thanks,
Miklos
