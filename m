Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754413Ab3KEKe7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Nov 2013 05:34:59 -0500
Date: Tue, 5 Nov 2013 05:34:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chutzpah@gentoo.org, liguangc@cn.ibm.com
Subject: Re: [PATCH] [RFC] vfs: don't revalidate dentries that serve as
 mountpoints
Message-ID: <20131105053448.57ab7f0e@tlielax.poochiereds.net>
In-Reply-To: <20131105133959.5be7c728@notabene.brown>
References: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
	<20131105133959.5be7c728@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/kPC/uDGwiqVRG=JLyrl4iWS"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kPC/uDGwiqVRG=JLyrl4iWS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 5 Nov 2013 13:39:59 +1100
NeilBrown <neilb@suse.de> wrote:

> On Mon,  4 Nov 2013 20:16:26 -0500 Jeff Layton <jlayton@redhat.com> wrote:
>=20
> > We had a couple of reports of people that are mounting NFS filesystems,
> > and then bind mounting certain local files onto dentries in that nfs
> > mount (sort of like a poor-man's unionmount).
> >=20
> > This all works well until the dentry serving as the mountpoint fails
> > d_revalidate. The dentry will end up being invalidated which makes the
> > bind mount unreachable via pathwalk.
> >=20
> > It doesn't make much sense to me to allow dentries to serve as
> > mountpoints to end up invalidated, so there's no real point in
> > attempting to d_revalidate them at all.
> >=20
> > Reported-by: Patrick McLean <chutzpah@gentoo.org>
> > Reported-by: Guang Cheng Li <liguangc@cn.ibm.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/namei.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index caa2805..5b10ad0 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -585,6 +585,9 @@ drop_root_mnt:
> > =20
> >  static inline int d_revalidate(struct dentry *dentry, unsigned int fla=
gs)
> >  {
> > +	/* dentries that serve as mountpoints are always considered valid */
> > +	if (d_mountpoint(dentry))
> > +		return 1;
> >  	return dentry->d_op->d_revalidate(dentry, flags);
> >  }
> > =20
>=20
> Makes sense to me. But what about the parent or grandparent of the mountp=
oint?
>=20
> Presumably we don't want to invalidate them either, and I don't think
> d_mountpoint() returns true for those, does it?
>=20
> NeilBrown

Good point...

I think we're probably saved there (at least on NFS) by the
check_submounts_and_drop() call in nfs_lookup_revalidate.

Hmmm, that said...I did do most of this testing on a slightly older
kernel that doesn't have that call, and I can't reproduce this problem
on a 3.12-ish kernel. I think this is probably already fixed by Miklos'
patches that added that.

Sorry for the noise!
--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/kPC/uDGwiqVRG=JLyrl4iWS
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSeMnIAAoJEAAOaEEZVoIVHZ8P+gMzM8MafR1dmCVSChDqtaql
EKXm1D7ULvlSK8TfllsWHPkzrcjocJ3xmzfdCirJl1paLImWQVjT+RCRC0aWBD7u
t0c7xicwhIoRtvNdhg1rUGnSOiVE0ul6OH5T/Qti/BNbaUsr6Q1ukEc9cFUHzz4i
n0rTyOSfmmfVPC7MGpM+plCTApsE7oz+iOQeEDjN74ZgVrYA60quSm3jmuy6PEit
H4YjSm1NTcV/klbDlyn0lyGcDFooLqWodptjUAUXfjOMp5ysx7e4yaY3LmVLrE56
B8fwH6T5x/A5rFxisEsI6Gh/SzkSgXKo3bb68ZdzzXtXsGZPULijrz+XiivRX7ZY
ljGmPki8ygBdyJ+i/1R46jauUbwYYuERpdwEGGIkuWf1YIXhqzdphU2SwGXQSxc+
Tl7ZTKyA/GwHFMkh4G35Bl86q7KAZ3sMf5TGCZ8Kqw+8HEQv/wfS/22PBZblfPz0
s8rz5HtVYkupznrl5+Po2WZZsOl1s/A8R48lIbs9+djLo+JlGnmdvkoAgxI5R9va
j28KdP57Q1Uff2600tC4JwFt9Xvypi08/hxtwGb/jKltdlQfmfTiU+PHE+yJ7xEe
eygAXHMrQEUxFOOc7BU9Ff5jo+6YUd3RVB/Rk30r9HWX1ODsGlqxdPoOaYakCxq6
b9Lz8axjouf46H+rTWL8
=0kZz
-----END PGP SIGNATURE-----

--Sig_/kPC/uDGwiqVRG=JLyrl4iWS--
