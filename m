Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw1-f66.google.com ([209.85.161.66]:42330 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728100AbeIPQXj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Sep 2018 12:23:39 -0400
Received: by mail-yw1-f66.google.com with SMTP id n207-v6so4364278ywn.9
        for <linux-nfs@vger.kernel.org>; Sun, 16 Sep 2018 04:01:05 -0700 (PDT)
Message-ID: <9401a43633d469bde6e4f842fd6175a9dcef9c7e.camel@redhat.com>
Subject: Re: Correctly understanding Linux's close-to-open consistency
From: Jeff Layton <jlayton@redhat.com>
To: Chris Siebenmann <cks@cs.toronto.edu>
Cc: linux-nfs@vger.kernel.org
Date: Sun, 16 Sep 2018 07:01:01 -0400
In-Reply-To: <20180915191102.EC92232257C@apps1.cs.toronto.edu>
References: <20180915191102.EC92232257C@apps1.cs.toronto.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2018-09-15 at 15:11 -0400, Chris Siebenmann wrote:
> > On Wed, 2018-09-12 at 21:24 -0400, Chris Siebenmann wrote:
> > >  Is it correct to say that when writing data to NFS files, the only
> > > sequence of operations that Linux NFS clients officially support is
> > > the following:
> > > 
> > > - all processes on all client machines close() the file
> > > - one machine (a client or the fileserver) opens() the file, writes
> > >   to it, and close()s again
> > > - processes on client machines can now open() the file again for
> > >   reading
> > 
> > No.
> > 
> > One can always call fsync() to force data to be flushed to avoid the
> > close of the write fd in this situation. That's really a more portable
> > solution anyway. A local filesystem may not flush data to disk, on close
> > (for instance) so calling fsync will ensure you rely less on filesystem
> > implementation details.
> > 
> > The separate open by the reader just helps ensure that the file's
> > attributes are revalidated (so you can tell whether cached data you
> > hold is still valid).
> 
>  This bit about the separate open doesn't seem to be the case
> currently, and people here have asserted that it's not true in
> general. Specifically, under some conditions *not involving you
> writing*, if you do not close() the file before another machine writes
> to it and then open() it afterward, the kernel may retain cached data
> that it is in a position to know (for sure) is invalid because it didn't
> exist in the previous version of the file (as it was past the end of
> file position).
>
>  Since failing to close() before another machine open()s puts you
> outside this outline of close-to-open, this kernel behavior is not a
> bug as such (or so it's been explained to me here).  If you go outside
> c-t-o, the kernel is free to do whatever it finds most convenient, and
> what it found most convenient was to not bother invalidating some cached
> page data even though it saw a GETATTR change.
> 

That would be a bug. If we have reason to believe the file has changed,
then we must invalidate the cache on the file prior to allowing a read
to proceed.

>  It may be that I'm not fully understanding how you mean 'revalidated'
> here. Is it that the kernel does not necessarily bother (re)checking
> some internal things (such as cached pages) even when it has new GETATTR
> results, until you do certain operations?
> 

Well, it'll generally mark the cache as being invalid (e.g.
NFS_INO_INVALID_DATA flag). Whether it purges the cache at that point is
a different matter. If we have writes cached, then we can't just drop
pages that have dirty data. They must be written back to the server
first.

Basically, if you don't take steps to serialize your I/O between hosts,
then your results may not be what you expect.

>  As far as the writer using fsync() instead of close(): under this
> model, the writer must close() if there are ever going to be writers
> on another machine and readers on its machine (including itself),
> because otherwise it (and they) will be in the 'reader' position here,
> and in violation of the outline, and so their client kernel is free to
> do odd things. (This is a basic model that ignores how NFS locks might
> interact with things.)
> 

A close() on NFS is basically doing fsync() and then close(), unless you
hold a write delegation, in which case it may not do the fsync since
it's not required.

> > If you use file locking (flock() or POSIX locks), then we treat
> > those as cache coherency points as well. The client will write back
> > cached data to the server prior to releasing a lock, and revalidate
> > attributes (and thus the local cache) after acquiring one.
> 
>  The client currently appears to do more than re-check attributes,
> at least in one sense of 'revalidate'. In some cases, flock() will
> cause the client to flush cached data that it would otherwise return and
> apparently considered valid, even though GETATTR results from the server
> didn't change. I'm curious if this is guaranteed behavior, or simply
> 'it works today'.
> 

You need to distinguish between two different cases in the cache here.
Pages can be dirty or clean. When I say flush here, I mean that it's
writing back dirty data. 

The client can decide to drop clean pages at any time. It doesn't need a
reason -- being low on memory is good enough.


> (If by 'revalidate attributes' you mean that the kernel internally
> revalidates some cached data that it didn't bother revalidating before,
> then that would match observed behavior. As an outside user of NFS,
> I find this confusing terminology, though, as the kernel clearly has
> new GETATTR results.)
> 
>  Specifically, consider the sequence:
> 
> 	client A			fileserver
> 	open file read-write
> 	read through end of file
> 1	go idle, but don't close file
> 2					open file, append data, close, sync
> 
> 3	remain idle until fstat() shows st_size has grown
> 
> 4	optional: close and re-open file
> 5	optional: flock()
> 
> 6	read from old EOF to new EOF
> 
> Today, if you leave out #5, at #6 client A will read some zero bytes
> instead of actual file content (whether or not you did #4). If you
> include #5, it will not (again whether or not you did #4).
> 
> Under my outline in my original email, client A is behaving outside
> of close to open consistency because it has not closed the file before
> the fileserver wrote to it and opened it afterward. At point #3, in some
> sense the client clearly knows that file attributes have changed, because
> fstat() results have changed (showing a new, larger file size among other
> things), but because we went outside the guaranteed behavior the kernel
> doesn't have to care completely; it retains a cached partial page at the
> old end of file and returns this data to us at step #6 (if we skip #5).
> 
> The file attributes obtained from the NFS server don't change between
> #3, #4, and #5, but if we do #5, today the kernel does something with
> the cached partial page that causes it to return real data at #6. This
> doesn't happen with just #4, but under my outlined rules that's acceptable
> because we violated c-t-o by closing the file only after it had been
> changed elsewhere and so the kernel isn't obliged to do the magic that
> it does for #5.
> 
> (In fact it is possible to read zero bytes before #5 and read good data
> afterward, including in a different program.)
> 
> 

Sure. As I said before, locking acts as cache coherency points. On
flock, we would revalidate the attributes so it would see the new size
and do reads like you'd expect.

As complicated as CTO sounds, it's actually relatively simple. When we
close a file, we flush any cached write data back to the server
(basically doing an fsync). When we open a file, we revalidate the
attributes to ensure that we know whether the cache is valid. We do
similar things with locking (releasing a lock flushes cached data, and
acquiring one revalidates attributes).

The client however is free to flush data at any time and fetch
attributes at any time. YMMV if changes happened to the file after you
locked or opened it, or if someone performs reads prior to your unlock
or close. If you want consistent reads and writes then you _must_ ensure
that the accesses are serialized. Usually that's done with locking but
it doesn't have to be if you can serialize open/close/fsync via other
mechanisms.

Basically, your assertion was that you _must_ open and close files in
order to get proper cache coherency between clients doing reads and
writes. That's simply not true if you use file locking. If you've found
cases where file locks are not protecting things as they should then
please do raise a bug report.

It's also not required to close the file that was open for write if you
do an fsync prior to the reader reopening the file. The close is
completely extraneous at that point since you know that writeback is
complete. The reopen for read in that case is only required in order to
ensure that the attrs are re-fetched prior to trusting the reader's
cache.

-- 
Jeff Layton <jlayton@redhat.com>
