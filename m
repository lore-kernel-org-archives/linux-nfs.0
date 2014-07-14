Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:56989 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847AbaGNNAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 09:00:31 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so3124298qaq.25
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 06:00:31 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 14 Jul 2014 09:00:28 -0400
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140714090028.6f04fd2c@tlielax.poochiereds.net>
In-Reply-To: <20140714223513.47807c98@notabene.brown>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
	<20140714223513.47807c98@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/7oYy9cPls=.whDZ5dBL2yPt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/7oYy9cPls=.whDZ5dBL2yPt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 Jul 2014 22:35:13 +1000
NeilBrown <neilb@suse.de> wrote:

> On Mon, 14 Jul 2014 08:14:55 -0400 Jeff Layton <jeff.layton@primarydata.c=
om>
> wrote:
>=20
> > On Mon, 14 Jul 2014 15:14:05 +1000
> > NeilBrown <neilb@suse.de> wrote:
> >=20
> > >=20
> > > If an 'open' of a file in an NFSv4 filesystem finds that the dentry is
> > > in cache, but the inode is stale (on the server), the dentry will not
> > > be re-validated immediately and may cause ESTALE to be returned to
> > > user-space.
> > >=20
> > > For a non-create 'open', do_last() calls lookup_fast() and on success
> > > will eventually call may_open() which calls into nfs_permission().
> > > If nfs_permission() makes the ACCESS call to the server it will get
> > > NFS4ERR_STALE, resulting in ESTALE from may_open() and thence from
> > > do_last().
> > > The retry-on-ESTALE in filename_lookup() will repeat exactly the same
> > > process because nothing in this path will invalidate the dentry due to
> > > the inode being stale, so the ESTALE will be returned.
> > >=20
> > > lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFSv4
> > > filesystem, that will succeed for regular files:
> > > 	/* Let f_op->open() actually open (and revalidate) the file */
> > >=20
> > > Unfortunately in the case of a STALE inode, f_op->open() never gets
> > > called.  If we teach nfs4_lookup_revalidate() to report a failure on
> > > NFS_STALE() inodes, then the dentry will be invalidated and a full
> > > lookup will be attempted.  The ESTALE errors go away.
> > >=20
> > >=20
> > > While I think this fix is correct, I'm not convinced that it is
> > > sufficient, particularly if lookupcache=3Dnone.
> > > The current code will fail an "open" is nfs_permission() fails,
> > > without having performed a LOOKUP. i.e. it will use the cache.
> > > nfs_lookup_revalidate will force a lookup before the permission check
> > > if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will not.
> > >=20
> >=20
> > This patch should make the code fall through to nfs_lookup_revalidate,
> > which would then force the lookup, right?
>=20
> Yes ... though maybe that's not what I really want to do.  I really wante=
d to
> just return '0', though I would need to check that is right in all cases.
>=20
> >=20
> > Also, I'm a little unclear...
> >=20
> > Why would may_open fail with ESTALE after the v4 OPEN succeeds? The
> > OPEN should be returning a filehandle and attributes for the inode
> > actually opened. It seems like we ought to be doing any permission
> > checks vs. that inode, not anything we had in cache. Presumably the
> > server is then holding it open so it shouldn't be stale.
>=20
> may_open is called *before* and v4 OPEN.
>=20
> In do_last, if the inode is already in cache, then
>   lookup_fast is called, which calls d_revalidate
>   then may_open (calls ->permission)
>   then finish_open which calls f_op->open
>=20
> Yes, we should be doing permission checking against whatever 'open' finds.
> But the VFS is structured to the the permission check after d_revalidate =
and
> before ->open.  So maybe d_revalidate needs to do the NFS open??
>=20

Ok, I see. Ugh, having the revalidate do the open sounds...messy.

A simpler fix might be to fix it so that an -ESTALE return from
may_open triggers a retry. Something like this maybe (probably
whitespace damaged, so just for discussion purposes):

diff --git a/fs/namei.c b/fs/namei.c
index 985c6f368485..c1657deea52c 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3045,8 +3045,13 @@ finish_open:
        }
 finish_open_created:
        error =3D may_open(&nd->path, acc_mode, open_flag);
-       if (error)
+       if (error) {
+               if (error =3D=3D -ESTALE)
+                       goto stale_open;
                goto out;
+       }
        file->f_path.mnt =3D nd->path.mnt;
        error =3D finish_open(file, nd->path.dentry, NULL, opened);
        if (error) {


...though might need to convert the ESTALE to EOPENSTALE there too, not
sure...

>=20
> >=20
> > Are we not properly updating the dcache (and attrcache) after the
> > OPEN reply?
>=20
> I think so, yes.  But in the problem case, we don't even send an OPEN
> request.
>=20
>=20
> >=20
> > >=20
> > > Signed-off-by: NeilBrown <neilb@suse.de>
> > >=20
> > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > index 4a3d4ef76127..4f7414afca27 100644
> > > --- a/fs/nfs/dir.c
> > > +++ b/fs/nfs/dir.c
> > > @@ -1563,6 +1563,8 @@ static int nfs4_lookup_revalidate(struct
> > > dentry *dentry, unsigned int flags) /* We cannot do exclusive
> > > creation on a positive dentry */ if (flags & LOOKUP_EXCL)
> > >  		goto no_open_dput;
> > > +	if (NFS_STALE(inode))
> > > +		goto no_open_dput;
> > > =20
> > >  	/* Let f_op->open() actually open (and revalidate) the
> > > file */ ret =3D 1;
> >=20
> > Looks legit to me too, but it seems like the inode could go stale
> > w/o us knowing after this point.
> >=20
> > Acked-by: Jeff Layton <jlayton@primarydata.com>
>=20
> Thanks,
> NeilBrown


--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/7oYy9cPls=.whDZ5dBL2yPt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTw9RsAAoJEAAOaEEZVoIVy1IQANCseB2MkPJepgXQeZM0wbVV
c0+NosubW3qULc5hDgjWmoTBZMhtgGiwXn6k5hRRTf47g4DOqoJzIgXFxBHL+zlY
BTJWLm2E2IZmYHLhDd5+BdkgnJrYXDD06u/QMXzOACQDRevdKryRiXwuzC/ziOnE
gIxsjAQjIRo6c1MUHe3RAvYn7vnvJiGJTQo2fjIkcAmiqlfW9kjdr5qexf30lWoE
2rPqjNB4ar6nUHk9fQwIGWo1WNrXkNvuSkb/mfmEVmCPyRTKaD1SELobH4jmVaNF
hVw7o5e4mVWl2aMHsOlQJ/bUjfgFotzxfoPG389WR2qSWfRWE5OZUFSXNf0x7nkh
y0MegqlF3Dj9YEMyLtciiCoB3qbGC8Kp6qCfJ7THkApBSY2V+InGN8nKvWtWebQB
ocpb9Bku5GHA9IUWpKyvNddwnnuoX5wrjcZjgPz8aBKCsUNxnGdR+flJz7+xLDqC
KrM/u4qD4lt4g1M0WKtBRpZht6mIwTCfg8/fnqC9SEWXQf0ywOkgf2ocCWSLqgsc
fwstywZTV73+zYsXdJmNo4Esbo0oYpaDYb9miZb06t8qfNU/ma5usgarDFfC7FDv
E3mAXMao6vpvH5d0eH+PsNnrF+Ubt9G/M2pj5hdS+CLrRNXdY8AVRAs/f4YjHbaS
y0eztc6e8XZa3/QJECuS
=RkPl
-----END PGP SIGNATURE-----

--Sig_/7oYy9cPls=.whDZ5dBL2yPt--
