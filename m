From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Intermittent RHE3-u3 client mount failures to Netapp fileserver
Date: Wed, 15 Dec 2004 08:47:20 -0800
Message-ID: <482A3FA0050D21419C269D13989C611308539560@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CecJG-0000Wl-Sj
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:47:30 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CecJD-0000oU-H8
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:47:30 -0800
To: "Olaf Kirch" <okir@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

olaf-

as we consider the changes you suggested to the port allocation
algorithm, can we think about the port blacklisting problem too?


> -----Original Message-----
> From: Mike Waychison [mailto:Michael.Waychison@Sun.COM]=20
> Sent: Wednesday, December 15, 2004 11:43 AM
> To: Lever, Charles
> Cc: David Meleedy; nfs@lists.sourceforge.net
> Subject: Re: [NFS] Intermittent RHE3-u3 client mount failures=20
> to Netapp fileserver
>=20
>=20
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Lever, Charles wrote:
> >=20
> > and check the hardware too.  we had an IPMI hardware=20
> implementation from
> > Intel at one point that took a port without notifying the operating
> > system, and that caused similar failures.
> >=20
>=20
> I've seen this too with e1000 hardware.  I usually blacklist the ports
> by adding the 623 for udp / tcp to my (x)inetd config and=20
> pointing them
> to /bin/true.
>=20
> I'm wondering if anybody has figured out a way to 'blacklist' these
> ports somehow from within the drivers..    ..probably best left as a
> hotplug event.
>=20
>=20
> - --
> Mike Waychison
> Sun Microsystems, Inc.
> 1 (650) 352-5299 voice
> 1 (416) 202-8336 voice
>=20
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> NOTICE:  The opinions expressed in this email are held by me,
> and may not represent the views of Sun Microsystems, Inc.
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.5 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org
>=20
> iD8DBQFBwGmxdQs4kOxk3/MRApeFAJkBj5Dn2KDsdkmknxUh+fmunZrALQCfTGm6
> 7N0fuLRQ22ff2MIUtzTS6KM=3D
> =3DxdDY
> -----END PGP SIGNATURE-----
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
