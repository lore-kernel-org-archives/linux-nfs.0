From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: chmod 1777 not working
Date: Thu, 19 Aug 2004 10:28:01 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092925681.3810.14.camel@lade.trondhjem.org>
References: <20040819135117.GA18593@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bxnte-0004R2-SG
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 07:28:06 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bxntd-0007nP-Gp
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 07:28:06 -0700
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040819135117.GA18593@janus>
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

P=E5 to , 19/08/2004 klokka 09:51, skreiv Frank van Maarseveen:
> NFSv3, UDP.
> client: 2.4.27 (RH9)
>=20
> in a directory mounted from a HP OSF1 V5.1 1885 alpha server:
>=20
> $ chmod 1777 .
> $ chmod: changing permissions of `.' (requested: 1777, actual: 0777): Ope=
ration not permitted.
>=20
> It did change the mode bits masked by 0777 however. Only the 01000 bit
> didn't come through.

Works for me against both Linux servers and a filer. This looks like an
OSF1 bug...

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
