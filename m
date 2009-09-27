From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_file_fsync question
Date: Sun, 27 Sep 2009 18:02:20 -0400
Message-ID: <1254088940.4041.15.camel@heimdal.trondhjem.org>
References: <20090926171851.GA16056@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57282 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbZI0WCU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Sep 2009 18:02:20 -0400
In-Reply-To: <20090926171851.GA16056@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-09-26 at 13:18 -0400, Christoph Hellwig wrote:
> Can anyone explain what nfs_do_fsync/nfs_wb_all is trying to do?

nfs_do_fsync() is trying to ensure that if we start seeing errors on
asynchronous writebacks, then we

  a) report those errors to userland asap.
  b) fall back to synchronous writes until the error condition clears.

> We use it for two cases:  either implementing ->fsync or the O_SYNC
> implementation in ->aio_write/->splice_write.
> 
> But vfs_fsync_range which is used both by the fsync implementation and
> called from generic_file_aio_write / generic_file_splice_write alread
> y writes out all data and handles errors from it, so ->fsync does not
> need to bother with data at all.  nfs_wb_all seems like a
> re-implmenetation of the generic page flushing helpers in filemap.c
> and not actually touch metadata.  So this code seems useless for the
> fsync and O_SYNC cases and only useful for the error catching.  Which
> we already do slightly different at VFS-level.  Any reasons to keep
> all this cruft around instead of properly integrating it with the
> VFS-level error reporting?

The VFS only covers 2 possible errors: EIO and ENOSPC. In NFS there are
a whole raft of other errors that can occur, and that we'd like to
report to userspace: e.g. authentication errors (EACCES or EROFS),
ESTALE, quota errors, ...

The other thing that nfs_wb_all() does, that is not covered by the VFS
is ensuring that the COMMIT gets sent, in order to ensure that the data
is physically flushed to disk on the server.

Cheers
  Trond

