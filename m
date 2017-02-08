Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33870 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754134AbdBHK5l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 05:57:41 -0500
Received: by mail-oi0-f66.google.com with SMTP id w144so10738468oiw.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 02:57:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170208055431.GJ13195@ZenIV.linux.org.uk>
References: <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk> <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
 <20170205220445.GE13195@ZenIV.linux.org.uk> <20170206030532.GF13195@ZenIV.linux.org.uk>
 <CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
 <20170206095706.GG13195@ZenIV.linux.org.uk> <CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
 <20170207071909.GI13195@ZenIV.linux.org.uk> <20170207113554.GA30656@veci.piliscsaba.szeredi.hu>
 <20170208055431.GJ13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 8 Feb 2017 10:53:26 +0100
Message-ID: <CAJfpegtXfDbM7YhE6JY==f_mGLwE3BUHR1rX8YbaEr=OHQGQnQ@mail.gmail.com>
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

On Wed, Feb 8, 2017 at 6:54 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Feb 07, 2017 at 12:35:54PM +0100, Miklos Szeredi wrote:
>> > Another thing: what guarantees that places in writepages-related paths
>> > where we store a reference into req->ff won't hit a request with already
>> > non-NULL ->ff?
>>
>> Well, it is set before being sent (queued onto queued_writes or queued on the
>> fuse device), but not when queued as secondary request onto an already in-flight
>> one.  It looks okay to me.
>
>>  void fuse_sync_release(struct fuse_file *ff, int flags)
>>  {
>> -     WARN_ON(atomic_read(&ff->count) > 1);
>> +     WARN_ON(atomic_read(&ff->count) != 1);
>>       fuse_prepare_release(ff, flags, FUSE_RELEASE);
>> -     __set_bit(FR_FORCE, &ff->reserved_req->flags);
>> -     __clear_bit(FR_BACKGROUND, &ff->reserved_req->flags);
>> -     fuse_request_send(ff->fc, ff->reserved_req);
>> -     fuse_put_request(ff->fc, ff->reserved_req);
>> -     kfree(ff);
>> +     fuse_file_put(ff, true);
>
> Umm...  At the very least, that deserves a comment re "iput(NULL) is a no-op
> and since the refcount is 1 and everything's synchronous, we are fine with
> not doing igrab/iput here".  There's enough mysteries in that code as it is...

Added comment.

>         Speaking of mysteries - how can ->private_data ever be NULL in
> fuse_release_common()?  AFAICS, it's only called from ->release() instances
> and those are only called after ->open() or ->atomic_open() on that struct file
> has returned 0.  On the ->open() side, it means fuse_do_open() having returned
> 0; on ->atomic_open() one - fuse_create_open() having done the same.  Neither
> is possible with ->private_data remaining NULL, and I don't see any places
> that would modify it afterwards...

Goes back to v2.6.15 (commit fd72faac95d7 "[PATCH] FUSE: atomic
create+open").  Didn't make sense back then, and it doesn't now.
Fixed.

>         Another thing: am I right assuming that ff->nodeid will be the same
> for all ff over given inode (== get_node_id(inode))?

Yes.  Except for cuse, where it's zero.

>  What about ff->fh?
> Is that a per-open thing, or will it be identical for all opens of the same
> inode?

A per-open thing (opaque identifier used by userspace fs to identify
the open file)

Thanks,
Miklos
