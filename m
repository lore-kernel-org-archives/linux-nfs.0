From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: userspace NFS daemon
Date: Sun, 05 Sep 2004 18:10:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094422226.8081.51.camel@lade.trondhjem.org>
References: <20040905210902.GA29182@janus>
	 <1094419552.8081.33.camel@lade.trondhjem.org>
	 <20040905220120.GA29596@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C45DY-0003yI-LQ
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 15:10:36 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C45DY-0004ls-5M
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 15:10:36 -0700
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040905220120.GA29596@janus>
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

P=E5 su , 05/09/2004 klokka 18:01, skreiv Frank van Maarseveen:

> Anyway, I found this:
>=20
> 	http://clusternfs.sourceforge.net
>=20
> This is not supported by knfsd I think.

Wow. People would actually trust their root partition to unfsd? The mind
boggles...

Note: there is no reason why this couldn't be done for knfsd (or even
for local file accesses) using a stackable filesystem.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
