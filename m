Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57292 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753387AbdBDDJE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 22:09:04 -0500
Date: Sat, 4 Feb 2017 03:08:42 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170204030842.GL27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 02, 2017 at 09:51:25AM +0000, Al Viro wrote:

> 	* fuse_copy_fill().  I'm not at all sure that iov_iter_get_pages()
> is a good idea there - fuse_copy_do() could bloody well just use
> copy_{to,from}_iter().

Miklos, could you explain why does lock_request() prohibit page faults until
the matching unlock_request()?  All it does is setting FR_LOCKED on
our request and the only thing that even looks at that is fuse_abort_conn(),
which doesn't (AFAICS) wait for anything.

Where does the deadlock come from, and if it's not a deadlock - what is
it?  Or is that comment stale since "fuse: simplify request abort"?
