Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39634 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab2BTCzu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Feb 2012 21:55:50 -0500
Date: Mon, 20 Feb 2012 13:55:37 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120220135537.3078e20b@notabene.brown>
In-Reply-To: <20120216223011.GA23997@fieldses.org>
References: <20101227234641.GA22248@fieldses.org>
	<20110118204509.GA10903@fieldses.org>
	<AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
	<20110118220817.GF10903@fieldses.org>
	<20110308181320.GA15566@fieldses.org>
	<20110310105821.GE22723@ZenIV.linux.org.uk>
	<20110311150749.2fa2be66@notabene.brown>
	<20120214170300.GA4309@fieldses.org>
	<20120215165633.GE12490@fieldses.org>
	<20120216140603.08cb4900@notabene.brown>
	<20120216223011.GA23997@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/fK/CEmmQ9s9.vkyA0ET8wuk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fK/CEmmQ9s9.vkyA0ET8wuk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 16 Feb 2012 17:30:11 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Feb 16, 2012 at 02:06:03PM +1100, NeilBrown wrote:
> > I was going ask how you managed to get an 'unhashed' dentry which was n=
ot
> > DISCONNECTED, and belonged to a directory that could be the subject of
> > d_splice_alias (that implies it has a name).
> >=20
> > The bug sounds like a race between lookup and rmdir, which should be
> > prevented by i_mutex.
> >=20
> > I think that using __d_find_any_alias would just be papering over the
> > problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED=
 alias.
>=20
> Looking through the latest upstream code, I can't come up with another
> obvious reproducer.
>=20
> But I also can't see the code making any particular effort to ensure
> that dentries are removed from inode's alias lists at the same time
> they're unhashed.
>=20
> E.g., trace up through the callers of d_drop/__d_drop and try to
> convince yourselves that they all end up removing the dentry from the
> alias list.
>=20
> Can you see any reason why the following would actually create a
> problem?

No, I don't think that would cause problems, so it is probably a good clean
up and as Peng says it means we can remove the want_discon arg as well.

However I cannot help thinking that something else must be going wrong befo=
re
we get to this point.
When you rmdir a directory it must be empty and it will never be linked aga=
in.
So how does 'lookup' find the inode and want to attach a dentry to it?

So I still think this is just papering over some other problem.

I think that looking at when aliases are removed is missing the point.

A directory can only have one name so it can only have one dentry.
If that dentry gets unhashed, that is because the directory was deleted.  So
now it must have zero names.  So there is no way that lookup can possibly
find it, so there is no way that d_splice_alias can be asked to attach an
alias to it.


NeilBrown


>=20
> --b.
>=20
> commit fcfef6b7319c5d19ea5064317528ff994343b011
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Feb 13 13:38:33 2012 -0500
>=20
>     exports: stop d_splice_alias creating directory aliases
>    =20
>     A directory should never have more than one dentry pointing to it.
>    =20
>     But d_splice_alias() does so in the case of a directory with an
>     already-existing non-DISCONNECTED dentry.
>    =20
>     Prior to the removal of dentry_unhash() from vfs_rmdir(), around v3.0,
>     this could cause an nfsd deadlock like this:
>    =20
>     	- Somebody attempts to remove a non-empty directory.
>     	- The dentry_unhash() in vfs_rmdir() unhashes the dentry
>     	  pointing to the non-empty directory.
>     	- ->rmdir() then fails with -ENOTEMPTY
>     	- Before the vfs_rmdir() caller reaches dput(), an nfsd process
>     	  in rename looks up the directory by filehandle; at the end of
>     	  that lookup, this dentry is found by d_alloc_anon(), and a
>     	  reference is taken on it, preventing dput() from removing it.
>     	- A regular lookup of the directory calls d_splice_alias(),
>     	  finds only an unhashed (not a DISCONNECTED) dentry, and
>     	  insteads adds a new one, so the directory now has two
>     	  dentries.
>     	- The nfsd process in rename, which was previously looking up
>     	  the source directory of the rename, now looks up the target
>     	  directory (which is the same), and gets the dentry newly
>     	  created by the previous lookup.
>     	- The rename, seeing two different dentries, assumes this is a
>     	  cross-directory rename and attempts to take the i_mutex on the
>     	  directory twice.
>    =20
>     I don't see as obvious a reproducer now, but I also don't see the
>     existing code taking care to remove dentries from the alias list
>     whenever they're unhashed.
>    =20
>     It therefore seems safest to allow d_splice_alias to use any dentry it
>     finds.
>    =20
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> diff --git a/fs/dcache.c b/fs/dcache.c
> index f68e193..1fd2256 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1602,9 +1602,8 @@ struct dentry *d_splice_alias(struct inode *inode, =
struct dentry *dentry)
> =20
>  	if (inode && S_ISDIR(inode->i_mode)) {
>  		spin_lock(&inode->i_lock);
> -		new =3D __d_find_alias(inode, 1);
> +		new =3D __d_find_any_alias(inode);
>  		if (new) {
> -			BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
>  			spin_unlock(&inode->i_lock);
>  			security_d_instantiate(new, inode);
>  			d_move(new, dentry);


--Sig_/fK/CEmmQ9s9.vkyA0ET8wuk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT0G2KTnsnt1WYoG5AQJ2sg//ac8z9W/6zvajgc+KveKc+Kxp0DGqZagu
CbtxqZg3nfYvO04lRBm/mJTQuWm+N3x1Fj9YxlhGbrEadQb/H5cj+KzT0RBoVwRG
C8jXwEI367qLLEHNz+TsB3Gu7bejcxxTwsySKyvTke4SeXIUl0AubXAXIW2BsS1r
R9VEbq49CsBgCWQg0Pn32sQnXDantsLbfmMec8LAwZRip4M4m/NP+A91hWvqKOut
j+1YqwoQCrvSdFw+1u+5lj7eZlZ2MZKQWoE/RUafByivYLMblbFpG4BO2JXx6yfg
9FVV9qV1HHxs9DdFvMc2JL4Qk4oHLxokHKc3cZPiX6LPdLX5hwcFEl23XxEK6lNP
2ORvssYMb9cK2PqdUetp+V6j4wSfM6UMNlzsZNFhwpxyfRqs36vJU2Oesrko6Rkk
ppdbep2PnOnJPK+MLHX2df49hzXv77vs+e+c1v8cyDqAT29NIuBP8HYrUIMr/t04
D6lj2FWG1PREZK+th3+NYmaQcNv/5EAZzggtPOU1tWsrv81ETXSbDZQYQDkFRM0o
H+nFvmeurj6fjtC4ml8R0Ol6fN1LlOEHy226qjxzNBsLu1E7E2nWN47DIxR0gnN1
2O+wMT/xoAUPhGdP0MMAUYqly0Oycl8wCIyC1g7Q8ysO4x9kUN+LVvMjOYQGUsif
rHQdO4Zb6vQ=
=0lIt
-----END PGP SIGNATURE-----

--Sig_/fK/CEmmQ9s9.vkyA0ET8wuk--
