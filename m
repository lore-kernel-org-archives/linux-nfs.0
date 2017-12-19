Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51526 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751013AbdLSVPc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 16:15:32 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Wed, 20 Dec 2017 08:15:25 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: always set NFS_LOCK_LOST when a lock is lost.
In-Reply-To: <87r2rzo8qi.fsf@notabene.neil.brown.name>
References: <87r2rzo8qi.fsf@notabene.neil.brown.name>
Message-ID: <87bmiul8r6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 13 2017, NeilBrown wrote:

> There are 2 comments in the NFSv4 code which suggest that
> SIGLOST should possibly be sent to a process.  In these
> cases a lock has been lost.
> The current practice is to set NFS_LOCK_LOST so that
> read/write returns EIO when a lock is lost.
> So change these comments to code when sets NFS_LOCK_LOST.
>
> One case is when lock recovery after apparent server restart
> fails with NFS4ERR_DENIED, NFS4ERR_RECLAIM_BAD, or
> NFS4ERRO_RECLAIM_CONFLICT.  The other case is when a lock
> attempt as part of lease recovery fails with NFS4ERR_DENIED.
>
> In an ideal world, these should not happen.  However I have
> a packet trace showing an NFSv4.1 session getting
> NFS4ERR_BADSESSION after an extended network parition.  The
> NFSv4.1 client treats this like server reboot until/unless
> it get NFS4ERR_NO_GRACE, in which case it switches over to
> "nograce" recovery mode.  In this network trace, the client
> attempts to recover a lock and the server (incorrectly)
> reports NFS4ERR_DENIED rather than NFS4ERR_NO_GRACE.  This
> leads to the ineffective comment and the client then
> continues to write using the OPEN stateid.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> Note that I have not tested this as I do not have direct access to a
> faulty NFS server.  Once I get confirmation I will provide an update.

Hi,
 I have now received confirmation that this change does fix the locking
 behavior in this case where the server is returning the wrong error
 code.

Thanks,
NeilBrown


>
> NeilBrown
>
>  fs/nfs/nfs4proc.c  | 12 ++++++++----
>  fs/nfs/nfs4state.c |  5 ++++-
>  2 files changed, 12 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 56fa5a16e097..083802f7a1e9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2019,7 +2019,7 @@ static int nfs4_open_reclaim(struct nfs4_state_owne=
r *sp, struct nfs4_state *sta
>  	return ret;
>  }
>=20=20
> -static int nfs4_handle_delegation_recall_error(struct nfs_server *server=
, struct nfs4_state *state, const nfs4_stateid *stateid, int err)
> +static int nfs4_handle_delegation_recall_error(struct nfs_server *server=
, struct nfs4_state *state, const nfs4_stateid *stateid, struct file_lock *=
fl, int err)
>  {
>  	switch (err) {
>  		default:
> @@ -2066,7 +2066,11 @@ static int nfs4_handle_delegation_recall_error(str=
uct nfs_server *server, struct
>  			return -EAGAIN;
>  		case -ENOMEM:
>  		case -NFS4ERR_DENIED:
> -			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
> +			if (fl) {
> +				struct nfs4_lock_state *lsp =3D fl->fl_u.nfs4_fl.owner;
> +				if (lsp)
> +					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
> +			}
>  			return 0;
>  	}
>  	return err;
> @@ -2102,7 +2106,7 @@ int nfs4_open_delegation_recall(struct nfs_open_con=
text *ctx,
>  		err =3D nfs4_open_recover_helper(opendata, FMODE_READ);
>  	}
>  	nfs4_opendata_put(opendata);
> -	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
> +	return nfs4_handle_delegation_recall_error(server, state, stateid, NULL=
, err);
>  }
>=20=20
>  static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calld=
ata)
> @@ -6739,7 +6743,7 @@ int nfs4_lock_delegation_recall(struct file_lock *f=
l, struct nfs4_state *state,
>  	if (err !=3D 0)
>  		return err;
>  	err =3D _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
> -	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
> +	return nfs4_handle_delegation_recall_error(server, state, stateid, fl, =
err);
>  }
>=20=20
>  struct nfs_release_lockowner_data {
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index e4f4a09ed9f4..91a4d4eeb235 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1482,6 +1482,7 @@ static int nfs4_reclaim_locks(struct nfs4_state *st=
ate, const struct nfs4_state_
>  	struct inode *inode =3D state->inode;
>  	struct nfs_inode *nfsi =3D NFS_I(inode);
>  	struct file_lock *fl;
> +	struct nfs4_lock_state *lsp;
>  	int status =3D 0;
>  	struct file_lock_context *flctx =3D inode->i_flctx;
>  	struct list_head *list;
> @@ -1522,7 +1523,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *st=
ate, const struct nfs4_state_
>  		case -NFS4ERR_DENIED:
>  		case -NFS4ERR_RECLAIM_BAD:
>  		case -NFS4ERR_RECLAIM_CONFLICT:
> -			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
> +			lsp =3D fl->fl_u.nfs4_fl.owner;
> +			if (lsp)
> +				set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
>  			status =3D 0;
>  		}
>  		spin_lock(&flctx->flc_lock);
> --=20
> 2.14.0.rc0.dirty

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo5gW0ACgkQOeye3VZi
gbmDdw//flmnxJ41m/8cIadaQXiKzfGStzuiNZf+SxTMfEO6OP77gyz4bdR7s3Bi
aQBo4EzAyUez0QtoLNk47YgqYhcB11GP/Gy5KLHdOL6xB1CKYQi/6Pc+Y+thMly5
LglDoilz4YkWnMDAcTN7UaRbn8j8w1jxF05yHhbYr2qcq9Kw8ODAV62GyZwc8OgU
tsK/RVw2vwxmpqqDCl4xfuYpDwC73XHT6Bvq59lei0LQfw/WYtaV2RL5oHIXTFEs
YnnGNaemumHAy7IiwmV9PHJxfipgvo0q/jO15ZB07f3C+FbxEEToaXCoTGnrtvud
LbSSwiTNx/ay1Yy5FChvmiwHHoLvNGtJzuuBS/+ys3flp4bkYcn603vrBO2QaWFl
IRbzgZ1Y2PfkRbzgi4zoKfYuGFPFGjldWH8RKb1sf8q3KL+ds1/797Fe3G2o21aH
Eni4srMCzL2xU60cQ9hFIJlr62j1GR5C8Y5RgvaGBJHJgs22fyBKFexvN3uuDU4G
9DmqeT3CW4bg7P4DUDzNEK/RYy5yYH/AmjfKGuhCN9up5lxMt+0ily0noBvjVwNG
UBwD8i20ObCpu5lRvJRZOMBhmP+SCfPEAnE5AHkEiFl1+DF3y5U9sKI8w9T02mYU
hY0PfYZn0Kg7/13XC/wT77Org5LyJ43klF/O9qAKJrNPxz4qoUI=
=qU8A
-----END PGP SIGNATURE-----
--=-=-=--
