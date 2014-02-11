Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34588 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbaBKE3S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 23:29:18 -0500
Date: Tue, 11 Feb 2014 15:29:06 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: "nosharecache" option prevent "mount" from detecting when the
 mount is a duplicate.
Message-ID: <20140211152906.4b370ccb@notabene.brown>
In-Reply-To: <4A18E8CC-9376-4456-9FD6-E6B36BF8E89D@primarydata.com>
References: <20140211133013.1ccf8615@notabene.brown>
	<4A18E8CC-9376-4456-9FD6-E6B36BF8E89D@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/LyK41d69rFlRoRX1zLcEwuu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/LyK41d69rFlRoRX1zLcEwuu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Feb 2014 23:19:09 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On Feb 10, 2014, at 21:30, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > (I seem to have quite a pile of NFS issues lately.... some if it is tid=
ying up
> > issues from before Christmas, some of it just keeps on coming :-)
> >=20
> > If you run "mount -a" it will attempt to mount all filesystems listed
> > in /etc/fstab, but filesystems that are already mounted will not be mou=
nted
> > again.  So it is normally safe to run "mount -a" multiple times.
> >=20
> > However if an NFS mount in /etc/fstab has the "nosharecache" option set,
> > mount doesn't notice that it is already mounted as so mounts it again. =
 So
> > repeated "mount -a" is no longer safe.
> >=20
> > This happens because the prevention of multiple mounts happens in do_ad=
d_mount
> > in fs/namespace.c:
> >=20
> > 	err =3D -EBUSY;
> > 	if (path->mnt->mnt_sb =3D=3D newmnt->mnt.mnt_sb &&
> > 	    path->mnt->mnt_root =3D=3D path->dentry)
> > 		goto unlock;
> >=20
> >=20
> > i.e. if the exact same superblock is being mounted in the exact same pl=
ace,
> > return EBUSY.
> > With nosharecache, every mount attempt produces a new superblock so thi=
s test
> > never fires.
> >=20
> > One way to address this would be to have a different option, e.g.
> >          sharecache=3D27
> >=20
> > where the '27' is an arbitrary number meaning that if two mount attempt=
s have
> > different sharecache numbers they will have different superblocks.  If =
they
> > have the same sharecache number they can have the same superblock.
> > This is not the most elegant interface ever and I would be very happy f=
or
> > suggestions to improve it.  Maybe a string rather than a number ???
> >=20
> > This probably isn't a very serious issue, but is a regression in terms =
of the
> > usability of "mount -a" and I think it would be best to fix it if the c=
ost is
> > not too high.
> >=20
> > Below is my patch to implement the "sharecache=3D%u" syntax.
> >=20
> > Any ideas?
>=20
> What are people using nosharecache for these days, and why is this not an=
other argument for just getting rid of it?

Baby or bath water?

In the particular case that brought this up for me they are actually using
"nosharetransport" which is a similar option I provide in SLES because there
are cases where sharing the transport reduces performance, and cases where
sharing the transport interacts poorly with particular details (of particul=
ar
versions) of the Netapp filer.

Seeing the root problem is the same for nosharecache and nosharetransport
it seems reasonable to report it upstream as an issue with nosharecache.

If you don't think this is worth "fixing", I certainly don't feel strongly
enough about it to argue.

Thanks,
NeilBrown

--Sig_/LyK41d69rFlRoRX1zLcEwuu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvmnEjnsnt1WYoG5AQI98RAApyiveQk8jxF1bkSPXiEI4+LHIgvX+/bq
fWZxf7LQLtzI5laNs9rLXW7yq/oDOShRWBJRId4IiEz/pTr1PeJIE3mVu5/6vgcn
W0pVhEKkoZL88tpaTSrM1FXqsVZVgUymT8zefCTTSnE+wnk89HxsdVZGlq9Jd9V4
1mgIzokWWyQCzvcVqr9yW4J0XKSKnz6zJdNdwVxy0z+YNm5PzivYiSLom8fBoIE7
rOsX3ML4sOmgfcp2nsEwnwgfi+c/OB6u5xb01SfyxEjF+S+kiwRyUUEo8HwIRztG
DxY5zBeS5zauoUUyc0YoaMJ6STJuVMz2X29LoALGGVbnKvJAIPkQwvehEjRN2C4E
U9MEzr37ScV3dct3WMdTVaEnMzerOwPLTXU2QM4/X/XXlLqm9sabcmrzRLtTNBBv
4si1kHxBuvLoaPKoVVUz7LR3gU0FNIglvBDFFvpsfx20iq0SBqYM0ePkISt4aYq0
OlwV3T4ecnpQbOCODWkRB6nRNUTsciG+fLgHTpbAJn7o0wKSC22642sM9YVUO12a
2JX+bc/YhEMUq7bFejZ9uciQHg42siZWnJWO5dhNI3h++aD71mee52bZmv2aaGfp
m1TMoXOebtBhK4nSoKhz520hXv+ucmbgdBPHCVp/FT5rlfW0vRzgRo/YzOUnyQPt
iwbfRhH/tgA=
=wcTY
-----END PGP SIGNATURE-----

--Sig_/LyK41d69rFlRoRX1zLcEwuu--
