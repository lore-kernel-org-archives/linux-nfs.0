From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client does not report accurate mtime when mtime is 0
Date: Mon, 14 Jun 2004 13:48:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087235299.3936.20.camel@lade.trondhjem.org>
References: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BZvZG-0001po-NJ
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 10:48:22 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BZvZG-0002gz-Af
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 10:48:22 -0700
To: Daniel Forrest <forrest@lmcg.wisc.edu>
In-Reply-To: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
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

P=E5 m=E5 , 14/06/2004 klokka 12:57, skreiv Daniel Forrest:
> I am wondering if this is a known bug and what Linux versions are
> affected by it.  Or if it might be a Red Hat only bug.
>=20
> I am using utimes() to set the atime/mtime of a file to 0 (i.e. the
> start of the Epoch).

So are you doing this on the server or on the client? If the former,
then you shouldn't expect any updates to atime/mtime to be registered
until the attribute cache has expired on the client (see "man 5 nfs" for
a description of the mount options that control the length of the cache
timeout).

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
