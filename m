Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50838 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbaHCXed (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Aug 2014 19:34:33 -0400
Date: Mon, 4 Aug 2014 09:34:23 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:testing 56/61] fs/nfs/dir.c:1092:26: sparse: incompatible
 types in comparison expression (different address spaces)
Message-ID: <20140804093423.3b467fe2@notabene.brown>
In-Reply-To: <CAHQdGtRYzKZiJLEuKAPWyE7j=H0-ymLJ-mpj+k1=eNY-MR70vA@mail.gmail.com>
References: <53deb592.cf6oANONk2xIr46y%fengguang.wu@intel.com>
	<20140804090328.0068952f@notabene.brown>
	<CAHQdGtRYzKZiJLEuKAPWyE7j=H0-ymLJ-mpj+k1=eNY-MR70vA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/MN9F8w9RVePFiaX8DKeNAY4"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MN9F8w9RVePFiaX8DKeNAY4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 3 Aug 2014 19:14:18 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Sun, Aug 3, 2014 at 7:03 PM, NeilBrown <neilb@suse.de> wrote:
> > On Mon, 04 Aug 2014 06:20:02 +0800 kbuild test robot <fengguang.wu@inte=
l.com>
> > wrote:
> >
> >> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> >> head:   f682a398b2e24ae0a775ddf37cced83b897198ee
> >> commit: d51ac1a8e9b86b2d17d349bb256869cab6522787 [56/61] NFS: prepare =
for RCU-walk support but pushing tests later in code.
> >> reproduce: make C=3D1 CF=3D-D__CHECK_ENDIAN__
> >>
> >>
> >> sparse warnings: (new ones prefixed by >>)
> >>
> >> >> fs/nfs/dir.c:1092:26: sparse: incompatible types in comparison expr=
ession (different address spaces)
> >> >> fs/nfs/dir.c:1169:31: sparse: incompatible types in comparison expr=
ession (different address spaces)
> >>
> >> vim +1092 fs/nfs/dir.c
> >>
> >>   1086                struct nfs_fh *fhandle =3D NULL;
> >>   1087                struct nfs_fattr *fattr =3D NULL;
> >>   1088                struct nfs4_label *label =3D NULL;
> >>   1089                int error;
> >>   1090
> >>   1091                if (flags & LOOKUP_RCU) {
> >> > 1092                        parent =3D rcu_dereference(dentry->d_par=
ent);
> >>   1093                        dir =3D ACCESS_ONCE(parent->d_inode);
> >>   1094                        if (!dir)
> >>   1095                                return -ECHILD;
> >
> > Hmmm.. I suspect rcu_dereference doesn't really make sense here.
> > After all, d_parent is not assigned with rcu_assign_ptr, and no-one els=
e uses
> > rcu_dereference for it.
> >
> > The issue is that, without locks, d_parent could change at any point.
> > As dentries are freed with call_rcu it is safe to follow any pointers w=
e find,
> > but there is a limit how much we can trust them.
> > It is very likely that any change to d_parent that mattered would incre=
ment
> > some seqlock so that RCU-walk would eventually abort.
> >
> >
> > So we may not need the
> >
> >> > 1169                        if (parent !=3D rcu_dereference(dentry->=
d_parent))
> >>   1170                                return -ECHILD;
> >
> > at the end, as a seqlock will probably catch any problem.
>=20
> My main worry with that argument is whether or not the d_seq protected
> lookups are guaranteed to always cover the parent. I can't see
> anything in Documentation/filesystems/path-lookup.txt that indicates
> that they must be.

I'll look harder and come up with something more convincing.
Give me a couple of days ... if this set misses the 3.17 merge window, then
it'll be nice and ready for 3.18 :-)

>=20
> > Without that we don't even need to store 'parent' at all, just
> >      dir =3D ACCESS_ONCE(dentry->d_parent->d_inode);
> >
> > If we keep it, which is probably safest, then using ACCESS_ONCE in plac=
e of
> > the current rcu_dereference() make sense.
> >
> >      parent =3D ACCESS_ONCE(dentry->d_parent);
> >      dir =3D ACCESS_ONCE(dir->d_inode);
> >
> > ...
> >
> >      if (parent !=3D ACCESS_ONCE(dentry->d_parent))
> >             return -ECHILD;
> >
> >
> > Trond, would you like me to resend that patch, or do you want to just
> > s/rcu_derefence/ACCESS_ONCE/
> > ??
>=20
> Could you send an incremental patch?

I went back to look at all the rcu_derefs with a refresh perspective.  There
are two patches which make the above error, and the rcu_deref in
rpcauth_lookupcred() is wrong.
In fact, the get_groups_info() is unneeded.  current_cred()->group_info is
never changed.   If the groups for a process change, the current_cred() is
updated, and that is already rcu protected.
So that patch can be significant simplified.

I'll send you incremental patches for anything I find and we can go from
there.

Thanks,
NeilBrown

--Sig_/MN9F8w9RVePFiaX8DKeNAY4
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU97G/znsnt1WYoG5AQJSrg/9HASnHjwYKxGJ1zLI+ZckXf9JLb6sMaVu
CDCZiEknv/ggNVbTFcol0Ta+H+aJHb3F4fCXpzl6sd3VIqoni01jbZzUpU1pfLVe
uAVY9AwDp72OsBGw26kqXR7me+CU77YCzBho/YygboKqJTfl62OqpDiSVJRyqcdW
c5CYvxbDWfQF/OcImYAo9Te/kuRDLExkdWsOP9OfuuEfm9wqxiLFpigeIv3ywSuc
5VMne4aMjduS+d/RvfqqgycgyonUHVfq/gm64O7+tgJHZuo9KVg9rASNY7pmxbJK
r70MFpN5AxYVTjt2LTiT4MqesOECKMFK7mfH/2RPLgazMSg1VDPCLMA3LuOMzuFd
wIFBKxMW5hXu8lA0Y6IOVFlUKaHJOTaImsQba2o8Purw4FjfgHmulj9Ybc5rdx9A
4I+fcW175oTgQS3tQ8VSU0JKCGibiNoiZzA4s/dn7eRxqYFAxR8eflJohsiSZ1c/
pICQupJ1SzOJa8WUVRQ/iQ3LpSVH+3UMbPP/Fl2SVGVVb0w0qBwXpXh0JG1gZhdh
kaRdr2HENYsi374rhriIyRFc31PtPYuLvJGIQF9Y4Kq43kD7+G9vgNZoo3j/4n0a
RbN/xuGHNh8E2LIm50ctFnDC32apCzlwbzIksfohW6elkpueSD81ydYb7OH/rnD1
aIloAeyyCTY=
=5oJh
-----END PGP SIGNATURE-----

--Sig_/MN9F8w9RVePFiaX8DKeNAY4--
