From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 20:43:41 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083285820.14910.77.camel@lade.trondhjem.org>
References: <20040429144012.GA15361@suse.de>
	 <1083257096.3686.27.camel@lade.trondhjem.org>
	 <20040429165802.GA18748@suse.de>
	 <1083258570.3686.38.camel@lade.trondhjem.org>
	 <20040429235018.GC4843@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJM83-0003JN-Q8
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 17:43:47 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJM83-0000zO-GF
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 17:43:47 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040429235018.GC4843@sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2004-04-29 at 19:50, Greg Banks wrote:
> > The ERRORS section lists the errors returned for specific types of
> > failures. These lists are not intended to be the definitive statement
> > of all of the errors which can be returned by any specific procedure,
> > but as a guide for the more common errors which may be returned.
> 
> This has been interpreted in discussions here as a loophole that allows
> the server to return any of the defined NFS errors for any of the calls
> at its discretion.

True, and indeed I should have known that.

Note for instance that the error NFS3ERR_JUKEBOX is not listed as a
return value for any of the procedures: I'm sure that it would come as a
surprise to most server implementors if you were to disallow its use
solely on those grounds.

> I don't know why the server returns NFSERR_STALE instead of NFSERR_ACCES,
> but RFC compliance is not a good reason.

Right. It is quite simply a bug...

NFS3ERR_STALE can be returned if the server unexports the filesystem
("revokes access") but here we are talking about a pure credential-based
access check, and so NFS3ERR_ACCES is the correct return value.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
