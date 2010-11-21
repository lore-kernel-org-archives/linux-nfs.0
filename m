Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45676 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755218Ab0KUUCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 15:02:05 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Moazam Raja <moazam@gmail.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20101121104624.GA13874@infradead.org>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
	 <1290194699.3135.49.camel@heimdal.trondhjem.org>
	 <20101119200421.GA3143@fieldses.org>
	 <1290201995.3135.63.camel@heimdal.trondhjem.org>
	 <20101121104624.GA13874@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 21 Nov 2010 15:01:55 -0500
Message-ID: <1290369715.5481.26.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-11-21 at 05:46 -0500, Christoph Hellwig wrote:
> On Fri, Nov 19, 2010 at 04:26:35PM -0500, Trond Myklebust wrote:
> > If the application requests O_DIRECT/O_SYNC or calls fsync(), we are
> > required by POSIX to ensure the data is safe on disk. The presence of an
> > NFS delegation does not change that requirement.
> 
> That's not quite correct.  O_DIRECT for one is not actually specific in
> Posix at all, and the documented Linux semantics only say that the
> pagecache should not be used (even if it sometimes is with various
> filesystems).  There is not guarantee that data actually is on disk or
> reachable, for that you need to add the O_SYNC/O_DYSNC flag in addition
> or use fsync/fdatasync.

True.

We treat the O_DIRECT case as being the same as O_DIRECT|O_SYNC because
we don't currently have a way to locate and track outstanding O_DIRECT
rpc calls, and so fsync() has no effect.

We do, however support aio/dio, and so people who want better writev()
syscall latency can use that...

Cheers
  Trond

