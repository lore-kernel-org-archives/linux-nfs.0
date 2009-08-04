From: Sylvain Rochet <gradator@gradator.net>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 4 Aug 2009 13:02:18 +0200
Message-ID: <20090804110217.GB4016@gradator.net>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090729125812.GL19209@duck.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GRPZ8SYKNexpdSJ7"
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090729125812.GL19209@duck.suse.cz>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Wed, Jul 29, 2009 at 02:58:12PM +0200, Jan Kara wrote:
> On Tue 28-07-09 18:41:42, Sylvain Rochet wrote:
> >=20
> > Lets move out the corrupted directory ;)
> >=20
> > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# r=
m -- * .ok=20
> > rm: cannot remove `spip%3Farticle19.f8740dca': Input/output error
> > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# c=
d ..
> > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache# mv =
e/ /data/lost+found/wooops
>=20
> Actually, leaving that file in the filesystem can potentially lead to
> strange effects because eventually the inode "spip%3Farticle19.f8740dca"
> points to gets reallocated and then you can get e.g. a hardlinked
> directory. On the other hand having it lost+found should be safe enough.

This happened a few times in the past, we saw corrupted dentries reappearin=
g with=20
a new file. New files with reference count set to 1 (but obviously should b=
e 2 in=20
this case). So the rule is "do not delete corrupted dentries anyway, keep t=
hem=20
safe in lost+found and do not touch it" ;).


Sylvain

--GRPZ8SYKNexpdSJ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKeBU5DFub3qtEsS8RAjidAJ9PuXtg58stKQYONUHxqcRV+ZDadACgvsOO
7SuufSlm3vtniC+vnWHa+2I=
=3Caa
-----END PGP SIGNATURE-----

--GRPZ8SYKNexpdSJ7--
