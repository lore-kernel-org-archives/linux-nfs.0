Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:43700 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726278AbeILIFS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Sep 2018 04:05:18 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        cks@cs.toronto.edu
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: trondmy's message of Wed, 12 Sep 2018 02:19:34 -0000.
             <a4bff5838b478038b6fa0122d37aee7895c4dc7d.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 23:03:00 -0400
Message-Id: <20180912030300.696D4322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >  If a client kernel has cached pages this way, is there any simple
> > sequence of system calls on the client that will cause it to discard
> > these cached pages? Or do you need the file's GETATTR to change again,
> > implicitly from another machine? (I assume that changing the file's
> > attributes from the client with the cached pages doesn't cause it to
> > invalidate them, and certainly eg a 'touch' doesn't do it from the
> > client where it does do it from another machine.)
> 
> There are 2 ways to manipulate the page cache directly on the client:
>    1. You can clear out the entire page cache as the 'root' user, with the
>       /proc/sys/vm/drop_caches interface (see 'man 5 proc').
>    2. Alternatively, you can use posix_fadvise() with the
>       POSIX_FADV_DONTNEED flag to clear out only the pages that you think
>       are bad. Make sure to first fsync() so that the pages don't get
>       pinned in memory by virtue of being dirty (see 'man 2 fadvise64').

 I just did some experiments, and on the Ubuntu 18.04 LTS version of
4.15.0, it appears that flock()'ing the file before re-reading it will
cause the kernel to not manifest the problem. I don't seem to have to
flock() the file initially when I read it before the change, and it's
sufficient to use LOCK_SH instead of LOCK_EX. (And I do have to flock()
after the change, otherwise I still see the problem even if I flock()
before.)

 Is this a supported/guaranteed behavior, or is it just lucky coincidence
that things currently work this way, much like it was happenstance
instead of design that things worked back in the 4.4.x era?

 It would be very convenient for us if flock() works around this,
because it turns out that the only reason Alpine is not flock()'ing
files is that it has an ancient 'do not use flock on Linux NFS' piece of
code deep inside it that was apparently there to work around a bug that
seems to have been fixed a decade or so ago:

   http://repo.or.cz/alpine.git/blob/HEAD:/imap/src/osdep/unix/flocklnx.c

	- cks
