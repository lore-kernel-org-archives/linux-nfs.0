From: Juergen Sauer <jojo@automatix.de>
Subject: Solution/Work around: Re: XFS NFS Fileserver, kernel: nfs: server server not responding, still trying
Date: Tue, 11 Nov 2003 10:19:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311111019.12947.jojo@automatix.de>
References: <Pine.LNX.4.44.0311071830050.25909-100000@kenzo.iwr.uni-heidelberg.de> <200311080942.38726.jojo@automatix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJUl0-0002Sr-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Nov 2003 01:24:19 -0800
Received: from [213.131.230.237] (helo=mail.automatix.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AJUkz-00067z-Kw
	for nfs@lists.sourceforge.net; Tue, 11 Nov 2003 01:24:17 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1AJUky-000282-00
	for nfs@lists.sourceforge.net; Tue, 11 Nov 2003 10:24:16 +0100
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <200311080942.38726.jojo@automatix.de>
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

Am Samstag, 8. November 2003 09:42 schrieb Juergen Sauer:
> Am Freitag, 7. November 2003 18:34 schrieb Bogdan Costescu:
> > On Fri, 7 Nov 2003, Juergen Sauer wrote:
>=20
> > > calls      retrans    authrefrsh
> > > 1483912    21137      0
> > > ...
> > > calls      retrans    authrefrsh
> > > 1752966    23343      0
>=20
> > The number of "retrans" is pretty high...
> That's it. ;-<
>=20
> > > ...rsize=3D32768,wsize=3D32768...
> I moved to lower and higher values. Including 8192, 4096, 1024
>=20
> > ... and I think that this is the problem. Try lowering the sizes to
> > something more closely matched to the network that you are using, like =
8k
> > or even lower. Although you said that you followed the NFS FAQ ???
> Yepp, I did the posting after the behavior changed dramatically in
> 2.4.22-xfs against 2.4.20-xfs.

I found the reason for the troubles. ;-<<
The NVIDIA Networkdriver is buggy. I opend an incident on the NVIDIA Support
for it, it's the matter of the driver crew.

Meanvile work around is putting this into modules.conf:
options nvnet optimization=3D0 speed=3D2 duplex=3D1

optimization=3D0 -> No throughput "optimizsation"
speed=3D2 -> 100 Mbit/s
duplex=3D1 -> no Duplex

Never thought, that s driver bug could infect in Linux.
I am definitely used to get execllent drivers out of the kernel, from
the kernel crew. That are the free/GPLed drivers.

The closed source driver nvnet (Nvidia/Nforce2 Chipset) taints the kernel
and breaks the speed. In kernel 2.4.
There are only 3,33 MByte/sec left after those "optimazations".


mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/sKmQW7UKI9EqarERAkr/AJ9kpqxnfbjSv3K4SHaSu2R8a7iKpwCfYVTJ
VZCQZBdxUGZfRB9ZJIGBt04=3D
=3D1Q0w
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
