From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: iostat wkB/s numbers during testing
Date: Fri, 14 Feb 2003 08:08:12 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D552E3@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jiO1-0002Uk-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 08:08:25 -0800
To: "Paul Heinlein" <heinlein@cse.ogi.edu>
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

hi paul-

you can check the list archives for more information,
but the experiences on this list have been that RAID
5 is generally not a hi-performance back-end solution
for Linux NFS servers.

i believe the problem is that NFS servers generate lots
of small writes, and that's something RAID 5 is not
very good at.

i can't answer your specific question about the numbers
you posted.  maybe someone else?

> -----Original Message-----
> From: Paul Heinlein [mailto:heinlein@cse.ogi.edu]=20
> Sent: Friday, February 14, 2003 10:32 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] iostat wkB/s numbers during testing
>=20
>=20
> I'm using a dual P-III Compaq DL380 running Red Hat 8.0 to=20
> host a new ATABoy RAID array purchased from Nexsan. It's=20
> connected to our switch via a gig/fiber card based on the=20
> Intel 82542 chipset.
>=20
> The service stack (for lack of a better phrase) is
>=20
> * ATABoy2 -- six-drive RAID-5 array that presents itself to the host=20
>              as a single SCSI device (no multiple LUNs)
> * LVM     -- 1.0.3, one PV, one VG, one LV (so far :-)
> * XFS     -- 1.2pre5
> * NFS     -- v2/v3, UDP only, 80 nfsd threads
> * Samba   -- 2.2.7
>=20
> Last night, I set up six NFS clients and one Linux/smbfs=20
> client to run=20
> iozone against the nfs mount/samba share.
>=20
> I was keeping track of stats using iostat -x on the server.=20
> My typical wkB/s numbers hovered in the 15000 to 19000 range.=20
> Is that sort of result set consistent with what any of you=20
> have seen for Linux-hosted=20
> NFS RAID exports?
>=20
> --Paul Heinlein <heinlein@cse.ogi.edu>
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.NET email is sponsored by: FREE  SSL Guide from=20
> Thawte are you planning your Web Server Security? Click here=20
> to get a FREE Thawte SSL guide and find the answers to all=20
> your  SSL security issues.=20
> http://ads.sourceforge.net/cgi-> bin/redirect.pl?thaw0026en
>=20
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
