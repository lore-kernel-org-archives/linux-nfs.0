Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:41750 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727278AbeIPAbF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Sep 2018 20:31:05 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Jeff Layton <jlayton@redhat.com>
cc: Chris Siebenmann <cks@cs.toronto.edu>, linux-nfs@vger.kernel.org
Subject: Re: Correctly understanding Linux's close-to-open consistency
In-reply-to: Your message of Sat, 15 Sep 2018 12:20:06 -0400.
             <19e995d2233282dcfd636a62d16ebe9f3b8d6166.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sat, 15 Sep 2018 15:11:02 -0400
Message-Id: <20180915191102.EC92232257C@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, 2018-09-12 at 21:24 -0400, Chris Siebenmann wrote:
> >  Is it correct to say that when writing data to NFS files, the only
> > sequence of operations that Linux NFS clients officially support is
> > the following:
> > 
> > - all processes on all client machines close() the file
> > - one machine (a client or the fileserver) opens() the file, writes
> >   to it, and close()s again
> > - processes on client machines can now open() the file again for
> >   reading
>
> No.
>
> One can always call fsync() to force data to be flushed to avoid the
> close of the write fd in this situation. That's really a more portable
> solution anyway. A local filesystem may not flush data to disk, on close
> (for instance) so calling fsync will ensure you rely less on filesystem
> implementation details.
>
> The separate open by the reader just helps ensure that the file's
> attributes are revalidated (so you can tell whether cached data you
> hold is still valid).

 This bit about the separate open doesn't seem to be the case
currently, and people here have asserted that it's not true in
general. Specifically, under some conditions *not involving you
writing*, if you do not close() the file before another machine writes
to it and then open() it afterward, the kernel may retain cached data
that it is in a position to know (for sure) is invalid because it didn't
exist in the previous version of the file (as it was past the end of
file position).

 Since failing to close() before another machine open()s puts you
outside this outline of close-to-open, this kernel behavior is not a
bug as such (or so it's been explained to me here).  If you go outside
c-t-o, the kernel is free to do whatever it finds most convenient, and
what it found most convenient was to not bother invalidating some cached
page data even though it saw a GETATTR change.

 It may be that I'm not fully understanding how you mean 'revalidated'
here. Is it that the kernel does not necessarily bother (re)checking
some internal things (such as cached pages) even when it has new GETATTR
results, until you do certain operations?

 As far as the writer using fsync() instead of close(): under this
model, the writer must close() if there are ever going to be writers
on another machine and readers on its machine (including itself),
because otherwise it (and they) will be in the 'reader' position here,
and in violation of the outline, and so their client kernel is free to
do odd things. (This is a basic model that ignores how NFS locks might
interact with things.)

> If you use file locking (flock() or POSIX locks), then we treat
> those as cache coherency points as well. The client will write back
> cached data to the server prior to releasing a lock, and revalidate
> attributes (and thus the local cache) after acquiring one.

 The client currently appears to do more than re-check attributes,
at least in one sense of 'revalidate'. In some cases, flock() will
cause the client to flush cached data that it would otherwise return and
apparently considered valid, even though GETATTR results from the server
didn't change. I'm curious if this is guaranteed behavior, or simply
'it works today'.

(If by 'revalidate attributes' you mean that the kernel internally
revalidates some cached data that it didn't bother revalidating before,
then that would match observed behavior. As an outside user of NFS,
I find this confusing terminology, though, as the kernel clearly has
new GETATTR results.)

 Specifically, consider the sequence:

	client A			fileserver
	open file read-write
	read through end of file
1	go idle, but don't close file
2					open file, append data, close, sync

3	remain idle until fstat() shows st_size has grown

4	optional: close and re-open file
5	optional: flock()

6	read from old EOF to new EOF

Today, if you leave out #5, at #6 client A will read some zero bytes
instead of actual file content (whether or not you did #4). If you
include #5, it will not (again whether or not you did #4).

Under my outline in my original email, client A is behaving outside
of close to open consistency because it has not closed the file before
the fileserver wrote to it and opened it afterward. At point #3, in some
sense the client clearly knows that file attributes have changed, because
fstat() results have changed (showing a new, larger file size among other
things), but because we went outside the guaranteed behavior the kernel
doesn't have to care completely; it retains a cached partial page at the
old end of file and returns this data to us at step #6 (if we skip #5).

The file attributes obtained from the NFS server don't change between
#3, #4, and #5, but if we do #5, today the kernel does something with
the cached partial page that causes it to return real data at #6. This
doesn't happen with just #4, but under my outlined rules that's acceptable
because we violated c-t-o by closing the file only after it had been
changed elsewhere and so the kernel isn't obliged to do the magic that
it does for #5.

(In fact it is possible to read zero bytes before #5 and read good data
afterward, including in a different program.)

	- cks
