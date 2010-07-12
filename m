Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38858 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359Ab0GLO3V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 10:29:21 -0400
Subject: Re: nfs_wb_all
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100711191451.GA13319@infradead.org>
References: <20100711191451.GA13319@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Jul 2010 10:28:21 -0400
Message-ID: <1278944901.2840.44.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-07-11 at 15:14 -0400, Christoph Hellwig wrote:
> nfs_wb_all is the only caller of sync_inode which does not set
> nr_to_write to 0, that is the only one actually using it to write out
> file data.
> 
> Now looking at the callers I'm not sure this actually is intended:

The intention is that nfs_wb_all() should do a full data integrity sync.

>  - nfs_msync_inode does a filemap_fdatawrite before and a
>    filemap_fdatawait after the call to nfs_wb_all, o the data writing
>    happens twice here, although it probably really should be a
>    filemap_write_and_wait before the call to sync_inode

nfs_msync_inode() should just be replaced with a single call to
nfs_wb_all().

>  - nfs_rename doesn't write data next to it. Then again writing out data
>    here from sync_inode probably isn't intentional either.

The call to nfs_wb_all() in nfs_rename() should probably be removed. It
was put in there because some (broken!) nfs servers don't preserve
filehandles across renames. On a compliant nfs server, we shouldn't have
to worry about that.

>  - nfs_do_fsync already has the data written back from vfs_fsync if
>    called though ->fsync although a data write is needed for the call
>    from ->flush and O_SYNC handling, although the latter should probably
>    be switched to use generic_write_sync

There is one special case that generic_write_sync() won't catch: when
the writeback code hits an error condition, we try to switch the writes
to synchronous mode until the error clears. It is mainly in order to
deal with temporary problems such as ENOSPC on the server.

So we can probably replace that call to nfs_wb_all() with a call to
nfs_commit_inode(), and then replace the calls to nfs_do_fsync() in
nfs_file_write() and nfs_file_splice_write() with calls to vfs_fsync().

>  - nfs_sync_mapping seems to actually want the data writeback
>  - nfs_setattr already does a filemap_write_and_wait just before the
>    call to nfs_wb_all

Again, we should just get rid of the filemap_write_and_wait().

Cheers
  Trond
