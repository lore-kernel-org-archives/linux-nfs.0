From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH/RFC] Return ENOSPC and EDQUOT for nfs writes
	earlier.
Date: Thu, 12 Jul 2007 16:31:36 -0400
Message-ID: <1184272296.30876.159.camel@heimdal.trondhjem.org>
References: <18069.29184.792156.782358@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I95KD-0000rN-GZ
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 13:31:45 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+EUh0Au+fofJb4C+yIOh0En6EGMA6r6+A=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I95KE-0003mA-JK
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 13:31:48 -0700
In-Reply-To: <18069.29184.792156.782358@notabene.brown>
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

On Thu, 2007-07-12 at 10:12 +1000, Neil Brown wrote:
> When a write to a local filesystem hits a space limitation such as
> filesystem-full or quota-exhausted, the write fails synchronously.
> You get ENOSPC or EDQUOT immediately.
> 
> NFS cannot do that efficiently.
> 
> Currently, you don't get these errors until 'fsync' or 'close'.  That
> is very different from local filesystem behaviour, and is less than
> ideal.
> 
> The following patch causes these two errors to be returned through the
> next write call once they are known about.
> 
> A possible extension would be to set a flag when we first get such an
> error, clear it when a write succeeds, and while the flag is set, do
> all writes synchronously.  This would be even closer to
> local-filesystem semantics, but I'm not sure it is worth it.

Well... I've been thinking along these last lines myself (i.e. forcing
all subsequent writes to be synchronous whenever an error occurs).

My main worry is actually rather about returning the error value. The
point is that you are returning an error that probably isn't relevant to
the write() system call that you are servicing. In fact the write
syscall that returns the error may actually succeed in writing all its
data to stable storage. Under those circumstances, I'm not sure that
returning an error at all is a good idea. 
BTW, I absolutely _loathe_ the mapping->flags AS_EIO and AS_ENOSPC hack.
In that case you are returning the error to a random process that just
happened to complete wait_on_page_writeback_range() before all the other
processes that called it did.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
