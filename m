From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client does not report accurate mtime when mtime is 0
Date: Mon, 14 Jun 2004 16:30:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087245051.3894.20.camel@lade.trondhjem.org>
References: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
	 <1087235299.3936.20.camel@lade.trondhjem.org>
	 <200406141941.i5EJfWM29182@rda07.lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BZy6Z-0004c5-9W
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 13:30:55 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BZy6Y-0001bg-Ua
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 13:30:55 -0700
To: Daniel Forrest <forrest@lmcg.wisc.edu>
In-Reply-To: <200406141941.i5EJfWM29182@rda07.lmcg.wisc.edu>
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

P=E5 m=E5 , 14/06/2004 klokka 15:41, skreiv Daniel Forrest:

> It doesn't matter where I set the atime/mtime from.
>=20
> Certain clients report an incorrect mtime regardless of how long it
> has been since the atime/mtime was set.

I'm unable to reproduce this on a 2.4.21 RHEL client. Ditto on both
stock 2.4.26-pre2 and 2.6.5 kernels from ftp.kernel.org.

Are you able to compile up a more recent 2.4.x kernel, to see if you can
reproduce the problem?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
