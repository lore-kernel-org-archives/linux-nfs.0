From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: unexplained ESTALE
Date: Mon, 30 Aug 2004 19:07:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093907252.8729.150.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1vFP-0005LW-9Z
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 16:07:35 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1vFN-000616-Qm
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 16:07:35 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
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

P=E5 m=E5 , 30/08/2004 klokka 18:37, skreiv Ara.T.Howard:

> this is obviously for daemons for which it is impossible to have two copi=
es
> running simoultaneously.  i can't imagine that this has any affect whatso=
ever,
> i'm simply pointing out that this daemon will run for days on end without
> problem, and then exit suddenly with
>=20
>    no such file ESTALE /nfs/mounted/daemon
>=20
> showing up in the daemon.oe file.
>=20
> are there any conditions on client or server i should know about (besides=
 the
> obvious ones) that could cause this?

Which filesystem are they exporting?

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
