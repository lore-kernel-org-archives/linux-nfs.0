Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44418 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755590AbbDVXol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2015 19:44:41 -0400
Date: Thu, 23 Apr 2015 09:44:31 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150423094431.1a8aa68b@notabene.brown>
In-Reply-To: <20150422150703.GA1247@fieldses.org>
References: <553663B7.7030506@gmail.com>
	<20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/sLq9rguV363NksGzEMYcKNv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/sLq9rguV363NksGzEMYcKNv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Apr 2015 11:07:03 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:


> > Reference of dentry/mnt is like a cache, avoids re-finding of them,
> > it is necessary to store them in svc_export.
> >=20
> > Neil points out another way of 'fs_pin', I will check that.
>=20
> Yes, that'd be interesting.  On a very quick look--I don't understand
> what it's meant to do at all.  But if it does provide a way to get a
> callback on umount, that'd certainly be interesting....

Yeah, on a quick look it isn't really obvious at all.

But I didn't read the code.  I read
 https://lwn.net/Articles/636730/

which says:

    In its place is a mechanism by which an object can be added to a vfsmou=
nt
    structure (which represents a mounted filesystem); that object supports=
=20
    only one method: kill(). These "pin" objects hang around until the final
    reference to the vfsmount goes away, at which point each one's kill() f=
unction
    is called. It thus is a clean mechanism for performing cleanup when a f=
ilesystem
    goes away.

This is used to close "BSD process accounting" files on umount, and sound
like the perfect interface for flushing things from the sunrpc cache on
umount.

NeilBrown

--Sig_/sLq9rguV363NksGzEMYcKNv
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVTgyXznsnt1WYoG5AQIFZBAArHgIxN3S2D38FqYJbzfHAaTusLe1k9V+
A/13NrSWtpyCjb230glC8yYKdyP/LfdnJtehjTXNnAAOHqjfrLaywMzPcgH/3sPy
v/FhYxUqqbiWrvSQN2gIobFW4eNNzLL+Ve70Y2hq9vXXvbOMRbrealBU260mlmS0
OaO71u+/tuZTADRStC6XJeWwTxp/gS1aoRhM7d8KcBaQ0+Qu2p7Xwr3HmsrRz9fb
tNw8WDXyLOkOBzHta4fp6gdPXsotGlcqFzHra9hYdj3s6mgocDrRMRkOg0MEIRnF
nOVr8wdq3FMJWkz8EpgGd6wIokc1rVqATqnQdvGo4TmYQS8hvKAU1wBFmpiUZ6+h
F27bwlvkG8mw8J3qJz6+vQ75JSQ8W4LksV+vCt5jhlqPL1QGDbcOggjOgCIi2GL+
d9iNqW7sZIZ7czHgpdYkvssAgF9dnRyJ4QRvFTbfcrcdf9wi8fpWnNagmLG0/8RH
sg65UndYl8L8WMZBiMUreCInsPsjfDoAfKrZdBqqG2d9C+D6MxFU4a+0ayAKhDvz
feGDeZmk6jA5U9H8awu+FKXL/DxdLuIN9vpcMEOFNdLj7CwAduWRAZlNVFFs9bAM
Q3AIdHZLAvP9kHMFMvB4M136JWCdfVi50XtyFKkZI98UX7DDME6RuCktYteL2RYg
yC02RLVik94=
=7PqA
-----END PGP SIGNATURE-----

--Sig_/sLq9rguV363NksGzEMYcKNv--
