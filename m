From: Timo Sirainen <tss@iki.fi>
Subject: Re: NFS server waking up sleeping disks
Date: Sun, 09 Mar 2008 01:27:44 +0200
Message-ID: <1205018864.11220.689.camel@hurina>
References: <1204969522.11220.680.camel@hurina>
	 <47D29BC2.9000806@foo-lounge.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HYm5+70y6JkMV8Shf9Os"
Cc: linux-nfs@vger.kernel.org
To: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:43194 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbYCHX1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2008 18:27:47 -0500
In-Reply-To: <47D29BC2.9000806-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-HYm5+70y6JkMV8Shf9Os
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-03-08 at 14:59 +0100, Timo Reimann wrote:
> Timo Sirainen wrote:
> > My Linux 2.6.24.1 NFS server has two disks. One of them is rarely used,
> > so it's normally sleeping and is not even mounted anywhere. But after
> > the NFS mount hasn't been used for a while (some hours?) doing just a
> > "ls" on NFS client causes the sleeping disk to wake up and the "ls"
> > reply is delayed a few seconds until the wakeup is finished.
> >=20
> > Any ideas why it's waking up the disk that has nothing to do with NFS,
> > and how to prevent it from doing this?
>=20
> Your issue might be related to the same that I have (which is still
> unresolved). Basically, my non-mounted backup disk keeps spinning up
> after a rough 20-25 minutes of sleeping. Check out my archived thread
> for details and hints how to determine disk-accessing processes:
>=20
> http://marc.info/?l=3Dlinux-nfs&m=3D120354580303104&w=3D2
>=20
> However, there is no `ls' or similar call required to wake up my disk.
> It just happens.

Thanks, mountd is indeed the problem:

01:22:06.662763 open("/proc/partitions", O_RDONLY) =3D 9
..
01:22:06.663000 open("/dev/hda6", O_RDONLY) =3D 11
..
01:22:06.663175 read(11, "&s\301_\177{/x\24d\240\262\264\256a\374yy\327\6`l=
/\271"..., 4096) =3D 4096
01:22:11.678610 lseek(11, 0, SEEK_SET)  =3D 0

I'll go figure out why it's doing this.

--=-HYm5+70y6JkMV8Shf9Os
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0yDwyUhSUUBViskRAs+VAJ9DUxz4nCgxOsWXBEDQ9G0ocWVhRQCgpiOL
1zzEiCP8lQlqo2JWWChY7a8=
=XATi
-----END PGP SIGNATURE-----

--=-HYm5+70y6JkMV8Shf9Os--

