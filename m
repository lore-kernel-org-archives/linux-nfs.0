From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 18:30:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094682603.8363.71.camel@lade.trondhjem.org>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
	 <1094662327.9493.42.camel@lade.trondhjem.org> <413F5127.5030008@bluewin.ch>
	 <1094673208.8363.21.camel@lade.trondhjem.org> <413F668D.4060601@bluewin.ch>
	 <1094676419.8363.42.camel@lade.trondhjem.org> <413F7EF6.9050005@bluewin.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5AxF-0003Jz-Mz
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 15:30:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5AxC-0006Mf-Tk
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 15:30:17 -0700
To: Bernd Nies <bnies@bluewin.ch>
In-Reply-To: <413F7EF6.9050005@bluewin.ch>
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

P=E5 on , 08/09/2004 klokka 17:51, skreiv Bernd Nies:
> OK, right. I tracked down one incident captured here:
>=20
> http://www.nies.ch/download/apple-nfs-loop-1dir.dump.gz
>=20
> A READDIRPLUS reports a directory entry "." with cookie 276 (Frame 157)=20
> and the next READDIRPLUS reports a file "package-use.html" with same=20
> cookie 276 (Frame 161). This is WRONG by the server, right?
>=20
> But why is it working then without problems on a Solaris NFS client?

They probably do not rely exclusively on the cookie to track where they
are in the READDIR stream: for instance it is possible to cache the
filename too, and to use that as a backup solution if the server is
being cranky.
We could possibly add this sort of information to Linux too.

Note though, this scheme fails for the case where the user wants to use
telldir()/seekdir(), so if you have an older glibc that uses the
horrible heuristic algorithm, you will still see odd behaviour.
More obviously: it also breaks down if the filename you cached was one
of the entries that got deleted...

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
