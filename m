From: Juergen Sauer <jojo@automatix.de>
Subject: Re: XFS NFS Fileserver, kernel: nfs: server server not responding, still trying
Date: Sat, 8 Nov 2003 09:42:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311080942.38726.jojo@automatix.de>
References: <Pine.LNX.4.44.0311071830050.25909-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AIOrP-0008Pw-00
	for <nfs@lists.sourceforge.net>; Sat, 08 Nov 2003 00:54:23 -0800
Received: from 237.230.131.213.rev.inetbone.net ([213.131.230.237] helo=mail.automatix.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AIOrP-00079D-04
	for nfs@lists.sourceforge.net; Sat, 08 Nov 2003 00:54:23 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1AIOrN-0007G5-00
	for nfs@lists.sourceforge.net; Sat, 08 Nov 2003 09:54:21 +0100
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0311071830050.25909-100000@kenzo.iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am Freitag, 7. November 2003 18:34 schrieb Bogdan Costescu:
> On Fri, 7 Nov 2003, Juergen Sauer wrote:
=20
> > calls      retrans    authrefrsh
> > 1483912    21137      0
> > ...
> > calls      retrans    authrefrsh
> > 1752966    23343      0
=20
> The number of "retrans" is pretty high...
That's it. ;-<
=20
> > ...rsize=3D32768,wsize=3D32768...
I moved to lower and higher values. Including 8192, 4096, 1024

> ... and I think that this is the problem. Try lowering the sizes to=20
> something more closely matched to the network that you are using, like 8k=
=20
> or even lower. Although you said that you followed the NFS FAQ ???
Yepp, I did the posting after the behavior changed dramatically in
2.4.22-xfs against 2.4.20-xfs.

Thanks so far.

mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/rKx+W7UKI9EqarERAmMRAJ4/6UAWEYKv8uBlg1fJvHm7ke6WjgCgyasV
IqQbGyhZssyB+t/Ih+1s3HQ=3D
=3DVVtv
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
