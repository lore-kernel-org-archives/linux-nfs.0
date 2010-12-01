Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36334 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753789Ab0LAEKc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 23:10:32 -0500
In-Reply-To: <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com> <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Nov 2010 20:10:08 -0800
Message-ID: <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 7:47 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> Otherwise, the VM may end up removing it while we're reading from it.

I don't think this is valid.

Maybe it fixes a bug, but the commit description is misleading at
best.  Since you have a reference count to the page, the page is not
going away. Locking may hide some other bug (due to serializing with
other code you care about), but it is _not_ about the "VM may end up
removing it".

Even from a serialization angle, I think this patch is a bit suspect,
since readdir() will always be called under the inode semaphore, so I
think you'll always be serialized wrt other readdir users. Of course,
you may have invalidation events etc that are outside of readdir, so
...

Anyway if this patch matters, there's something else going on, and you
need to describe that.

                  Linus
