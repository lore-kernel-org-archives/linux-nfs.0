Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Concurrent `ls` takes out the thrash
Date: Wed, 7 Dec 2016 22:41:59 +0000
Message-ID: <6C5DA8AC-9A42-45FA-892C-E9597A7F7AC9@primarydata.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com>
 <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
 <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com>
In-Reply-To: <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 7, 2016, at 17:34, Benjamin Coddington <bcodding@redhat.com> wrote=
:
>=20
> From: "Benjamin Coddington" <bcodding@redhat.com>
>=20
> So, I've got the following patch, and it seems to work fine for the origi=
nal
> workload.  However, if I use ~20 procs started 2 seconds apart, I can sti=
ll
> sometimes get into the state where the machine takes a very long time (5 =
- 8
> minutes).  I wonder if I am getting into a state were vmscan is reclaimin=
g
> pages while I'm trying to fill them up.  So.. I'll do a bit more debuggin=
g
> and re-post this if I feel like it is still the right approach.
>=20
> Adding an int to nfs_open_dir_context puts it at 60 bytes here.  Probably
> could have added a unsigned long flags and used bits for the duped stuff =
as
> well, but it was uglier that way, so I left it.  I like how duped carries
> -1, 0, and >1 information without having flag defines cluttering everywhe=
re.
>=20
> Ben
>=20
> 8<-----------------------------------------------------------------------=
-
>=20
> From 5b3e747a984ec966e8c742d8f4fe4b08e1c93acd Mon Sep 17 00:00:00 2001
> Message-Id: <5b3e747a984ec966e8c742d8f4fe4b08e1c93acd.1481149380.git.bcod=
ding@redhat.com>
> From: Benjamin Coddington <bcodding@redhat.com>
> Date: Wed, 7 Dec 2016 16:23:30 -0500
> Subject: [PATCH] NFS: Move readdirplus flag to directory context
>=20
> For a concurrent 'ls -l' workload, processes can stack up in nfs_readdir(=
)
> both waiting on the next page and taking turns filling the next page from
> XDR, but only one of them will have desc->plus set because setting it
> clears the flag on the directory.  If a page is filled by a process that
> doesn't have desc->plus set then the next pass through lookup() will caus=
e
> it to dump the entire page cache with nfs_force_use_readdirplus().  Then
> the next readdir starts all over filling the pagecache.  Forward progress
> happens, but only after many steps back re-filling the pagecache.
>=20
> Fix this by moving the flag to use readdirplus to each open directory
> context.
>=20
> Suggested-by: Trond Myklebust <trondmy@primarydata.com>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/dir.c           | 39 ++++++++++++++++++++++++---------------
> include/linux/nfs_fs.h |  1 +
> 2 files changed, 25 insertions(+), 15 deletions(-)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 7483722162fa..818172606fed 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -78,6 +78,7 @@ static struct nfs_open_dir_context *alloc_nfs_open_dir_=
context(struct inode *dir
> =09=09ctx->dir_cookie =3D 0;
> =09=09ctx->dup_cookie =3D 0;
> =09=09ctx->cred =3D get_rpccred(cred);
> +=09=09ctx->use_readdir_plus =3D 0;
> =09=09spin_lock(&dir->i_lock);
> =09=09list_add(&ctx->list, &nfsi->open_files);
> =09=09spin_unlock(&dir->i_lock);
> @@ -443,17 +444,35 @@ int nfs_same_file(struct dentry *dentry, struct nfs=
_entry *entry)
> }
>=20
> static
> -bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx)
> +bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx,
> +=09=09=09struct nfs_open_dir_context *dir_ctx)
> {
> =09if (!nfs_server_capable(dir, NFS_CAP_READDIRPLUS))
> =09=09return false;
> -=09if (test_and_clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags))
> +=09if (xchg(&dir_ctx->use_readdir_plus, 0))
> =09=09return true;
> =09if (ctx->pos =3D=3D 0)
> =09=09return true;
> =09return false;
> }
>=20
> +static
> +void nfs_set_readdirplus(struct inode *dir, int force)
> +{
> +=09struct nfs_inode *nfsi =3D NFS_I(dir);
> +=09struct nfs_open_dir_context *ctx;
> +
> +=09if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
> +=09    !list_empty(&nfsi->open_files)) {
> +=09=09spin_lock(&dir->i_lock);
> +=09=09list_for_each_entry(ctx, &nfsi->open_files, list)
> +=09=09=09ctx->use_readdir_plus =3D 1;
> +=09=09spin_unlock(&dir->i_lock);
> +=09=09if (force)
> +=09=09=09invalidate_mapping_pages(dir->i_mapping, 0, -1);
> +=09}
> +}
> +
> /*
>  * This function is called by the lookup and getattr code to request the
>  * use of readdirplus to accelerate any future lookups in the same
> @@ -461,11 +480,7 @@ bool nfs_use_readdirplus(struct inode *dir, struct d=
ir_context *ctx)
>  */
> void nfs_advise_use_readdirplus(struct inode *dir)
> {
> -=09struct nfs_inode *nfsi =3D NFS_I(dir);
> -
> -=09if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
> -=09    !list_empty(&nfsi->open_files))
> -=09=09set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
> +=09nfs_set_readdirplus(dir, 0);
> }
>=20
> /*
> @@ -478,13 +493,7 @@ void nfs_advise_use_readdirplus(struct inode *dir)
>  */
> void nfs_force_use_readdirplus(struct inode *dir)
> {
> -=09struct nfs_inode *nfsi =3D NFS_I(dir);
> -
> -=09if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
> -=09    !list_empty(&nfsi->open_files)) {
> -=09=09set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
> -=09=09invalidate_mapping_pages(dir->i_mapping, 0, -1);
> -=09}
> +=09nfs_set_readdirplus(dir, 1);
> }
>=20
> static
> @@ -921,7 +930,7 @@ static int nfs_readdir(struct file *file, struct dir_=
context *ctx)
> =09desc->ctx =3D ctx;
> =09desc->dir_cookie =3D &dir_ctx->dir_cookie;
> =09desc->decode =3D NFS_PROTO(inode)->decode_dirent;
> -=09desc->plus =3D nfs_use_readdirplus(inode, ctx) ? 1 : 0;
> +=09desc->plus =3D nfs_use_readdirplus(inode, ctx, dir_ctx) ? 1 : 0;

This fixes desc->plus at the beginning of the readdir() call. Perhaps we sh=
ould instead check the value of ctx->use_readdir_plus in the call to nfs_re=
addir_xdr_filler(), and just resetting cts->use_readdir_plus at the very en=
d of nfs_readdir()?

>=20
> =09if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode))
> =09=09res =3D nfs_revalidate_mapping(inode, file->f_mapping);
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index cb631973839a..fe06c1dd1737 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -89,6 +89,7 @@ struct nfs_open_dir_context {
> =09__u64 dir_cookie;
> =09__u64 dup_cookie;
> =09signed char duped;
> +=09int use_readdir_plus;
> };
>=20
> /*
> --=20
> 2.5.5
>=20
