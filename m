From: Garrick Staples <garrick@usc.edu>
Subject: Re: stat'ing >4TB NFS filesystems
Date: Fri, 16 Jul 2004 10:02:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040716170216.GL22659@polop.usc.edu>
References: <20040715192125.GZ22659@polop.usc.edu> <40F7AC3F.5050800@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6e3mN4pOUzfBrwoS"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BlW6F-0008LV-JF
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 10:02:19 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BlW6F-0000O1-B0
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 10:02:19 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i6GH2GFM026687
	for <nfs@lists.sourceforge.net>; Fri, 16 Jul 2004 10:02:16 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i6GH2G4S026685
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 10:02:16 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <40F7AC3F.5050800@RedHat.com>
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


--6e3mN4pOUzfBrwoS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 16, 2004 at 06:21:51AM -0400, Steve Dickson alleged:
>=20
>=20
> Garrick Staples wrote:
>=20
> >  I have some RHE3 machines (2.4.21) here that can't properly stat a 5GB=
=20
> >  filesystem,
> >but some RH7.2 machines with (vanilla 2.4.26) can stat it fine.  I=20
> >searched for
> >the lkml looking for NFS patches since 2.4.21 but couldn't find anything.
> >Can anyone here point me to the right patch?
> >
> >=20
> >
> There are a couple patches in
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D121475
> one of which made it into U3....


Thanks, everything is working great now!

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--6e3mN4pOUzfBrwoS
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA+AoY0SBUxJbm9HMRAi5eAJ9OdBzX3X2+YxeK8sER8lXBK1gRhgCeLGCb
b7K04CWpa8oFgLjmo1plY0A=
=iXdr
-----END PGP SIGNATURE-----

--6e3mN4pOUzfBrwoS--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
