From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sun, 05 Sep 2004 16:10:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094415006.8081.6.camel@lade.trondhjem.org>
References: <chdp06$e56$1@sea.gmane.org>
	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>
	 <1094349744.13791.128.camel@lade.trondhjem.org>  <413A789C.9000501@upb.de>
	 <1094353267.13791.156.camel@lade.trondhjem.org>  <413B121B.2070101@upb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C43LA-0003Qd-Ns
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 13:10:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C43L8-0004qQ-0k
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 13:10:20 -0700
To: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>
In-Reply-To: <413B121B.2070101@upb.de>
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

P=E5 su , 05/09/2004 klokka 09:18, skreiv Sven K=F6hler:

> So there should be a filesystem mounted to /proc/fs/nfsd? This isn't the=20
> case on my machine. Should the init-script do a simple "mount -t nfsd=20
> none /proc/fs/nfsd"? Than this would be a Bug of my distribution (Gentoo)=
.

Yes... See the manpage for "exportfs".

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
