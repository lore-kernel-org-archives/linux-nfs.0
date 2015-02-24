Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39579 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbbBXVt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2015 16:49:59 -0500
Date: Wed, 25 Feb 2015 08:49:50 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Nix <nix@esperi.org.uk>
Subject: Re: [PATCH 1/3] NFS: Don't invalidate a submounted dentry in
 nfs_prime_dcache()
Message-ID: <20150225084950.38900907@notabene.brown>
In-Reply-To: <CAHQdGtR1GawAD6yAidTZJM68TzaBrieX86C+eDE08HQF_0Jg4w@mail.gmail.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
	<CAHQdGtR1GawAD6yAidTZJM68TzaBrieX86C+eDE08HQF_0Jg4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/gV6CtUuAMDmgT4fABU94IIw"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/gV6CtUuAMDmgT4fABU94IIw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Feb 2015 22:09:09 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, Feb 23, 2015 at 7:14 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > If we're traversing a directory which contains a submounted filesystem,
> > or one that has a referral, the NFS server that is processing the READD=
IR
> > request will often return information for the underlying (mounted-on)
> > directory. It may, or may not, also return filehandle information.
> >
> > If this happens, and the lookup in nfs_prime_dcache() returns the
> > dentry for the submounted directory, the filehandle comparison will
> > fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
> > ("vfs: Lazily remove mounts on unlinked files and directories."), this
> > means the entire subtree is unmounted.
> >
> > The following minimal patch addresses this problem by punting on
> > the invalidation if there is a submount.
> >
> > Kudos to Neil Brown <neilb@suse.de> for having tracked down this
> > issue (see link).
> >
> > Reported-by: Nix <nix@esperi.org.uk>
> > Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
> > Cc: stable@vger.kernel.org # 3.18+
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfs/dir.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 9b0c55cb2a2e..0da617a61c0b 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -479,6 +479,10 @@ void nfs_prime_dcache(struct dentry *parent, struc=
t nfs_entry *entry)
> >
> >         dentry =3D d_lookup(parent, &filename);
> >         if (dentry !=3D NULL) {
> > +               /* Is there a mountpoint here? If so, just exit */
> > +               if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
> > +                                       &entry->fattr->fsid))
> > +                       goto out;
> >                 if (nfs_same_file(dentry, entry)) {
> >                         nfs_set_verifier(dentry, nfs_save_change_attrib=
ute(dir));
> >                         status =3D nfs_refresh_inode(dentry->d_inode, e=
ntry->fattr);
> > --
>=20
> ...and this of course needs the test for NFS_ATTR_FATTR_FSID from
> 3/3.... I've updated.
>=20
>=20
>=20

Sorry ... I didn't see this before my earlier reply...

What exactly do you do if NFS_ATTR_FATTR_FSID isn't set?
Hopefully you "goto out".

Thanks,
NeilBrown

--Sig_/gV6CtUuAMDmgT4fABU94IIw
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOzx/jnsnt1WYoG5AQLP8w/+PtRLaIZfXTqix1cCGDNHXpAhxC+LEiHY
KEH3q92EMxRNVVfHaq84Gwa7mE72neubsTOqeYv96wrscDzDm7b6AZwnGCORqPdA
NkAHOmixyKgcAY00YPX6Co4QOxT6Y3vgIFoG0DtD0768D3ZDwVBhxtJacG42RXqy
xXjdaLhQiQkp2r+KP7OqRf77fOQV/e6IJQrU937snCuZrQjqTsUSsP6PkABqefsV
JvLM+6uKhi23tJ0Q8qP9jREFYVuWclTz2a329JzytwJnXQEpG0Mf5Omb3V4Mv4cZ
jVfLxRxqRLLWcajDmSYn2YbAJKGNmoftK93YtJhH2KQCMvZvOm1TldmvzBBcDQPE
AWjGtu5n2HqzGqA9RQSqgh00NPcvuULEBqdPw6nL404G2E/yAhABPVYXXM0T4ut+
fk/RkvelL7zTCoOCcVFG24g7r8EZx9vGpC3+dXbg4Myedu92XPDbpJ76LQcy5QQn
zhcMqa3RMg8OLxkNqLqm9SiBVsnrFabfMzG+duVv1aolbbdDBN9cyoTZyifKWFzv
j5zFmK3azJWB8dYL8afmlJJQwOToayO/stoleuQKyHuOdMbPZfjvTtU731u92sHj
uKvvPkukm5JjTWV9dP4CtTc6i/lXJKwJDxCCm3mOFWbL95D0+FG8mZLbNpuSBED6
RlzK/7xsFFQ=
=a4yV
-----END PGP SIGNATURE-----

--Sig_/gV6CtUuAMDmgT4fABU94IIw--
