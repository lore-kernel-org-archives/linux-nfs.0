From: Timo Sirainen <tss@iki.fi>
Subject: Re: inode caching
Date: Tue, 27 May 2008 18:40:48 +0300
Message-ID: <1211902848.3904.279.camel@hurina>
References: <1211835499.3904.231.camel@hurina>  <483C031B.80601@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bRIdSC78VbuFmt4KCbmH"
Cc: linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:41024 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757604AbYE0Pky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 11:40:54 -0400
In-Reply-To: <483C031B.80601@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-bRIdSC78VbuFmt4KCbmH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-05-27 at 08:48 -0400, Peter Staubach wrote:
> Timo Sirainen wrote:
> > NFS server: Linux 2.6.25
> > NFS client: Linux debian 2.6.25-2 (or 2.6.23.1)
> >
> > If I do:
> >
> > NFS client: fd1 =3D creat("foo"); write(fd1, "xx", 2); fsync(fd1);
> > NFS server: unlink("foo"); creat("foo");
> > NFS client: fd2 =3D open("foo"); fstat(fd1, &st1); fstat(fd2, &st2);
> > fstat(fd1, &st3);
> >
> > The result is usually that the fstat(fd1) fails with ESTALE. But
> > sometimes the result is st1.st_ino =3D=3D st2.st_ino =3D=3D st3.st_ino =
and
> > st1.st_size =3D=3D 2 but st2.st_size =3D=3D 0. So I see two different f=
iles
> > using the same inode number. I'd really want to avoid seeing that
> > condition.
> >
> >  =20
>=20
> This is really up the file system on the server. It is the one
> that selects the inode number when creating a new file.

I don't mind that the inode gets reused, I mind that I can't reliably
detect that situation.

> > So what I'd want to know is:
> >
> > a) Why does this happen only sometimes? I can't really figure out from
> > the code what invalidates the fd1 inode. Apparently the second open()
> > somehow, but since it uses the new "foo" file with a different struct
> > inode, where does the old struct inode get invalidated?
> >
> >  =20
>=20
> This will happen always, but you may see occasional successful
> fstat() calls on the client due to attribute caching and/or
> dentry caching.

I would understand if it always failed or always succeeded, but it seems
to be somewhat random now. And it's not "occational successful fstat()",
but it's "occational failed fstat()". The difference shouldn't be
because of attribute caching, because I specify it explicitly to two
seconds and run the test within that 2 second. So the test should always
hit the attribute cache, and according to you that should always cause
it to succeed (but it rarely does). I think dentry caching also more or
less depends on attribute cache timeout?

> > b) Can this be fixed? Or is it just luck that it works as well as it
> > does now?
> >
> >  =20
>=20
> This can be fixed, somewhat. I have some changes to address the
> ESTALE situation in system calls that take filename as arguments,
> but I need to work with some more people to get them included.
> The system calls which do not take file names as arguments can not
> be recovered from because the file they are referring is really
> gone or at least not accessible anymore.
>=20
> The reuse of the inode number is just a fact of life and that way
> that file systems work. I would suggest rethinking your application
> in order to reduce or eliminate any dependence that it might have.

The problem I have is that I need to reliably find out if a file has
been replaced with a new file. So I first flush the dentry cache
(chowning parent directory), stat() the file and fstat() the opened
file. If fstat() fails with ESTALE or if the inodes don't match, I know
that the file has been replaced and I need to re-open and re-read it.
This seems to work nearly always.

--=-bRIdSC78VbuFmt4KCbmH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIPCuAyUhSUUBViskRAqmQAJ4xMsVaYZhrYP42tHfeHhQ2/+SPcwCdEtvF
CKzdlRX0Qr1BtFc2fg3uY9s=
=pfDx
-----END PGP SIGNATURE-----

--=-bRIdSC78VbuFmt4KCbmH--

