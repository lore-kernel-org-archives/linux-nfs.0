From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsprog support
Date: Thu, 15 Apr 2004 14:43:54 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082065434.7141.48.camel@lade.trondhjem.org>
References: <200404151750.53209.bernd-schubert@web.de>
	 <200404152040.06227.bernd-schubert@web.de>
	 <1082057977.7141.31.camel@lade.trondhjem.org>
	 <200404152331.47440.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFag0-0003C9-Ow
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 08:27:16 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BFag0-0003bH-Cv
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 08:27:16 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200404152331.47440.bernd-schubert@web.de>
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

P=E5 to , 15/04/2004 klokka 14:31, skreiv Bernd Schubert:

> as I wrote, we want to use NFSv3 for knfs and userspace nfs, just take a=20
> look at the following rpcinfo tables:
>=20

What you are describing sounds like a bug in "mount". In the case where
the user specifies both "port" and "nfsvers", there is no need
whatsoever to consult the portmapper.

I just do not see this as a kernel bug, or as any form of justification
for adding support for the nfsprog hack.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
