Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55117 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992695AbbEOXYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 19:24:00 -0400
Date: Sat, 16 May 2015 09:23:49 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
Message-ID: <20150516092349.6718a946@notabene.brown>
In-Reply-To: <20150515211134.GG29627@fieldses.org>
References: <554A149B.5060102@gmail.com>
	<554A154B.6040103@gmail.com>
	<20150508144031.6f0d3cda@notabene.brown>
	<20150508134744.GA23753@fieldses.org>
	<5550A9DF.1070908@gmail.com>
	<20150513142515.6bd881c8@notabene.brown>
	<20150515211134.GG29627@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/xyUh4RAmNWUUa+EyIimAngR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/xyUh4RAmNWUUa+EyIimAngR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 15 May 2015 17:11:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, May 13, 2015 at 02:25:15PM +1000, NeilBrown wrote:
> > On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com>=
 wrote:
> >=20
> > > On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
> > > > It could also be useful to have the ability to force an unmount eve=
n in
> > > > the presence of locks.  That's not a safe default, but an
> > > > "allow_force_unmount" export option might be useful.
> >=20
> > We already have a mechanism to forcibly drop any locks by writing some =
magic
> > to /proc/fs/nfsd/unlock_{ip,filesystem}.  I don't think we need any mor=
e.
>=20
> Yeah, I remember thinking this sort of approach would have advantages,
> maybe I was wrong, I need to revisit it.
>=20
> The unlock_{ip,filesystem} approach requires temporarily shutting down
> mountd, doesn't it?

Not necessarily.
It does require ensuring that new locks aren't suddenly taken though.

I imagine an early step in the migration process is to "ifconfig down" the
virtual interface with the floating ID.  Then you can safely "unlock" and
unmount any filesystems are that only accessed via the IP.

But you are right that using the "unlock_*" interface and then unmounting is
racy in a way that we are trying to make "unmount" not racy.  So maybe an
"allow_force_unmount" would have a place.

Thanks,
NeilBrown

--Sig_/xyUh4RAmNWUUa+EyIimAngR
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVVaABjnsnt1WYoG5AQIm3A//T82LRt4VYjSqKqc9hYsudF3HhgLkN+Zu
LUFJYu3vTynZCvaqeiezlydJ5gJyRi0JTfCi1BE0eGVvRFFD+2ot9MqVGupV5gT/
z1scNP4nZVq7BdJ5tArf3HNocd7WD7yLDmSHyiT/yH0c58UKYVbxmv8cKWzXKyGa
4HkQNE9nx5YKx0nzOXITsU+lpp5YnHVLi1W6ZvL8wrcaNV9NT5NYumpMxbCOvhNg
0/wLgh56btOWXhpH2XkwmvuUrIKq5ZmkbJmIiL/besdURI7n5kTbp+7jW3mQacfD
l/t8zjIPJ9jTZ5yHHZmu5BgKy8muhUTcnvo0X5yzFFkC2HyeKj5kZBuPB98Dn6EI
BLId1PNdBFqglOCCLjTomEY3QJ1YfE3fIjV2ipVmREK70dIWUAhS7gLX0HnlI0h3
+F4gdUB+xt+5ZdZI8nwVndEe03gwyO4tp2idnYsaORt0DHUkES0XWAR7rNdEcc7F
11XVGy3H0xrKVQGB3bB5UXUDyL34D1ZZbM91ZxsxgV5bSyBO8Wf8WSA87C5AeVtd
+fvnrMyEt82RpAw6L55Ef/BbT+TUr28o21OpoOAIyO/xFaa/ky9alVITh4sxmyMr
p+kB/08oBUpC1z1pC5NtlqZtlIwucE6nHStbs6iPvUVW1gpQ/aIX+ICAwMFhJXKu
nb0sS1iupmY=
=nukn
-----END PGP SIGNATURE-----

--Sig_/xyUh4RAmNWUUa+EyIimAngR--
