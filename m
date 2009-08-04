From: Sylvain Rochet <gradator@gradator.net>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 4 Aug 2009 12:50:04 +0200
Message-ID: <20090804105004.GA4016@gradator.net>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090728211215.GE28376@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932796AbZHDKuJ@vger.kernel.org>
In-Reply-To: <20090728211215.GE28376@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jul 28, 2009 at 05:12:15PM -0400, J. Bruce Fields wrote:
> On Tue, Jul 28, 2009 at 06:41:42PM +0200, Sylvain Rochet wrote:
> >=20
> > [...]
> > May 26 12:34:39 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!
> > May 26 12:39:43 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!
> >=20
> > This is obviously related to the corruption.
>=20
> It might be interesting to know whether the file that we returned to the
> client with nlink 0 was the same that you later saw corruption on; maybe
> adding a printk of the inode number there would help.
>=20
> Googling around on that error message, a previous thread:
>=20
> 	http://marc.info/?t=3D107429333300004&r=3D1&w=3D4
>=20
> seems to conclude it's a bug, but doesn't followup with a fix.  And I
> don't see any mention of possible filesystem corruption.
>=20
> Is NFSv4 involved here?  I wonder if something that might otherwise be
> only a problem for the client could become a problem for the server if
> it attempts to do further operations with an unlinked inode in a
> compound operation that follows a lookup.

NFSv3 here.

Sylvain

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKeBJcDFub3qtEsS8RAue2AJ940oj3TiTdzUtLo8xhlnM47jzEHACeJJME
SE0HtE5jB0MYBMK6Ehdyrj0=
=o/m5
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
