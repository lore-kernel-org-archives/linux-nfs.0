From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Does nfsd.o handle overwriting of files properly?
Date: Fri, 13 Aug 2004 12:06:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092413192.5046.12.camel@lade.trondhjem.org>
References: <200408130904.26180.perbu@linpro.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BveZf-00024a-5K
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:06:35 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BveZe-0002Bl-QB
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:06:35 -0700
To: Per Buer <perbu@linpro.no>
In-Reply-To: <200408130904.26180.perbu@linpro.no>
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

P=E5 fr , 13/08/2004 klokka 03:04, skreiv Per Buer:
> Hi.
>=20
> We have a daemon which does the following. Create a new file "foo" and re=
names=20
> this file to "bar". This happens on a nfs volume. The problem seems to be=
=20
> that we get "stale NFS handle" right after "bar" is overwritten.
>=20

That is fully expected behaviour for NFS. All implementations will do
the same thing, be it Solaris, Linux, IRIX,...

If you want the old file to be accessible, then the only workaround is
to rename it instead of deleting it (and that is precisely what most NFS
clients will do if you try to remove a file that is still held open by a
process on that client).

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
