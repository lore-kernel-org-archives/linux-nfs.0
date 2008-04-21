From: Joey Hess <joeyh@debian.org>
Subject: Bug#476577: corrected patch
Date: Mon, 21 Apr 2008 12:53:14 -0400
Message-ID: <20080421165314.GA2178@kodama.kitenet.net>
References: <20080417200928.GA20809@kodama.kitenet.net> <20080420223416.GA12722@uio.no> <40FD052D-BBC2-4AE4-BEF3-56914D39E13A@oracle.com>
Reply-To: Joey Hess <joeyh@debian.org>, 476577@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Cc: "Steinar H. Gunderson" <sesse@debian.org>, linux-nfs@vger.kernel.org,
	476577@bugs.debian.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.476577.B476577.12087967971647@bugs.debian.org>
In-Reply-To: <40FD052D-BBC2-4AE4-BEF3-56914D39E13A@oracle.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-ID: <linux-nfs.vger.kernel.org>


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Chuck Lever wrote:
> What if /etc/mtab is a symlink to a valid writable file that is not /=20
> proc/mounts?  The test you introduce below will prevent that case from =
=20
> working properly.

Note that util-linux mount does the same thing in this case, so this must
be an uncommon case.

umount.nfs also avoids writing to /etc/mtab if it is a symlink..

> Is there a security issue with creating a file in / when /proc isn't =20
> mounted, or is this just an inconvenience?

The worse problem is that mount.nfs fails with a nonzero exit code if
/proc/ is mounted, since the fchmod of /proc/mounts fails.

--=20
see shy jo

--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIDMZ6d8HHehbQuO8RAvCPAJ4sHLvDygM0YTQjrsEmowipU1iP4gCgjjrv
ESEqMsE1Wnb7sZqqBHYXCqI=
=htOv
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--
