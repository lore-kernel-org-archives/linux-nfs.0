Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 20 Oct 2016 11:57:55 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/6] NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
In-Reply-To: <147633280750.766.16214787133000729977.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble> <147633280750.766.16214787133000729977.stgit@noble>
Message-ID: <87zilzx2ek.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 13 2016, NeilBrown wrote:

> The only time that a lock_context is not immediately available is in
> setattr, and now that it has an open_context, it can easily find one
> with nfs_get_lock_context.
> This removes the need for the on-stack nfs_lockowner.
>
> This change is preparation for correctly support flock stateids.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4_fs.h   |    2 +-
>  fs/nfs/nfs4proc.c  |   15 ++++++---------
>  fs/nfs/nfs4state.c |   11 +++++------
>  3 files changed, 12 insertions(+), 16 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 9b3a82abab07..7784b79915e1 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -457,7 +457,7 @@ extern void nfs41_handle_server_scope(struct nfs_clie=
nt *,
>  extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
>  extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_loc=
k *fl);
>  extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
> -		const struct nfs_lockowner *, nfs4_stateid *,
> +		const struct nfs_lock_context *, nfs4_stateid *,
>  		struct rpc_cred **);
>=20=20
>  extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *count=
er, gfp_t gfp_mask);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 950b25413bb4..3c2f11189794 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2926,12 +2926,13 @@ static int _nfs4_do_setattr(struct inode *inode,
>  	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegati=
on_cred)) {
>  		/* Use that stateid */
>  	} else if (truncate && ctx !=3D NULL) {
> -		struct nfs_lockowner lockowner =3D {
> -			.l_owner =3D current->files,
> -		};
> +		struct nfs_lock_context *l_ctx;
>  		if (!nfs4_valid_open_stateid(ctx->state))
>  			return -EBADF;
> -		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, &lockowner,
> +		l_ctx =3D nfs_get_lock_context(ctx);
> +		if (IS_ERR(l_ctx))
> +			return PTR_ERR(l_ctx);
> +		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
>  				&arg->stateid, &delegation_cred) =3D=3D -EIO)
>  			return -EBADF;

Oops...
I have an nfs_get_lock_context() here with no matching
nfs_put_lock_context();


I've merged:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3c2f11189794..be4e3d9de1eb 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2932,8 +2932,10 @@ static int _nfs4_do_setattr(struct inode *inode,
 		l_ctx =3D nfs_get_lock_context(ctx);
 		if (IS_ERR(l_ctx))
 			return PTR_ERR(l_ctx);
=2D		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
=2D				&arg->stateid, &delegation_cred) =3D=3D -EIO)
+		status =3D nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
+						&arg->stateid, &delegation_cred);
+		nfs_put_lock_context(l_ctx);
+		if (status =3D=3D -EIO)
 			return -EBADF;
 	} else
 		nfs4_stateid_copy(&arg->stateid, &zero_stateid);

into that patch and pushed out a new

  git://neil.brown.name/linux tags/nfs-flock-fix

 (3f5546538d7c678b82d10ce6add29a6d92565f1e)


Please let me know if I should re-post the series.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYCBaTAAoJEDnsnt1WYoG5PNsP/2uoWBPlJSdRWmnGH7Xu1pZ6
fN6b9B3xisYtA4je8OY/M+4W7mfCrxNzkc3qmd3nHwwOIBNKjiof4bwr46hXoDLm
cFLZvxasQf99eowwKZJQgA3t8gJYGSEzTQ/a09eUWyn2Qrm4Zka+APsT4RYZS+GR
ktMpnNewb7f6W2RtFzf5X1m365JMoswejKcf+wa5RhOHoZICukhBBwYyVrAnf8jC
sImHOGuc0jVaJEYLXTVEpUwEcVMPR0b/lnU/LQoUJ00K8yOipDRmyzNEYKNwfFFE
CceESPLeWytVxW8avvHJxup/zHZTAyts+bPFwKbz67bUt9PcoVjKu0EjfDFEa1Ni
0evoOB8oG13c52rjqz8QiorV8C88+3dWfcVUxGfTKfKlkISLlu5OgMYpF8JLCo+y
yGXPrpLCuLkMOwswMjoCb3jWNyQTQrggJkKpECSxT43poH8tgDjmuHY9JlS/yHI2
igmGqVAihyE3kf631Ms28djwzlRI+eERn8TUgL2YTHiGOnfbNiopzNsdsM+wsH5I
RG2LT0lpPWBnccC/KEO2pfQbsqoO2BqjzKW9YvU1JYYP4M3mEKNSUpOdA4zQLLSf
t+FOKjhqrhAcqmbR23wuYxOuqGnWMCNxYx+0iY83ayZnV0hMlm4hKHJsFn0n6KMr
CxxZ8LcgLL6TvY/Xq4Ip
=AKDn
-----END PGP SIGNATURE-----
--=-=-=--
