Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36761 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdBEVTV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 16:19:21 -0500
Received: by mail-oi0-f67.google.com with SMTP id u143so5216815oif.3
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 13:19:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170205210151.GD13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
 <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
 <20170205015145.GB13195@ZenIV.linux.org.uk> <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 5 Feb 2017 22:19:20 +0100
Message-ID: <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
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

On Sun, Feb 5, 2017 at 10:01 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Feb 05, 2017 at 09:15:24PM +0100, Miklos Szeredi wrote:
>
>> That case is fine.   But nothing guarantees that fuse_abort_conn()
>> won't be called (in the non-deadlock case) when data is being copied
>> to the request args.  Ending the request at such a point could easily
>> lead to use after free,
>
> So why not leave ending it to your fuse_dev_do_write()/fuse_dev_do_read()?
> See the reply I'd just sent (your mail arrived while I'd been writing that
> one - saw it only after I'd sent mine).
>
> Basically, what if we keep FR_LOCKED through *all* fuse_dev_do_{read,write}(),
> rather than dropping and regaining it many times and have fuse_abort_conn()
> skip request_end() on FR_LOCKED ones?

Then we can't break out of that deadlock: we wait until
fuse_dev_do_write() is done until calling request_end() which
ultimately results in unlocking page.  But fuse_dev_do_write() won't
complete until the page is unlocked.

The only way out that I see is to have a refcount on all pages in
args.  Which means copying everything not already in refcountable page
(i.e. args on stack) to a page array.   It's definitely doable, but
needs time to sort out, and I'm definitely lacking that (overlayfs
currently trumps fuse).

Thanks,
Miklos
