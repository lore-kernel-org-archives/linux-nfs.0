From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 12:52:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094662327.9493.42.camel@lade.trondhjem.org>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C55gC-0004nH-V3
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 09:52:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C55gC-0008GV-3X
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 09:52:20 -0700
To: bnies@bluewin.ch
In-Reply-To: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
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

P=E5 on , 08/09/2004 klokka 04:42, skreiv bnies@bluewin.ch:

> Martin Algesten reported that this might be caused by non-unique NFS cook=
ies
> in the same READDIRPLUS reply from the Apple NFS server but in our enviro=
nment
> with MacOS X 10.3.5 and SuSE Linux 9.0 (Kernel 2.4.21-243-smp4G, glibc-2.=
3.2-88)
> I cannot confirm this. The NFS cookies are unique in the same READDIRPLUS
> reply but not unique during the same NFS session.
>=20

What does this mean? That 2 different READDIRPLUS entries for the same
directory may return the same cookie? That would a server bug...

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
