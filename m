Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50589 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbaHCXDi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Aug 2014 19:03:38 -0400
Date: Mon, 4 Aug 2014 09:03:28 +1000
From: NeilBrown <neilb@suse.de>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, kbuild-all@01.org,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:testing 56/61] fs/nfs/dir.c:1092:26: sparse: incompatible
 types in comparison expression (different address spaces)
Message-ID: <20140804090328.0068952f@notabene.brown>
In-Reply-To: <53deb592.cf6oANONk2xIr46y%fengguang.wu@intel.com>
References: <53deb592.cf6oANONk2xIr46y%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/tRT7m7XLyaUxxEwb_EMxV88"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tRT7m7XLyaUxxEwb_EMxV88
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 04 Aug 2014 06:20:02 +0800 kbuild test robot <fengguang.wu@intel.co=
m>
wrote:

> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   f682a398b2e24ae0a775ddf37cced83b897198ee
> commit: d51ac1a8e9b86b2d17d349bb256869cab6522787 [56/61] NFS: prepare for=
 RCU-walk support but pushing tests later in code.
> reproduce: make C=3D1 CF=3D-D__CHECK_ENDIAN__
>=20
>=20
> sparse warnings: (new ones prefixed by >>)
>=20
> >> fs/nfs/dir.c:1092:26: sparse: incompatible types in comparison express=
ion (different address spaces)
> >> fs/nfs/dir.c:1169:31: sparse: incompatible types in comparison express=
ion (different address spaces)
>=20
> vim +1092 fs/nfs/dir.c
>=20
>   1086		struct nfs_fh *fhandle =3D NULL;
>   1087		struct nfs_fattr *fattr =3D NULL;
>   1088		struct nfs4_label *label =3D NULL;
>   1089		int error;
>   1090=09
>   1091		if (flags & LOOKUP_RCU) {
> > 1092			parent =3D rcu_dereference(dentry->d_parent);
>   1093			dir =3D ACCESS_ONCE(parent->d_inode);
>   1094			if (!dir)
>   1095				return -ECHILD;

Hmmm.. I suspect rcu_dereference doesn't really make sense here.
After all, d_parent is not assigned with rcu_assign_ptr, and no-one else us=
es
rcu_dereference for it.

The issue is that, without locks, d_parent could change at any point.
As dentries are freed with call_rcu it is safe to follow any pointers we fi=
nd,
but there is a limit how much we can trust them.
It is very likely that any change to d_parent that mattered would increment
some seqlock so that RCU-walk would eventually abort.

So we may not need the=20

> > 1169			if (parent !=3D rcu_dereference(dentry->d_parent))
>   1170				return -ECHILD;

at the end, as a seqlock will probably catch any problem.
Without that we don't even need to store 'parent' at all, just
     dir =3D ACCESS_ONCE(dentry->d_parent->d_inode);

If we keep it, which is probably safest, then using ACCESS_ONCE in place of
the current rcu_dereference() make sense.

     parent =3D ACCESS_ONCE(dentry->d_parent);
     dir =3D ACCESS_ONCE(dir->d_inode);

...

     if (parent !=3D ACCESS_ONCE(dentry->d_parent))
            return -ECHILD;


Trond, would you like me to resend that patch, or do you want to just
s/rcu_derefence/ACCESS_ONCE/
??

Thanks,
NeilBrown

--Sig_/tRT7m7XLyaUxxEwb_EMxV88
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU96/wDnsnt1WYoG5AQI91A/9H+cS+aCMTjg6Utp0XdZ4PKVz8HstEXW/
eozIQ9Z5PUsh9y6q5H+/OMXKLOlx7IzrVX1ALQIB3qwO/3NkrL7SUz1vUmxiw8ax
7suBTyvltDLEj804N0ZDwe1pOa2xdcqG4lVnK2yVPsaV4UhTEE8/pIvz6YeglZyf
uvRIwzadDjMAY22fdgrYp24velOWJ+bkEXFgKnyCuRkvQVdyOUnIbMDf5s6P3eTB
te43tkVFlWmMDZzMiB4ZNuKFSfJJ1t1yh9ZN5ZUluxjsrcFKV+CxqiSQttyxn7z0
w+jFlRXndJcs9JZz1YND0Wl+W4empDtRvF8WCkREbxMI2w/ak3gb27Y9INOr6o6e
arwBbgcScL3NxjI3S9lVd2hlbdUip1BP/IJbHDqFJiFw7JstThVa7Z0lhUuG/nam
rdXi2fzFyxnV+UZVeoCsjF7MaL2JCJ5IWcfxO9yvmPXs8YM4Pcc73y+P6yuVj/Kc
5MT1SPUekQ1EYcRtLGRI3oPiIZaXTVqR2/dPUtH8rW2Wag6rKMIgfYF2FvZnAS3C
XE+dHnqyWW/KuAgx1j5oyf0fAhve7jzhSNzUm8DssqqSaoYxyTq0PuhbCDASdgoJ
JBkdIgl7OQ+of1HL63YgR6Hj49KeMjfEYXmvPUVaVScLVbCYydE96cnxx0OApoVp
AiWR5GoDGZY=
=U0rQ
-----END PGP SIGNATURE-----

--Sig_/tRT7m7XLyaUxxEwb_EMxV88--
