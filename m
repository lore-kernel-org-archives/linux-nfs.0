From: Juergen Sauer <jojo@automatix.de>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 09:46:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311280946.06755.jojo@automatix.de>
References: <1069934421.4677.77.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APeOR-0003lG-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 00:54:27 -0800
Received: from 237.230.131.213.rev.inetbone.net ([213.131.230.237] helo=mail.automatix.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APeOQ-00044u-Uv
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 00:54:27 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1APeOK-0001eZ-00
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 09:54:20 +0100
To: Douglas Furlong <douglas.furlong@firebox.com>,
 nfs@lists.sourceforge.net
In-Reply-To: <1069934421.4677.77.camel@wibbit.firebox.com>
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

Am Donnerstag, 27. November 2003 13:00 schrieb Douglas Furlong:
> Good day all.
>=20
> I am running in to excessive amounts of NFS errors as below.
>=20
> kernel: nfs: server neon not responding, still trying
> kernel: nfs: server neon OK
>=20
> I was hoping that some of you may be able to provide me with some
> assistance.

Hight Doug, Hi Trond,

Is there any NVIDIA Stuff in the client/server ?
The Nvidia drivers vor the graphics and the nvidia netdrivers
are broken for 2.4.[20|21|22] !
The nv.o module for Xfree86 breaks IMHO the NFS.

I sent a bug report to the Nvidia maintainers.

Refer to the NFS Server not responding threads in the last month.

mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/xwtOW7UKI9EqarERAszVAKC8J1ljR66RKR3YAMQXBxdezNi6zwCbB/9H
Rgeni0oil7CgF+xDGRUn61s=3D
=3D3tlk
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
