From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Solaris NFS server and Linux Client.
Date: Mon, 14 Jun 2004 21:54:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087264465.3894.58.camel@lade.trondhjem.org>
References: <200406142347.i5ENlAMD005798@lodur.srl.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba39f-0006DP-0O
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 18:54:27 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Ba39e-0007aD-KR
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 18:54:26 -0700
To: Minerva Calderon <mc@srl.caltech.edu>
In-Reply-To: <200406142347.i5ENlAMD005798@lodur.srl.caltech.edu>
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

P=E5 m=E5 , 14/06/2004 klokka 19:47, skreiv Minerva Calderon:
>=20
> I have a 3.0TB partition on a Solaris 9.0 server which is NFS mounted on
> a Linux 7.2 client. When processing on the linux clients old directories
> on these partition dissapear.  The directories can be listed on the serve=
r.
> When the job is reran on the client after failure the directories appear
> again.

So, exactly what is a Linux 7.2 client? ;-)


I assume you mean RedHat Linux 7.2, but they have a variety of errata
kernels. Depending on how well you've kept up with the patches, you
could have anything from a 2.4.9 kernel to a patched 2.4.20. "uname -a"
should help clarify which...

My other question is what you mean by "old directories"? Are they
directories that have been removed on the server?

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
