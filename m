From: John Sutton <john@scl.co.uk>
Subject: Re: Linux: nfsroot and a Tulip card
Date: Mon, 7 Jul 2003 13:31:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <03070713384502.00985@diva.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.scl.co.uk ([80.71.1.205] helo=sparta.scl.co.uk)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ZVFo-0007Pq-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Jul 2003 05:38:00 -0700
To: ryurick.hristev@canterbury.ac.nz
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

Hi Ryurick

Did you ever get this problem sorted out?  I've got exactly the same
problem and like you have run out of any ideas!

Any help you can give me will be much appreciated.

TIA
John Sutton

> Hello,
>=20
> After a prolonged mucking around I am finally out of any idea.
>=20
> I have a problem:
>=20
> I have a Linux based PC with a Tulip type network card which refuses
> to read the root filesystem over nfs.
>=20
> Given that the card have to be DHCP configured the network driver
> is compiled into the kernel. The system boots, it gets configured
> via DHCP, mounts the root via nfs (as shown by the logs) then hangs.=20
>=20
> I have other systems with different network cards which do work
> with the same setup. The system also works with Linux 2.2 but not 2.4
>=20
> The tulip driver in Linux kernel 2.4 appears to be FUBAR so I used
> the de4x5 which apparently works up to reading the nfsroot
> (IIRC that was recommended by someone on the tulip driver mailing list)=
=2E
>=20
> TIA for any pointers, ideas, etc,
>=20
> Cheers,
> --=20
> Ryurick M. Hristev mailto:r.hristev@ph...
> Computer Systems Manager
> University of Canterbury, Physics & Astronomy Dept., New Zealand
--=20

***************************************************
John Sutton
SCL Internet
URL http://www.scl.co.uk/
Tel. +44 (0) 1239 711 888
***************************************************


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
