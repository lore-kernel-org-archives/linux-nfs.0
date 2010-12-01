Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21717 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642Ab0LAE3a convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 23:29:30 -0500
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
	 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 23:29:13 -0500
Message-ID: <1291177753.7694.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 20:10 -0800, Linus Torvalds wrote:
> On Tue, Nov 30, 2010 at 7:47 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > Otherwise, the VM may end up removing it while we're reading from it.
> 
> I don't think this is valid.
> 
> Maybe it fixes a bug, but the commit description is misleading at
> best.  Since you have a reference count to the page, the page is not
> going away. Locking may hide some other bug (due to serializing with
> other code you care about), but it is _not_ about the "VM may end up
> removing it".
> 
> Even from a serialization angle, I think this patch is a bit suspect,
> since readdir() will always be called under the inode semaphore, so I
> think you'll always be serialized wrt other readdir users. Of course,
> you may have invalidation events etc that are outside of readdir, so
> ...

I'm not worried about other readdir calls invalidating the page. My
concern is rather about the VM memory reclaimers ejecting the page from
the page cache, and calling nfs_readdir_clear_array while we're
referencing the page. This wasn't a problem with the previous readdir
code, but it will be with the new incarnation because the actual
filenames are stored outside the page itself.
As far as I can see, the only way to protect against that is to lock the
page, perform the usual tests and then release the page lock when we're
done...

> Anyway if this patch matters, there's something else going on, and you
> need to describe that.

No problem. I just wanted to get the patches out so that the people who
are reporting regressions can start testing.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

