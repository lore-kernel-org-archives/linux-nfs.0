From: Juergen Sauer <jojo@automatix.de>
Subject: Re: XFS NFS Fileserver, kernel: nfs: server server not responding, still trying
Date: Sat, 8 Nov 2003 09:46:19 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311080946.19910.jojo@automatix.de>
References: <482A3FA0050D21419C269D13989C6113020AC67A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AIOrP-0008Px-00
	for <nfs@lists.sourceforge.net>; Sat, 08 Nov 2003 00:54:23 -0800
Received: from 237.230.131.213.rev.inetbone.net ([213.131.230.237] helo=mail.automatix.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AIOrP-00079E-2O
	for nfs@lists.sourceforge.net; Sat, 08 Nov 2003 00:54:23 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1AIOrN-0007G9-00
	for nfs@lists.sourceforge.net; Sat, 08 Nov 2003 09:54:21 +0100
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113020AC67A@lavender-fe.eng.netapp.com>
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

Am Freitag, 7. November 2003 19:01 schrieb Lever, Charles:
> have you tried with NFS over TCP?  you may have a
> network problem which prevents NFS over UDP from
> working efficiently.
Not yet.
In Server/Client-Kernel 2.4.20-xfs was all fine,
In 2.4.22-xfs on the Server and on the Client the horror began.

On the Client 2.4.22-xfs is nessesary because of Hardware forced.
The Server is already back on 2.4.20-xfs, like in other posts on the
List described.

mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/rK1bW7UKI9EqarERAk2CAJ0U6S8uLo4ezShPBtix50VZhUxtHQCg0doh
6CW2mjJfZuopNUHo+Obt7WQ=3D
=3DhKG5
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
