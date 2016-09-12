Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:30757 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758284AbcILMS1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2016 08:18:27 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: =?Windows-1252?Q?Gr=FCnbacher_Andreas?= <agruenba@redhat.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: Set s_time_gran consistently on NFSv2
Date: Mon, 12 Sep 2016 12:18:15 +0000
Message-ID: <8348CFA2-E94A-4544-9D9D-CB4FEC6A304C@primarydata.com>
References: <1473678968-13124-1-git-send-email-agruenba@redhat.com>
In-Reply-To: <1473678968-13124-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andreas,

> On Sep 12, 2016, at 07:16, Andreas Gruenbacher <agruenba@redhat.com> wrot=
e:
>=20
> Hi Trond and Anna,
>=20
> is it true that nfs_clone_super accidentally sets s_time_gran to 1 on NFS=
v2?
> If so, could you please merge the following patch?
>=20
> Thanks,
> Andreas
>=20
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
> fs/nfs/super.c | 25 +++++++++----------------
> 1 file changed, 9 insertions(+), 16 deletions(-)
>=20
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d396013..4c72fec 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2312,6 +2312,15 @@ inline void nfs_initialise_sb(struct super_block *=
sb)
> {
> =09struct nfs_server *server =3D NFS_SB(sb);
>=20
> +=09if (server->nfs_client->rpc_ops->version !=3D 2) {
> +=09=09sb->s_time_gran =3D 1;
> +=09=09/*
> +=09=09 * The VFS shouldn't apply the umask to mode bits. We will do
> +=09=09 * so ourselves when necessary.
> +=09=09 */
> +=09=09sb->s_flags |=3D MS_POSIXACL;
> +=09}
> +
> =09sb->s_magic =3D NFS_SUPER_MAGIC;
>=20
> =09/* We probably want something more informative here */
> @@ -2342,14 +2351,6 @@ void nfs_fill_super(struct super_block *sb, struct=
 nfs_mount_info *mount_info)
> =09if (data && data->bsize)
> =09=09sb->s_blocksize =3D nfs_block_size(data->bsize, &sb->s_blocksize_bi=
ts);
>=20
> -=09if (server->nfs_client->rpc_ops->version !=3D 2) {
> -=09=09/* The VFS shouldn't apply the umask to mode bits. We will do
> -=09=09 * so ourselves when necessary.
> -=09=09 */
> -=09=09sb->s_flags |=3D MS_POSIXACL;
> -=09=09sb->s_time_gran =3D 1;
> -=09}
> -
>  =09nfs_initialise_sb(sb);
> }
> EXPORT_SYMBOL_GPL(nfs_fill_super);
> @@ -2367,14 +2368,6 @@ void nfs_clone_super(struct super_block *sb, struc=
t nfs_mount_info *mount_info)
> =09sb->s_maxbytes =3D old_sb->s_maxbytes;
> =09sb->s_xattr =3D old_sb->s_xattr;
> =09sb->s_op =3D old_sb->s_op;
> -=09sb->s_time_gran =3D 1;
> -
> -=09if (server->nfs_client->rpc_ops->version !=3D 2) {
> -=09=09/* The VFS shouldn't apply the umask to mode bits. We will do
> -=09=09 * so ourselves when necessary.
> -=09=09 */
> -=09=09sb->s_flags |=3D MS_POSIXACL;
> -=09}
>=20
>  =09nfs_initialise_sb(sb);
> }
> =97=20

Actually, we should be using the fsinfo->time_delta in nfs_server_set_fsinf=
o() to set sb->s_time_gran to the precise value supported by the filesystem=
.
We can then fake up a value for NFSv2, since its =91statfs=92 implementatio=
n doesn=92t return one.

Cheers
  Trond

