Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:46648 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725996AbeIQFnW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 01:43:22 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "cks@cs.toronto.edu" <cks@cs.toronto.edu>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Correctly understanding Linux's close-to-open consistency
In-reply-to: trondmy's message of Sun, 16 Sep 2018 16:12:43 -0000.
             <2e145c9d46e2fbec262d0bc67d6b14b75b41bea6.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 16 Sep 2018 20:18:35 -0400
Message-Id: <20180917001835.23C7232257C@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > >  Since failing to close() before another machine open()s puts you
> > > outside this outline of close-to-open, this kernel behavior is
> > > not a bug as such (or so it's been explained to me here).  If you
> > > go outside c-t-o, the kernel is free to do whatever it finds most
> > > convenient, and what it found most convenient was to not bother
> > > invalidating some cached page data even though it saw a GETATTR
> > > change.
> >
> > That would be a bug. If we have reason to believe the file has
> > changed, then we must invalidate the cache on the file prior to
> > allowing a read to proceed.
>
> The point here is that when the file is open for writing (or for
> read+write), and your applications are not using locking, then we have
> no reason to believe the file is being changed on the server, and we
> deliberately optimise for the case where the cache consistency rules
> are being observed.

 In this case the user level can be completely sure that the client
kernel has issued a GETATTR and received a different answer from the
NFS server, because the fstat() results it sees have changed from the
values it has seen before (and remembered). This may not count as the
NFS client kernel code '[having] reason to believe' that the file has
changed on the server from its perspective, but if so it's not because
the information is not available and a GETATTR would have to be explicitly
issued to find it out. The client code has made the GETATTR and received
different results, which it has passed to user level; it has just not
used those results to do things to its cached data.

 Today, if you do a flock(), the NFS client code in the kernel will
do things that invalidate the cached data, despite the GETATTR result
from the fileserver not changing. From my outside perspective, as someone
writing code or dealing with programs that must work over NFS, this is a
little bit magical, and as a result I would like to understand if it is
guaranteed that the magic works or if this is not officially supported
magic, merely 'it happens to work' magic in the way that having the
file open read-write without the flock() used to work in kernel 4.4.x
but doesn't now (and this is simply considered to be the kernel using
CTO more strongly, not a bug).

(Looking at a tcpdump trace, the flock() call appears to cause the kernel
to issue another GETATTR to the fileserver. The results are the same as
the GETATTR results that were passed to the client program.)

> Again, these are the cases where you are _not_ using locking to
> mediate. If you are using locking, then I agree that changes need to
> be seen by the client.

 The original code (Alpine) *is* using locking in the broad sense,
but it is not flock() locking; instead it is locking (in this case)
through .lock files. The current kernel behavior and what I've been
told about it implies that it is not sufficient for your application to
perfectly coordinate locking, writes, fsync(), and fstat() visibility
of the resulting changes through its own mechanism; you must do your
locking through the officially approved kernel channels (and it is not
clear what they are) or see potentially incorrect results.

 Consider a system where reads and writes to a shared file are
coordinated by a central process that everyone communicates with through
TCP connections. The central process pauses readers before it allows
a writer to start, the writer always fsync()s before it releases its
write permissions, and then no reader is permitted to proceed until the
entire cluster sees the same updated fstat() result. This is perfectly
coordinated but currently could see incorrect read() results, and I've
been told that this is allowed under Linux's CTO rules because all of
the processes hold the file open read-write through this entire process
(and no one flock()s).

	- cks
