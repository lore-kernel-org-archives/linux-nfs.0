From: Juergen Sauer <jojo@automatix.de>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 11:11:49 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311281111.49153.jojo@automatix.de>
References: <1069934421.4677.77.camel@wibbit.firebox.com> <200311280946.06755.jojo@automatix.de> <1070012227.3615.7.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APfnL-00011N-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 02:24:15 -0800
Received: from 237.230.131.213.rev.inetbone.net ([213.131.230.237] helo=mail.automatix.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APfnL-0006Mo-Eo
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 02:24:15 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1APfnL-0001vN-00
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 11:24:15 +0100
To: Douglas Furlong <douglas.furlong@firebox.com>,
 nfs@lists.sourceforge.net
In-Reply-To: <1070012227.3615.7.camel@wibbit.firebox.com>
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

Am Freitag, 28. November 2003 10:37 schrieb Douglas Furlong:
MKoin doug,

> I do indeed have an nvidia card in the machine which is a nVidia
> Corporation NV11 [GeForce2 MX/MX 400] (rev b2).
=20
> However on an lsmod the nv.o driver is not being loaded (the machine
> goes to run level 3 not 5.
Is the kernel module "nvidia" loaded ?
Mathew McNally reported the same thing, problems with Nvidia Graphic distur=
bs
NFS/Network.

Perhaps I should be more exactly, my client here has an ASUS A7N8X
board. This have Nvidia NFORCE2 Chipset, Nvidia Network Chip,=20
and a AGP-Nvidia Gforce 4X Card.
Using 2.4.18-XFS all is fine, except the speed of the IDE System,
Using 2.4.22-XFS mostly IDE Speed is fine, System runs fine,=20
except "NFS Server not responding", those errors are fast comming and
going. nfsstat shows a lot of retrans.

> Am I right in saying this should mean the problem does not exist?
The Problem exists - definitely.
But it's possible to configure that it does not hurt too much, by lowering
rsize=3D4096,wsize=3D4096 I got a compromise between speed and "NFS server =
=2E..".

I think the only solution is to send bugreports to NVIDIA.
(Shit closed source, in OSS we had already fixed this junk).
=20
> I will go and have a look at those archives (only been on the list for a
> week).

mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/xx9lW7UKI9EqarERApFLAKCFe23cAKIQ4uKMKXf5jP2WkAEXMACgs55Z
X3UtibcJjpctpqhjDlwyaU8=3D
=3DIyCZ
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
