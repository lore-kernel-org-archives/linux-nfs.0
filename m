From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Wed, 8 Dec 2004 14:00:24 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC73@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc9rP-000212-0B
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 14:00:35 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cc9rL-0000HM-MU
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 14:00:34 -0800
To: "Mike Waychison" <Michael.Waychison@Sun.COM>
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

i don't have a patch like this, but trond may have something.

> -----Original Message-----
> From: Mike Waychison [mailto:Michael.Waychison@Sun.COM]=20
> Sent: Wednesday, December 08, 2004 4:58 PM
> To: Lever, Charles
> Cc: Olaf Kirch; nfs@lists.sourceforge.net
> Subject: Re: [PATCH] xprt sharing (was Re: [NFS] xprt_bindresvport)
>=20
>=20
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Lever, Charles wrote:
> >>>but also notice this cuts the usable port range in half=20
> >>
> >>(from ~800 to
> >>
> >>>~420).  we need some form of mitigation to ensure we aren't=20
> >>
> >>limiting the
> >>
> >>>number of NFS mounts a client can have.
> >>
> >>This has been bugging me for a while.  The fact that we are=20
> limitting
> >>ourselves to a single nfs mount per port.  From what I can=20
> >>tell, Solaris
> >>shares the transports between nfs mounts from the same server=20
> >>and saves
> >>themselves a lot of trouble with running out of port numbers=20
> >>in doing so.
> >>
> >>The attached patch does the same for Linux against 2.6.9.  We share
> >>xprts from existing connections, effectively removing any=20
> limit on the
> >>number of nfs mounts we have in the system.
> >>
> >>The only thing to worry about now is any talking to the=20
> portmapper or
> >>mountd from userspace using tcp, which will put the=20
> reserved ports in
> >>TIME_WAIT state.  This can limit the 'speed' at which we=20
> >>mount many mounts.
> >=20
> >=20
> > we're looking at a similar solution.  we want to make sure we don't
> > limit the scalability of everyone's mount point by making them all
> > funnel through a single slot table.
> >=20
>=20
> Can you post any work in progress for this?   The xprt patch I posted
> was written a while ago, and I just realized this afternoon that it
> doesn't seem to do the right thing for tcp sockets that are=20
> autoclosed.
>=20
> If you have a similar patch that works, it would save me the=20
> trouble ;)
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
> iD8DBQFBt3jodQs4kOxk3/MRArXNAKCaahtv7uNfhX2n2yaz/N3D18t0vgCfSOLa
> rOARY+qtJrFfWOtb0m18cSk=3D
> =3DHlXX
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
