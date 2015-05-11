Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56041 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962AbbEKHDE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2015 03:03:04 -0400
Date: Mon, 11 May 2015 17:02:51 +1000
From: NeilBrown <neilb@suse.de>
To: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Cc: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NILFS2: support NFSv2 export
Message-ID: <20150511170251.4fb69e52@notabene.brown>
In-Reply-To: <20150511.013143.706881749197692581.konishi.ryusuke@lab.ntt.co.jp>
References: <20150508001142.31129.7604.stgit@notabene.brown>
	<20150508001623.31129.25102.stgit@notabene.brown>
	<20150511.013143.706881749197692581.konishi.ryusuke@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/35.LbBM347yd6zox5nPIdTU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/35.LbBM347yd6zox5nPIdTU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 May 2015 01:31:43 +0900 (JST) Ryusuke Konishi
<konishi.ryusuke@lab.ntt.co.jp> wrote:

> On Fri, 08 May 2015 10:16:23 +1000, NeilBrown <neilb@suse.de> wrote:
> > The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
> > that returned by encode_fh - it may be larger.
> >=20
> > With NFSv2, the filehandle is fixed length, so it may appear longer
> > than expected and be zero-padded.
> >=20
> > So we must test that fh_len is at least some value, not exactly equal
> > to it.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  fs/nilfs2/namei.c |    6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
> > index 22180836ec22..b65fb79d16fd 100644
> > --- a/fs/nilfs2/namei.c
> > +++ b/fs/nilfs2/namei.c
> > @@ -496,8 +496,8 @@ static struct dentry *nilfs_fh_to_dentry(struct sup=
er_block *sb, struct fid *fh,
> >  {
> >  	struct nilfs_fid *fid =3D (struct nilfs_fid *)fh;
> > =20
> > -	if ((fh_len !=3D NILFS_FID_SIZE_NON_CONNECTABLE &&
> > -	     fh_len !=3D NILFS_FID_SIZE_CONNECTABLE) ||
>=20
> > +	if ((fh_len < NILFS_FID_SIZE_NON_CONNECTABLE &&
> > +	     fh_len < NILFS_FID_SIZE_CONNECTABLE) ||
> >  	    (fh_type !=3D FILEID_NILFS_WITH_PARENT &&
> >  	     fh_type !=3D FILEID_NILFS_WITHOUT_PARENT))
> >  		return NULL;
>=20
> A bit weird.  "fh_len < NILFS_FID_SIZE_CONNECTABLE" implies "fh_len <
> NILFS_FID_SIZE_NON_CONNECTABLE".
>=20
> How about the following fix ?
>=20
> 	if ((fh_type !=3D FILEID_NILFS_WITH_PARENT ||
> 	     fh_len < NILFS_FID_SIZE_CONNECTABLE) &&
> 	    (fh_type !=3D FILEID_NILFS_WITHOUT_PARENT ||
> 	     fh_len < NILFS_FID_SIZE_NON_CONNECTABLE))
> 		return NULL;
>=20

Yes, weird.  The code only uses the early parts of the filehandle, so we
only need to complain if the fh_len is less than FILEID_NILFS_WITHOUT_PAREN=
T.

So I'd prefer:

@@ -496,8 +496,7 @@ static struct dentry *nilfs_fh_to_dentry(struct super_b=
lock *sb, struct fid *fh,
 {
        struct nilfs_fid *fid =3D (struct nilfs_fid *)fh;
=20
-       if ((fh_len !=3D NILFS_FID_SIZE_NON_CONNECTABLE &&
-            fh_len !=3D NILFS_FID_SIZE_CONNECTABLE) ||
+       if (fh_len < NILFS_FID_SIZE_NON_CONNECTABLE ||
            (fh_type !=3D FILEID_NILFS_WITH_PARENT &&
             fh_type !=3D FILEID_NILFS_WITHOUT_PARENT))
                return NULL;


Would you be OK with that?  If so I'll resend.

Thanks,
NeilBrown

--Sig_/35.LbBM347yd6zox5nPIdTU
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVVBUGznsnt1WYoG5AQJSNhAAw7yPbb31Q3bO0qM2CygGzjb9TKaaCWwG
xj3P1mXLl+v8HCBOoQrrupA/UjQLKzvELW62KvQmywlyY73nSAZnYQ5y2fnrAgYg
7I0pOPwXtE3nof0kNgLdiKDZdMdgGLXANnOrLy8lzelXvmIEZRhH4i/Hakjfe/9E
nxRLlYdQAjo6FUadIQP9OMmogqz/ztX4leSto9HsfpM3f5R0bImK56NTzMynlUr+
FOf4xvQKEFombS8HQc/VDX1LYWYCeBt66I0h8WySWyd6WNssnBALiWcAPue4nNas
DDyeetLjeoNUYfUyCF+xjbB5yo9fZ1K2CmWIJEBtFQlFMC8TZYA6dKX0sWxPicxm
QDVhSRxt7nLU+BwQiGjJcNLpGxmanvd1HcZbww7dUerCTeoyJMhRqo4i7Rvg+iDg
acTsF0U62DRY5VXqc7x2DLlpYGAni6bV+Ur5sktJVCtn18nWcnReYWeqo65dnAo7
qVX7TFMIFGeGWPp/IJ+dOcszNbCA4lJnKUHLCza28KZ8fHUyAzvDhz5M97ZAyE/1
R4zelmnpxEezZv/eWM9SYsoEnKZzhDFbIKVZs82efC9oe+s5h2MQovKWdBv8ESow
lqxlnv5Eu75/TDEfOhvaYWsIJYAdexmJxChfb5vyuE0dpwJKV27fNss43cO4q6D8
RG5pbUxlcE8=
=Qrom
-----END PGP SIGNATURE-----

--Sig_/35.LbBM347yd6zox5nPIdTU--
