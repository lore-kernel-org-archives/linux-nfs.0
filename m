From: Sylvain Rochet <gradator@gradator.net>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 4 Aug 2009 13:15:05 +0200
Message-ID: <20090804111505.GA6433@gradator.net>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090803222901.GB23162@duck.suse.cz>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Tue, Aug 04, 2009 at 12:29:01AM +0200, Jan Kara wrote:
>=20
>   OK, I've found some time and written the debugging patch. Hopefully it
> will tell us more. It should output messages to the kernel log if it
> finds something suspicious - like:
> No dentry for unlinked inode...
> Dentry ... for unlinked inode ... has no parent
> Found directory entry ... for unlinked inode
>=20
>   When you see such messages in the log, send them to me please. Also
> attach the System.map file so that I can translate the address where
> i_nlink was dropped - for that ext3 should be compiled into the kernel
> (should not be a module). Thanks a lot for testing.

Patch applied.

And there is already a lot of output.

http://edony.tuxfamily.org/~grad/bazooka/System.map-2.6.30.4
http://edony.tuxfamily.org/~grad/bazooka/config-2.6.30.4
http://edony.tuxfamily.org/~grad/bazooka/kern.log


Sylvain

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKeBg5DFub3qtEsS8RAgIWAKCsC2fadjouSls1EWuiVIEPh3lxpgCfZ4wG
lgccIBouV30FqS6ou8zkxO8=
=iyJr
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
