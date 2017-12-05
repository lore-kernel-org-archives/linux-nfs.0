Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45105 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752387AbdLEXIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 18:08:06 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Wed, 06 Dec 2017 10:07:56 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC v4 5/9] NFS: Kill RPCs for the duration of umount
In-Reply-To: <20171117174552.18722-6-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com> <20171117174552.18722-6-JPEWhacker@gmail.com>
Message-ID: <87lgigsrhv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 17 2017, Joshua Watt wrote:

> RPCs are now killed for the duration of the umount operation when
> MNT_FORCE is specified. Specifically, if the umount flags are MNT_FORCE
> | MNT_DETACH, all future RPCs will be killed.
>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  fs/nfs/internal.h  |  1 +
>  fs/nfs/nfs4super.c |  1 +
>  fs/nfs/super.c     | 36 +++++++++++++++++++++++++++++-------
>  3 files changed, 31 insertions(+), 7 deletions(-)
>
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index f9a4a5524bd5..3ec165368a08 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -461,6 +461,7 @@ extern void nfs_pageio_reset_read_mds(struct nfs_page=
io_descriptor *pgio);
>=20=20
>  /* super.c */
>  void nfs_umount_begin(struct super_block *);
> +void nfs_umount_end(struct super_block *sb);
>  int  nfs_statfs(struct dentry *, struct kstatfs *);
>  int  nfs_show_options(struct seq_file *, struct dentry *);
>  int  nfs_show_devname(struct seq_file *, struct dentry *);
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 6fb7cb6b3f4b..e9788f9c3394 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -56,6 +56,7 @@ static const struct super_operations nfs4_sops =3D {
>  	.statfs		=3D nfs_statfs,
>  	.evict_inode	=3D nfs4_evict_inode,
>  	.umount_begin	=3D nfs_umount_begin,
> +	.umount_end	=3D nfs_umount_end,
>  	.show_options	=3D nfs_show_options,
>  	.show_devname	=3D nfs_show_devname,
>  	.show_path	=3D nfs_show_path,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 216f67d628b3..71361ca6d6b4 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -315,6 +315,7 @@ const struct super_operations nfs_sops =3D {
>  	.statfs		=3D nfs_statfs,
>  	.evict_inode	=3D nfs_evict_inode,
>  	.umount_begin	=3D nfs_umount_begin,
> +	.umount_end	=3D nfs_umount_end,
>  	.show_options	=3D nfs_show_options,
>  	.show_devname	=3D nfs_show_devname,
>  	.show_path	=3D nfs_show_path,
> @@ -890,6 +891,15 @@ int nfs_show_stats(struct seq_file *m, struct dentry=
 *root)
>  }
>  EXPORT_SYMBOL_GPL(nfs_show_stats);
>=20=20
> +static void
> +kill_rpc(struct rpc_clnt *rpc)
> +{
> +	if (!IS_ERR(rpc)) {
> +		atomic_inc(&rpc->cl_kill_new_tasks);
> +		rpc_killall_tasks(rpc);
> +	}
> +}
> +
>  /*
>   * Begin unmount by attempting to remove all automounted mountpoints we =
added
>   * in response to xdev traversals and referrals
> @@ -897,19 +907,31 @@ EXPORT_SYMBOL_GPL(nfs_show_stats);
>  void nfs_umount_begin(struct super_block *sb)
>  {
>  	struct nfs_server *server;
> -	struct rpc_clnt *rpc;
>=20=20
>  	server =3D NFS_SB(sb);
>  	/* -EIO all pending I/O */
> -	rpc =3D server->client_acl;
> -	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc);
> -	rpc =3D server->client;
> -	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc);
> +	kill_rpc(server->client_acl);
> +	kill_rpc(server->client);
>  }
>  EXPORT_SYMBOL_GPL(nfs_umount_begin);
>=20=20
> +static void
> +restore_rpc(struct rpc_clnt *rpc)
> +{
> +	if (!IS_ERR(rpc))
> +		__atomic_add_unless(&rpc->cl_kill_new_tasks, -1, 0);

Why use __atomic_add_unless() instead of the more obvious
atomic_add_unless()?
The only difference is the return value and as you ignore that, it isn't
a difference.

Thanks,
NeilBrown


> +}
> +
> +void
> +nfs_umount_end(struct super_block *sb)
> +{
> +	struct nfs_server *server =3D NFS_SB(sb);
> +
> +	restore_rpc(server->client_acl);
> +	restore_rpc(server->client);
> +}
> +EXPORT_SYMBOL_GPL(nfs_umount_end);
> +
>  static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
>  {
>  	struct nfs_parsed_mount_data *data;
> --=20
> 2.13.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlonJswACgkQOeye3VZi
gblgmA/9E9aW/3JtLzIUbsJLmk4IqSTmsUxR761phbqpYjd+huG4/Jkv7+AoeFva
rytlDFVOubV0QXyqCYjDlFH9K9X6WsspPt12C62yxt6s9H/ee9/pNjzbMjhQkCu0
c0cN+QIqVOwJJLI2NtDXufCUeP61FerkEr6dNDB7uCOH9u+4NCpvcVbqhWaKzCGy
6QBIXh96Tuy8GdDZ1zxenHrGD6RV6A7KQS1DkO5nabSAe7KmsNkTOkyWX9iKTBzv
Sr2rb2O5lUpQ8KAGGGV4q1OGCtpiaBvahhVsb6AQhtZ9JarWGmAQhnGh5ymRkpTC
u+CAa1roQu4rLJ9YUZEKsl9pRgIJrAbBCNg890qyAu2tC29NCR4jXPUMmVe81n21
9RPDHsZz3vw/2Jg8lvIJ6Bbld5exSeVfpplqSzHxKDBoQ7ivB2nVWHJJYsI4xTTB
VQxV71N9P6RqZNgldYjrZKTTLfWFi03b/OwNw54BCQhRXEpEBP1GA5TdTZ5oZZwF
3NzDAL6O8iHLNHwi/MdoQP7zQqGIKmRgq4qHeRyJIG8U0NZCj7nqAL6Mb36iqdji
Hs1zrPOb6VNw0qb0dj1M4Zje/xbvy38RJCmv78Am2FCjEfQXa8svJewMYEBflXuS
GUf3NaR2c2DZMCWZ2FfDQZBICnXfRNS6nZacsyTdC/BrL8EsBFY=
=Ifqr
-----END PGP SIGNATURE-----
--=-=-=--
