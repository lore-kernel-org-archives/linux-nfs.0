From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
Date: Mon, 22 Feb 2010 06:37:41 +0100
Message-ID: <20100222053741.GE29366@develbox.linuxbox.cz>
References: <20100122150325.6ad12428.akpm@linux-foundation.org>
 <20100127190522.GB18278@fieldses.org>
 <4B60C5D4.6070000@atmos.washington.edu>
 <20100202162228.GD4293@fieldses.org>
 <20100216182248.GA4922@nik-comp.linuxbox.cz>
 <20100216202121.GE26292@fieldses.org>
 <20100216202720.GB4922@nik-comp.linuxbox.cz>
 <20100216202947.GF26292@fieldses.org>
 <20100217151435.GC30897@develbox.linuxbox.cz>
 <20100220235105.GB15015@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5oH/S/bF6lOfqCQb"
Cc: Nikola Ciprich <extmaillist@linuxbox.cz>,
	Harry Edmon <harry@atmos.washington.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100220235105.GB15015@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--5oH/S/bF6lOfqCQb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

It was working pretty well when we were using 2.6.27.x, but after upgrade, I
also changed FS from XFS to ext4, (so I can't easily test with 2.6.27 now) =
and
since then NFS is almost unusable on this machine.
But 2.6.27 is pretty old, so there's been a lot of changes.
But greg released 2.6.32.9-rc1 which contains bunch of NFS-related fixes,
so I'll give it a try and report.
nik

On Sat, Feb 20, 2010 at 06:51:05PM -0500, J. Bruce Fields wrote:
> On Wed, Feb 17, 2010 at 04:14:35PM +0100, Nikola Ciprich wrote:
> > Well,
> > I did a lot of stress tests, and it seems to be pretty random, and what=
's
> > worse, I think it is more then one problem, oh great...
> > Seems that at least one of my NFS problems was in fact caused by ext4 r=
egression
> > (what FS are you using?)
> > applying this one: http://bugzilla.kernel.org/attachment.cgi?id=3D24975
> > improved things for me a lot (see http://bugzilla.kernel.org/show_bug.c=
gi?id=3D15231 for
> > full discussion).
> > I'll watch the machine for next few days and report...
>=20
> Is there *any* kernel (however old) on which you are confident you can
> *not* reproduce the kref bug?
>=20
> --b.
>=20
> > regards
> > nik
> >=20
> > On Tue, Feb 16, 2010 at 03:29:47PM -0500, J. Bruce Fields wrote:
> > > On Tue, Feb 16, 2010 at 09:27:20PM +0100, Nikola Ciprich wrote:
> > > > > Nothing yet.  I'm taking another look.
> > > > >=20
> > > > > Do you know what the most recent version was where you did *not* =
see
> > > > > these warnings?
> > > > well, actually I decided I'll bisect this one no matter what, so ho=
pefully
> > > > we'll see soon :)
> > > > I'll report
> > >=20
> > > That would be fantastic, thanks.  What test-case are you using?
> > >=20
> > > Any partial information ("xxxx good, xxxx bad") would also be useful.
> > >=20
> > > --b.
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >=20
> >=20
> > --=20
> > -------------------------------------
> > Ing. Nikola CIPRICH
> > LinuxBox.cz, s.r.o.
> > 28. rijna 168, 709 01 Ostrava
> >=20
> > tel.:   +420 596 603 142
> > fax:    +420 596 621 273
> > mobil:  +420 777 093 799
> > www.linuxbox.cz
> >=20
> > mobil servis: +420 737 238 656
> > email servis: servis@linuxbox.cz
> > -------------------------------------
>=20

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--5oH/S/bF6lOfqCQb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFLghgl3xdJJrLygV4RAhjlAKDDuEk+3fib3A2Af1kIkMgOkrkikACeMqGN
OAoq1VR8TECw28TxKDUWY6E=
=JJo9
-----END PGP SIGNATURE-----

--5oH/S/bF6lOfqCQb--
