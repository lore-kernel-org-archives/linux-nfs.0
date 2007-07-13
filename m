From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH/RFC] Return ENOSPC and EDQUOT for nfs writes
	earlier.
Date: Fri, 13 Jul 2007 10:01:53 +1000
Message-ID: <18070.49393.13232.932323@notabene.brown>
References: <18069.29184.792156.782358@notabene.brown>
	<1184272296.30876.159.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I98bK-0005i9-7O
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 17:01:38 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I98bM-0007OH-VZ
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 17:01:41 -0700
In-Reply-To: message from Trond Myklebust on Thursday July 12
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday July 12, trond.myklebust@fys.uio.no wrote:
> On Thu, 2007-07-12 at 10:12 +1000, Neil Brown wrote:
> > When a write to a local filesystem hits a space limitation such as
> > filesystem-full or quota-exhausted, the write fails synchronously.
> > You get ENOSPC or EDQUOT immediately.
> > 
> > NFS cannot do that efficiently.
> > 
> > Currently, you don't get these errors until 'fsync' or 'close'.  That
> > is very different from local filesystem behaviour, and is less than
> > ideal.
> > 
> > The following patch causes these two errors to be returned through the
> > next write call once they are known about.
> > 
> > A possible extension would be to set a flag when we first get such an
> > error, clear it when a write succeeds, and while the flag is set, do
> > all writes synchronously.  This would be even closer to
> > local-filesystem semantics, but I'm not sure it is worth it.
> 
> Well... I've been thinking along these last lines myself (i.e. forcing
> all subsequent writes to be synchronous whenever an error occurs).
> 
> My main worry is actually rather about returning the error value. The
> point is that you are returning an error that probably isn't relevant to
> the write() system call that you are servicing. In fact the write
> syscall that returns the error may actually succeed in writing all its
> data to stable storage. Under those circumstances, I'm not sure that
> returning an error at all is a good idea. 

Yes, I had those same thoughts, but decided that it wasn't really
worth worrying about.
If you want precise errors from writes, you really need to use O_SYNC,
or fsync when you really care.
And the nature of ENOSPC is that you could quite possibly get it once,
then try the same write again and it will succeed (if someone else
deleted a file).  So returning it here without even trying the write
isn't necessarily wrong.

On the other size of the coin, I looked briefly at switching to sync
writes, and it didn't look at all straight forward.  The awkwardness
is in switching from async to sync.  There are mismatched assumptions.

With O_SYNC, nfs_file_write always calls nfs_fsync, which will return
and clear ctx->error.  So any error from any preceding write will be
returned.  But that is OK - as the file is O_SYNC, all preceding
writes will have already returned their errors and anything in
ctx->error must be from this write (unless two process use pwrite to
write to different places of the same fd ...).

To do a single sync write we would need to:
  nfs_wb_all
  take a copy of ctx->error and clear it.
  submit the write
  nfs_wb_all
  copy the new ctx->error
  restore the saved ctx->error
  return the ctx->error relevant for this write.

Which seems rather clumsy and racy (though I guess we hold i_mutex, so
it is possibly safe).

So I went for the approach that was simplest....


> BTW, I absolutely _loathe_ the mapping->flags AS_EIO and AS_ENOSPC hack.
> In that case you are returning the error to a random process that just
> happened to complete wait_on_page_writeback_range() before all the other
> processes that called it did.

Hmmm... returning errors for async writes is something that the POSIX
API doesn't really support well.  The best you could hope for is that
if a write error occurs, then anyone who could have written to that
file gets an error on the next write, fsync, close, msync, ...
That would mean a counter in the address_space for each error,
and a matching counter in the struct file.
On open:  file->enospc_cnt = mapping->enospc_cnt
On fsync etc: 
          cnt = mapping->enospc_cnt;
	  if (file->enospc_cnt != cnt) {
		file->enospc_cnt = cnt;
		return -ENOSPC;
	  }

One counter each for EIO, ENOSPC, EDQUOT - I think that is all (I note
there is no AS_EDQUOT...).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
