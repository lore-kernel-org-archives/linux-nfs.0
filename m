From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: processes stuck in D state
Date: Tue, 6 May 2003 08:18:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127478@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D4DC-0005at-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 08:18:34 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h46FIRFB011626
	for <nfs@lists.sourceforge.net>; Tue, 6 May 2003 08:18:27 -0700 (PDT)
Received: from black.eng.netapp.com (black.eng.netapp.com [10.56.10.24])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h46FIRln012835
	for <nfs@lists.sourceforge.net>; Tue, 6 May 2003 08:18:27 -0700 (PDT)
To: Michael Buesch <fsdeveloper@yahoo.de>
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

hi michael-

i'm not sure why you mailed neilb -- this appears to
be NFS client related, not server related.

can you spell out the sequence of events that leads
to the stuck processes?  it looks like the client
is working-as-designed, but if you can provide more
details, we can verify what's going on.

> -----Original Message-----
> From: Michael Buesch [mailto:fsdeveloper@yahoo.de]
> Sent: Tuesday, May 06, 2003 10:52 AM
> To: neilb@cse.unsw.edu.au
> Cc: nfs@lists.sourceforge.net
> Subject: [NFS] processes stuck in D state
>=20
>=20
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hi!
>=20
> Please take a look at this problem:
>=20
> [linux-kernel-mailing-list thread]
> http://marc.theaimsgroup.com/?t=3D98639966100003&r=3D1&w=3D2
>=20
> thanks.
> Please cc me, as I'm not subscribed to the nfs-list.
>=20
> - --=20
> Regards Michael B=FCsch
> http://www.8ung.at/tuxsoft
>  16:28:34 up 20 min,  1 user,  load average: 1.07, 0.97, 0.66
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.1 (GNU/Linux)
>=20
> iD8DBQE+t8wdoxoigfggmSgRAm5aAJsGJLPe9yUd4sqah4yiU0GsMIAGzACfSa2+
> gAMZvSHQirHmE8yZChpgH/8=3D
> =3Dpka2
> -----END PGP SIGNATURE-----
>=20
>=20
>=20
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux=20
> enterprise solutions
> www.enterpriselinuxforum.com
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
