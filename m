From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Sat, 26 Oct 2002 12:11:50 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021026.121150.74753877.taka@valinux.co.jp>
References: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
	<15801.15328.866301.720864@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185HU4-0006eb-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 20:19:32 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15801.15328.866301.720864@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello

> > > I have been thinking some more about this, trying to understand the
> > > big picture, and I'm afraid that I think I want some more changes.
> > > 
> > > In particular, I think it would be good to use 'struct xdr_buf' from
> > > sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
> > > we could share some of the infrastructure.
> > 
> > I just realized it would be hard to use the xdr_buf as it couldn't
> > handle data in a socket buffer. Each socket burfer consists of
> > some non-page data and some pages and each of them might have its
> > own offset and length.
> 
> You would only want this for single-copy write request  - right?

Yes.

> I think we have treat them as a special case and pass the skbuf all
> the way up to nfsd in that case.
> You would only want to try this if:
>    The NIC had verified the checksum
>    The packets was some minimum size (1K? 1 PAGE ??)
>    We were using AUTH_UNIX, nothing more interesting like crypto
>      security
>    The first fragment were some minimum size (size of a write without
>    the data).
> 
> I would make a special 'fast-path' for that case which didn't copy any
> data but passed a skbuf up, and code in nfs*xdr.c would convert that
> into an iovec[];

I implemented that only sunrpc layer could handle a skbuff and
made nfsd layer keep away from its implementation. I felt this approach
was not bad.

Yes, your approach is also good and will work fine.

> I am working on a patch which changes rpcsvc to use xdr_buf.  Some of
> it works.  Some doesn't.  I include it below for your reference I
> repeat: it doesn't work yet.  
> Once it is done, adding the rest of zero-copy should be fairly easy.

OK.

It's goot that you're implementing vfs_readv and vfs_writev which
I've also realized it doesn't support aio yet.


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
