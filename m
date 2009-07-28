From: Sylvain Rochet <gradator@gradator.net>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 28 Jul 2009 18:41:42 +0200
Message-ID: <20090728164142.GA13662@gradator.net>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755017AbZG1Qlq@vger.kernel.org>
In-Reply-To: <20090728135226.GA21682@duck.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Tue, Jul 28, 2009 at 03:52:26PM +0200, Jan Kara wrote:
> On Tue 28-07-09 13:27:15, Sylvain Rochet wrote:
> > On Mon, Jul 27, 2009 at 05:42:53PM +0200, Jan Kara wrote:
> > > On Sat 25-07-09 17:17:52, Sylvain Rochet wrote:
> > > > >=20
> > > > > Can you still see the corruption with 2.6.30 kernel?
> > > >=20
> > > > Not upgraded yet, we'll give a try.
> >=20
> > Done, now featuring 2.6.30.3 ;)
>=20
> OK, drop me an email if you will see corruption also with this kernel.

Lets move out the corrupted directory ;)

root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# rm --=
 * .ok=20
rm: cannot remove `spip%3Farticle19.f8740dca': Input/output error
root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cd ..
root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache# mv e/ /=
data/lost+found/wooops


> > > This is probably the misleading output from ext3_iget(). It should gi=
ve
> > > you EIO in the latest kernel.
> >=20
> > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# c=
at spip%3Farticle19.f8740dca=20
> > cat: spip%3Farticle19.f8740dca: Input/output error
> >=20
> > It has much more sense now. We thought the problem was around NFS due=
=20
> > the the previous error message, actually this is probably not the best=
=20
> > looking path.
>=20
> Yes, EIO makes more sence. I think the problem is NFS connected anyway
> though :). But I don't have a clue how it can happen yet. Maybe I can try
> adding some low-cost debugging checks if you'd be willing to run such
> kernel...

Without any problem, we have 24/7/365 physical access and we don't need=20
to provide high-availability services.

Anyway, the data hosted aren't that important, there is little or even=20
no need for strict confidentiality, so we will be happy to provide ssh=20
access to whom would like to look deeper into this issue.


> I'm adding to CC linux-nfs just in case someone has an idea.
>=20
> > >   Ah, OK, here's the problem. The directory points to a file which is
> > > obviously deleted (note the "Links: 0"). All the content of the inode=
 seems
> > > to indicate that the file was correctly deleted (you might check that=
 the
> > > corresponding bit in the bitmap is cleared via: "icheck 88541562").
> >=20
> > root@bazooka:~# debugfs /dev/md10
> > debugfs 1.40-WIP (14-Nov-2006)
> > debugfs:  icheck 88541562
> > Block   Inode number
> > 88541562        <block not found>
>=20
> Ah, wrong debugfs command. I should have written:
> testi <88541562>

debugfs:  testi <88541562>
Inode 88541562 is not in use


> > >   The question is how it could happen the directory still points to t=
he
> > > inode. Really strange. It looks as if we've lost a write to the direc=
tory
> > > but I don't see how. Are there any suspitious kernel messages in this=
 case?
> >=20
> > There were nothing for a while, but since the reboot there are some=20
> > about this inode:=20
> >=20
> > EXT3-fs error (device md10): ext3_lookup: deleted inode referenced: 885=
41562
>=20
> Yes, that's to be expected given the corruption any NFS error messages?

There are some error messages on NFS clients, however they are quite old.

Apr 19 15:38:21 gin kernel: NFS: Buggy server - nlink =3D=3D 0!
May  3 20:00:52 gin kernel: NFS: Buggy server - nlink =3D=3D 0!
May  3 23:24:03 gin kernel: NFS: Buggy server - nlink =3D=3D 0!
May  7 11:40:57 gin kernel: NFS: Buggy server - nlink =3D=3D 0!
May  7 14:41:02 gin kernel: NFS: Buggy server - nlink =3D=3D 0!
May 26 11:10:42 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!
May 26 11:13:28 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!
May 26 12:34:39 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!
May 26 12:39:43 cognac kernel: NFS: Buggy server - nlink =3D=3D 0!

This is obviously related to the corruption.



Sylvain

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKbypGDFub3qtEsS8RAgERAJ9GdWiFQCX8t2oZfFFTS/9UwbqfygCeO05E
7EIKWVZT8uF3KHO4hFpmolE=
=+F77
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
