Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:34001 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdBDWMt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2017 17:12:49 -0500
Received: by mail-ot0-f193.google.com with SMTP id 73so6330165otj.1
        for <linux-nfs@vger.kernel.org>; Sat, 04 Feb 2017 14:12:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170204192655.GA13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170204030842.GL27291@ZenIV.linux.org.uk>
 <20170204192655.GA13195@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 4 Feb 2017 23:12:48 +0100
Message-ID: <CAJfpeguuL9ng4-QmpX=BvZtA3=QtvEWQUSW21d5sPYmzmSA9Dg@mail.gmail.com>
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

On Sat, Feb 4, 2017 at 8:26 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sat, Feb 04, 2017 at 03:08:42AM +0000, Al Viro wrote:

> What am I missing here?  Looks like those checks in fuse_copy_page() are
> dead code...  They had been there since the initial merge, but AFAICS
> they were just as useless in 2.6.14.  Rudiments of some prehistorical stuff
> that never had been cleaned out, perhaps?

Yep, that one is probably historical.  I'll double check to make sure, though.

Thanks,
Miklos
