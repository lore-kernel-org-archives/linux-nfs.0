Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34045 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317Ab1LABtd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 20:49:33 -0500
Date: Thu, 1 Dec 2011 12:49:22 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Rename dir on server can cause client to get ESTALE - this time
 with PATCH
Message-ID: <20111201124922.22e7d72f@notabene.brown>
In-Reply-To: <20111114131929.7b341444@notabene.brown>
References: <20111114131929.7b341444@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/mssf+YXLsj_1kj/lZcOeF+B"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mssf+YXLsj_1kj/lZcOeF+B
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 Nov 2011 13:19:29 +1100 NeilBrown <neilb@suse.de> wrote:

>=20
> hi,
>   I've run into another issue that seems to related to FS_REVAL_DOT.
>=20
> The script below makes the details precise, but the essence is that if I =
'cd'
> into a directory on the client, then rename it on the server, then it is
> possible that the client will start getting ESTALE when accessing '.' - e=
ven
> though the directory still exists.
>=20
> The ESTALE is generated because nfs_lookup_revalidate fails on the dentry=
, so=20
> complete_walk (in fs/namei.c) gets failure from d_revalidate() and so set=
s the
> status to -ESTALE.
>=20
> nfs_lookup_revalidate fails because when it repeats the lookup it sees a
> different directory (as you will see the script creates a new directory w=
ith
> the old name).
>=20
> I think it only makes sense to do a ->lookup revalidate of the dentry at =
the
> end of the path when there was a real non '.' or '..' name leading to the
> dentry.  If we were just looking up '.', we want to revalidate the inode,=
 but
> not the dentry.
>=20
> Unfortunately I cannot see how that distinction could be introduced into =
the
> current path-walk code.
>=20
> Any ideas?
>=20
> Thanks,
> NeilBrown
>=20
>=20
> SERVER=3Deli     # name of server.  ssh access required.
> DIR=3D/home      # directory on server to mount
> MPOINT=3D/mnt    # location on client to mount it.
> TMP=3D/neilb/tmp # path to scratch area in $DIR
>=20
> sudo umount $MPOINT
> sudo mount -o vers=3D3 $SERVER:$DIR $MPOINT
>=20
> cd /
> ssh $SERVER "rm -r $DIR$TMP/*dir*"
> ssh $SERVER "mkdir $DIR$TMP/adir"
> while [ ! -d $MPOINT$TMP/adir ];
> do echo -n . ; sleep 2;
> done
> cd $MPOINT$TMP/adir || exit
> echo "Entered directory"
> ls -la > /dev/null
> ssh $SERVER "cd $DIR$TMP; mv adir adir.moved"
> echo "Moved directory on server"
> ls -la > /dev/null
> echo -n "Waiting for move to be visible on client"
> while ls -la $MPOINT$TMP/adir >/dev/null 2>&1
> do echo -n .=20
>    sleep 3
>    (cd / ; ssh $SERVER "cd $DIR$TMP; mkdir bdir ; rmdir bdir" )
> done
> echo
> echo "Make replacement directory on server"
> (cd / ; ssh $SERVER "cd $DIR$TMP; mkdir adir")
> ls -la $MPOINT$TMP/adir
> ls -la
>=20


.. but answer came there none....

I've looked some more at the code and now would like to propose a patch.
This fixes it for me and feels right.

Opinions?

Thanks,
NeilBrown

=46rom 7abb2d77b4c8d8ca340e372447467d8a47241f83 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Wed, 30 Nov 2011 18:35:13 +1100
Subject: [PATCH] nfs - handle d_revalidate of 'dot' correctly.

When d_revalidate is called on a dentry because FS_REVAL_DOT is set
it isn't really appropriate to revalidate the name.

If the path was simply ".", then the current-working-directory could
have been renamed on the server and should still be accessible as "."
even if it has a new name.

If the path was "/some/long/path/.", then the final component ("path" in
this case) has already been revalidated and there is no particular
need to do it again.

If we change nd->last_type to refer to "the last component looked at"
rather than just "the last component", then these cases can be
detected by "nd->last_type !=3D LAST_NORM".

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/namei.c   |    2 +-
 fs/nfs/dir.c |    9 +++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 5008f01..6a720f7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1434,6 +1434,7 @@ static int link_path_walk(const char *name, struct na=
meidata *nd)
 			}
 		}
=20
+		nd->last_type =3D type;
 		/* remove trailing slashes? */
 		if (!c)
 			goto last_component;
@@ -1458,7 +1459,6 @@ static int link_path_walk(const char *name, struct na=
meidata *nd)
=20
 last_component:
 		nd->last =3D this;
-		nd->last_type =3D type;
 		return 0;
 	}
 	terminate_walk(nd);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac28990..f62827a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1137,6 +1137,15 @@ static int nfs_lookup_revalidate(struct dentry *dent=
ry, struct nameidata *nd)
 	if (NFS_STALE(inode))
 		goto out_bad;
=20
+	if (nd->last_type !=3D LAST_NORM) {
+		/* name not relevant, just inode */
+		error =3D nfs_revalidate_inode(NFS_SERVER(inode), inode);
+		if (error)
+			goto out_bad;
+		else
+			goto out_valid;
+	}
+
 	error =3D -ENOMEM;
 	fhandle =3D nfs_alloc_fhandle();
 	fattr =3D nfs_alloc_fattr();
--=20
1.7.7.3





--Sig_/mssf+YXLsj_1kj/lZcOeF+B
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTtbdIjnsnt1WYoG5AQJU+hAAqYh7yYxe8Z3uwei8gdJL4wGF5vS7e9Rm
1LvAzxQ0gyzozZvCRXMT/OasH3ByhVJqLJQr0xHQ536BrHRMOD8woK6dQHmU+AUF
FP8i7RvNuw6BrkwQs26HpE4qxMq+lUnTragjLLR4k2Ta1pnyoSFl5xc4KPP6T35A
kxbkPOVN1oTtUS8IfgJ4hI9S/Ys350M1huCdtsf7Gpb1ucYYF/y9LV6C/b/HQOk0
1X+SRcIIRChZu9LYVPpfPds1FlUDc2BImGqdEGgfFGdgHuh2vUGOvrHqmGpz7wEM
EwJJ8jlAC40HktkR/Y+VZYnzmAaRtYwqR+uxq4dc13rln+Y4sjw6YLHQsMfSrGjX
2q7a9rQThscJ6e9+6zxjmRSD30hZDCo/JMte2hk5QsVqhKKd684IGlLA+LmdMyK8
M2ZmWyFUVgpgRoyX2vxyELAi2dk19wrBSF3bmxfg85uYslWOwxmjRG03c009AGcd
jcJCTQLoHGvxGn5hTRQhEn9nMGjE/JRSY34F83ynbV7DBVci598dQP5K9Oq/5Qua
c8GPIFQLLofyKrAVUy7BZQAVOTfyPe2yt0uV84ZZcDh+46g0IPMiBEakFqHJiFhc
54N60Ew0E1cAVXtnAIonrrVbOxx4B5rKXcKLrA1GXYD1/witV1kYotqJg45hBSyd
VBmMqczAuO4=
=wqB6
-----END PGP SIGNATURE-----

--Sig_/mssf+YXLsj_1kj/lZcOeF+B--
