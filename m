From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client does not report accurate mtime when mtime is 0
Date: Mon, 14 Jun 2004 19:53:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087257233.3894.45.camel@lade.trondhjem.org>
References: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
	 <16590.12362.453055.998493@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Daniel Forrest <forrest@lmcg.wisc.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba1H2-0003ch-KV
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:53:56 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Ba1H2-0001Ym-Ad
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:53:56 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16590.12362.453055.998493@cse.unsw.edu.au>
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

P=E5 m=E5 , 14/06/2004 klokka 19:10, skreiv Neil Brown:

> The simplest fix is probably to add:
>=20
> 	inode->i_mtime =3D 0;
>=20
> near the top of nfs_read_inode in fs/nfs/inode.c

Ah... That indeed looks plausible.

It's probably better to fix nfs_fill_inode() though. We want to make
sure it initializes all fields of the inode regardless of what checks
made by nfs_refresh_inode().

I'll code up a patch after dinner.

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
