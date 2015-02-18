Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57586 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbbBRCJ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 21:09:57 -0500
Date: Wed, 18 Feb 2015 13:09:49 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
Message-ID: <20150218130949.31c4b180@notabene.brown>
In-Reply-To: <20150218015432.GA4148@fieldses.org>
References: <20150216122107.4bfd4225@notabene.brown>
	<20150216201751.GB22154@fieldses.org>
	<20150218124101.0c1cebfe@notabene.brown>
	<20150218015432.GA4148@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/iB02=3F4mQUnhBAuDk=3FsT"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/iB02=3F4mQUnhBAuDk=3FsT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 17 Feb 2015 20:54:32 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Feb 18, 2015 at 12:41:01PM +1100, NeilBrown wrote:
> > On Mon, 16 Feb 2015 15:17:51 -0500 bfields@fieldses.org (J. Bruce Field=
s)
> > wrote:
> >=20
> > > On Mon, Feb 16, 2015 at 12:21:07PM +1100, NeilBrown wrote:
> > > >=20
> > > >=20
> > > > - note that 'nohide' is irrelevant for NFSv4
> > > > - note that children on a 'crossmnt' filesystem cannot be unexported
> > > > - note that 'nocrossmnt' is a valid option, but probably not useful.
> > > >=20
> > > > Signed-off-by: NeilBrown <neilb@suse.de>
> > > >=20
> > > > ---
> > > >=20
> > > > I wonder if we should add a new option, e.g. "noaccess" so that chi=
ldren
> > > > of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't nee=
d to
> > > > know about this.  It would just tell mountd to refuse to export that
> > > > filesystem even if the parent was "crossmnt".
> > > > ??
> > >=20
> > > Seems logical enough, but I can't recall seeing requests for it, and
> > > the options here already seem complicated enough.
> >=20
> > I haven't seem requests myself.  Just rumours of 'nohide' not working w=
ith
> > NFSv4, which seems to suggest that someone wants something like that.
> > But I cannot find a clear source.
> >=20
> > Maybe:
> >=20
> > http://ubuntuforums.org/showthread.php?t=3D2152643
> > http://ubuntuforums.org/showthread.php?t=3D1603881
> >=20
> >=20
> > >=20
> > > In theory something like that could also be done with namespaces.  (S=
o,
> > > run mountd in a separate mount namespace that lacks those children.)
> >=20
> > Do any of the NFS man pages need to be updated to say something about
> > namespaces?
>=20
> Maybe just a note in the rpc.mountd man page that export paths are all
> with respect to the mount namespace rpc.mountd is running in?
>=20

I assume that implies that there can only ever be one rpc.mountd running?

I haven't really been following, but I assumed we would end up with a
different rpc.mountd in each of several different namespaces, each one seei=
ng
a different cache through a differently configured /proc..

And somehow there would be different nfsds in different network namespaces,
each tied to a filesystem namespace ... or something.


I guess that isn't want is really happening?

Thanks,
NeilBrown

--Sig_/iB02=3F4mQUnhBAuDk=3FsT
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOP0bTnsnt1WYoG5AQLV5A//YCwQRUhyw9cEciKhgQVyhZqP+TBqtPOc
oTDd6csuQIYW6APqDnXKvVXQ36mfV6lm5Asd3epLKiFLE89LJP+Jc2dTaSZ5DnrA
/0OweHqJcNFkXp0jLJy6d6QPg438Hc6Jzv3LUKE9CqJABba+9YCuVyG8tPGBp7dY
lg8khCcC4bl0vdzuY/e6Kwsd/9nqqA6Sr8GZW4xk7BWV0XYJRSUyYixiY6RcyZrI
uGArxtG7elEMLtJgQFxnu64RRD4xHd/3lXlJMXI0/VWUBpz38TJbMVb3lniqssoA
nxBt34obW4kiqoo0PvOcfJIbohbkzMxLhIA4TSP1Lhavsd6LX+2II81naDFKTqjU
P4UHUNcGkkPOD+g8T6hYBLvvjLHMSJVKK//pWB3fLMAof7hxTLQmLtYwRT5KWO8u
IFISOBB3OVqpM/VFddk6b6YxXhPLkedui8zJ34TcxxY8gjt4o0PEBtQUCHmw26Cl
RY/clTjbNtokos46nL4ZXs9goZFCqNOUiBDsQLqxSnmP5lEIxewcJZoS/jseESIe
euR1H3Q2ZBZ30CL6lPTopEtxo7Em20rCQI6vJZXfsDAcNkXIKy2SMlOkQWI4ySUT
GnF6UT9i0BNCZ+vLUzSJl3/dm2nCnQLGe8n31SelHEgle3OqKYVfoQnAcEsALcHf
/0Jb27tqxUE=
=MStj
-----END PGP SIGNATURE-----

--Sig_/iB02=3F4mQUnhBAuDk=3FsT--
