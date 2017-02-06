Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34728 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBFIhO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2017 03:37:14 -0500
Received: by mail-oi0-f65.google.com with SMTP id w144so5985375oiw.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Feb 2017 00:37:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170205220445.GE13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk> <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk> <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
 <20170205220445.GE13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 6 Feb 2017 09:37:12 +0100
Message-ID: <CAJfpegtPELcLY_zGufhhfEYXAmmDsKnxexUyhsQFCQgZfuSY1A@mail.gmail.com>
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

On Sun, Feb 5, 2017 at 11:04 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Feb 05, 2017 at 10:19:20PM +0100, Miklos Szeredi wrote:
>
>> Then we can't break out of that deadlock: we wait until
>> fuse_dev_do_write() is done until calling request_end() which
>> ultimately results in unlocking page.  But fuse_dev_do_write() won't
>> complete until the page is unlocked.
>
> Wait a sec.  What happens if
>
> process A: fuse_lookup()
>                 struct fuse_entry_out outarg on stack
>                 ...
>                 fuse_request_send() with req->out.args[0].value = &outarg
>                         sleep in request_wait_answer() on req->waitq
> server: read the request, write reply
>         fuse_dev_do_write()
>                 copy_out_args()
>                         fuse_copy_args()
>                                 fuse_copy_one()
>                                         FR_LOCKED is guaranteed to be set
>                                         fuse_copy_do()
> process C on another CPU: umount -f
>         fuse_conn_abort()
>                 end_requests()
>                         request_end()
>                                 set FR_FINISHED
>                                 wake A up (via req->waitq)
> process A: regain CPU
>         bugger off from request_wait_answer(), through __fuse_request_send(),
>         fuse_request_send(), fuse_simple_request(), fuse_lookup_name(),
>         fuse_lookup() and out of fuse_lookup().
>
> In the meanwhile, server in fuse_copy_do() does memcpy() to what used to
> be outarg, corrupting the stack of process A.
>
> Sure, you need to hit a fairly narrow window, especially if you are to
> cause damage in A, but AFAICS it's not impossible.  Consider e.g. the
> situation when you lose CPU on preempt on the way to memcpy(); in that
> case server might come back when A has incremented its stack footprint
> again.  Or A might end up taking a hardware interrupt and handling it
> on the normal kernel stack, etc.
>
> Looks like *any* scenario where fuse_conn_abort() manages to run during
> that memcpy() has potential for that kind of trouble; any SMP box appears
> to be vulnerable, along with preempt UP...
>
> Am I missing something that prevents that kind of problem?

Yes: if FR_LOCKED is set, then we leave the request alone in
fuse_abort_conn().  Then, when the copy is finished and
request_unlock() is called, we return -ENOENT to fuse_dev_do_write(),
which in turn calls request_end() to wake up the original caller,
which gets -ECONNABORTED.

So basically FR_LOCKED is protecting the copy, which is guaranteed to
be atomic due to the get_user_pages magic that faults in all pages
beforehand.

Thanks,
Miklos
