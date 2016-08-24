Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Schumaker Anna
	<anna.schumaker@netapp.com>,
        Mayhew Scott <smayhew@redhat.com>
Subject: Re: [PATCH] NFS: Don't invalidate directory mapping until attributes
 expire
Date: Wed, 24 Aug 2016 17:49:59 +0000
Message-ID: <1D0703D0-AC52-4449-BA13-9E924E5DFAD8@primarydata.com>
References: <67cfa1f7f028229bfd4b1ac2619bc85b9e34ef7f.1472059583.git.bcodding@redhat.com>
In-Reply-To: <67cfa1f7f028229bfd4b1ac2619bc85b9e34ef7f.1472059583.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 24, 2016, at 13:27, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> Commit 311324ad1713666a6e803aecf0d4e1a136a5b34a ("NFS: Be more aggressive
> in using readdirplus for 'ls -l' situations") removed the optimization
> added by commit 07b5ce8ef2d87f1914054804720d6facbaa3f4ce ("NFS: Make nfs_=
readdir
> revalidate less often") to bypass the revalidation of the directory mappi=
ng
> on subsequent calls into nfs_readdir().  Add that optimization back here.
>=20
> A directory modified once every second and containing 40k entries takes m=
y
> system around 80 seconds to list.  With this patch, that time is reduced =
to
> 7 seconds.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/dir.c | 13 +------------
> 1 file changed, 1 insertion(+), 12 deletions(-)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 19d93d0cd400..9a036dc6caa3 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -872,17 +872,6 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
> =09goto out;
> }
>=20
> -static bool nfs_dir_mapping_need_revalidate(struct inode *dir)
> -{
> -=09struct nfs_inode *nfsi =3D NFS_I(dir);
> -
> -=09if (nfs_attribute_cache_expired(dir))
> -=09=09return true;
> -=09if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
> -=09=09return true;
> -=09return false;
> -}
> -
> /* The file offset position represents the dirent entry number.  A
>    last cookie cache takes care of the common case of reading the
>    whole directory.
> @@ -914,7 +903,7 @@ static int nfs_readdir(struct file *file, struct dir_=
context *ctx)
> =09desc->decode =3D NFS_PROTO(inode)->decode_dirent;
> =09desc->plus =3D nfs_use_readdirplus(inode, ctx) ? 1 : 0;
>=20
> -=09if (ctx->pos =3D=3D 0 || nfs_dir_mapping_need_revalidate(inode))
> +=09if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode))
> =09=09res =3D nfs_revalidate_mapping(inode, file->f_mapping);
> =09if (res < 0)
> =09=09goto out;
> --=20
> 2.5.5
>=20

NACK.

As already discussed, this patch will break the functionality introduced in=
 commit 311324ad1713. You need at least to ensure that we respect nfs_force=
_use_readdirplus().
