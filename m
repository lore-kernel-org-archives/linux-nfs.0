From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 2.6.5 NFS ready for production?
Date: Mon, 26 Apr 2004 11:27:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DF67@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIAp5-0006KY-6j
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 11:27:19 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIAp4-00049u-UX
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 11:27:18 -0700
To: "Erik Walthinsen" <omega@pdxcolo.net>
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

have you looked into why ttcp gets only 18MB/sec?


> -----Original Message-----
> From: Erik Walthinsen [mailto:omega@pdxcolo.net]=20
> Sent: Monday, April 26, 2004 1:38 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] 2.6.5 NFS ready for production?
>=20
>=20
> I'm trying to decide whether or not to even contemplate=20
> putting 2.6.5 on our NAS server (single 2.4GHz Xeon, 512MB,=20
> 4x 200GB SATA on 3ware) to gain the various I/O scheduling=20
> improvements, but obviously whether it's even remotely=20
> possible depends primarily on whether NFS is up to it.
>=20
> I have stock 2.6.5 on a test machine, and am getting *well*=20
> under 1MB/sec with bonnie++ over NFS on Gigabit (ttcp gets=20
> 18MB/sec, no jumbo frames), compared to 20+MB/sec local=20
> (single old ATA disk).  Haven't tried to pin down what=20
> precisely is causing the issue, but it begs the
> question: should I even be considering 2.6's NFS as=20
> production-capable yet?
>=20
> TIA,
>=20
> - Omega
>   aka Erik Walthinsen
>   omega@pdxcolo.net
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: The Robotic Monkeys at=20
> ThinkGeek For a limited time only, get FREE Ground shipping=20
> on all orders of $35 or more. Hurry up and shop folks, this=20
> offer expires April 30th!=20
> http://www.thinkgeek.com/freeshipping/?cpg=3D> 12297
>=20
> _______________________________________________
> NFS=20
> maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
