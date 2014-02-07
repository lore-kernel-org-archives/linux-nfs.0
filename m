Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58170 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbaBGEVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Feb 2014 23:21:16 -0500
Date: Fri, 7 Feb 2014 15:21:05 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Do not set NFS_INO_INVALID_LABEL unless server
 supports labeled NFS
Message-ID: <20140207152105.2f0970e1@notabene.brown>
In-Reply-To: <1391716418-7353-1-git-send-email-trond.myklebust@primarydata.com>
References: <20140206135101.1cc83442@notabene.brown>
	<1391716418-7353-1-git-send-email-trond.myklebust@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/gGS.QZlT1FfR972AjAqVmZ_"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/gGS.QZlT1FfR972AjAqVmZ_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu,  6 Feb 2014 14:53:38 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> Commit aa9c2669626c (NFS: Client implementation of Labeled-NFS) introduces
> a performance regression. When nfs_zap_caches_locked is called, it sets
> the NFS_INO_INVALID_LABEL flag irrespectively of whether or not the
> NFS server supports security labels. Since that flag is never cleared,
> it means that all calls to nfs_revalidate_inode() will now trigger
> an on-the-wire GETATTR call.
>=20
> This patch ensures that we never set the NFS_INO_INVALID_LABEL unless the
> server advertises support for labeled NFS.
> It also causes nfs_setsecurity() to clear NFS_INO_INVALID_LABEL when it
> has successfully set the security label for the inode.
> Finally it gets rid of the NFS_INO_INVALID_LABEL cruft from nfs_update_in=
ode,
> which has nothing to do with labeled NFS.
>=20
> Reported-by: Neil Brown <neilb@suse.de>
> Cc: stable@vger.kernel.org # 3.11+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>=20
> Hi Neil,
> Does this fix the GETATTR regression that you reported?

Yes, thanks.
With this patch I don't get streams of GETATTR requests after the READDIR
request which I previously fixed with that oneline change in inode.c

Tested-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown


>=20
> Cheers
>  Trond
>=20
>  fs/nfs/inode.c    | 14 ++++++++++----
>  fs/nfs/internal.h |  9 +++++++++
>  2 files changed, 19 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 29cb93653b3c..4636b828e957 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -169,7 +169,6 @@ static void nfs_zap_caches_locked(struct inode *inode)
>  	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
>  		nfs_fscache_invalidate(inode);
>  		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR
> -					| NFS_INO_INVALID_LABEL
>  					| NFS_INO_INVALID_DATA
>  					| NFS_INO_INVALID_ACCESS
>  					| NFS_INO_INVALID_ACL
> @@ -177,10 +176,10 @@ static void nfs_zap_caches_locked(struct inode *ino=
de)
>  		nfs_zap_readdir_cookie(nfsi);
>  	} else
>  		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR
> -					| NFS_INO_INVALID_LABEL
>  					| NFS_INO_INVALID_ACCESS
>  					| NFS_INO_INVALID_ACL
>  					| NFS_INO_REVAL_PAGECACHE;
> +	nfs_zap_label_cache_locked(nfsi);
>  }
> =20
>  void nfs_zap_caches(struct inode *inode)
> @@ -272,6 +271,13 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  }
> =20
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +static void nfs_clear_label_invalid(struct inode *inode)
> +{
> +	spin_lock(&inode->i_lock);
> +	NFS_I(inode)->cache_validity &=3D ~NFS_INO_INVALID_LABEL;
> +	spin_unlock(&inode->i_lock);
> +}
> +
>  void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
>  					struct nfs4_label *label)
>  {
> @@ -289,6 +295,7 @@ void nfs_setsecurity(struct inode *inode, struct nfs_=
fattr *fattr,
>  					__func__,
>  					(char *)label->label,
>  					label->len, error);
> +		nfs_clear_label_invalid(inode);
>  	}
>  }
> =20
> @@ -1654,7 +1661,7 @@ static int nfs_update_inode(struct inode *inode, st=
ruct nfs_fattr *fattr)
>  		inode->i_blocks =3D fattr->du.nfs2.blocks;
> =20
>  	/* Update attrtimeo value if we're out of the unstable period */
> -	if (invalid & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL)) {
> +	if (invalid & NFS_INO_INVALID_ATTR) {
>  		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
>  		nfsi->attrtimeo =3D NFS_MINATTRTIMEO(inode);
>  		nfsi->attrtimeo_timestamp =3D now;
> @@ -1667,7 +1674,6 @@ static int nfs_update_inode(struct inode *inode, st=
ruct nfs_fattr *fattr)
>  		}
>  	}
>  	invalid &=3D ~NFS_INO_INVALID_ATTR;
> -	invalid &=3D ~NFS_INO_INVALID_LABEL;
>  	/* Don't invalidate the data if we were to blame */
>  	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
>  				|| S_ISLNK(inode->i_mode)))
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 8b5cc04a8611..fafdddac8271 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -279,9 +279,18 @@ static inline void nfs4_label_free(struct nfs4_label=
 *label)
>  	}
>  	return;
>  }
> +
> +static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
> +{
> +	if (nfs_server_capable(&nfsi->vfs_inode, NFS_CAP_SECURITY_LABEL))
> +		nfsi->cache_validity |=3D NFS_INO_INVALID_LABEL;
> +}
>  #else
>  static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *ser=
ver, gfp_t flags) { return NULL; }
>  static inline void nfs4_label_free(void *label) {}
> +static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
> +{
> +}
>  #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
> =20
>  /* proc.c */


--Sig_/gGS.QZlT1FfR972AjAqVmZ_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvRfMTnsnt1WYoG5AQLpKA/9FitFHuXVjLHyirbNsqovbgBBLUD12DiC
0OIvvKFA1ElNRaTUoBUms9mPcCz+9KBWIUEU4qUJQVFRLSnDGdSrZJypc7tVd7cp
Fts0vA6d9bJPvMaIz3frHGED4xFBLRzBKdPU8AZNEYI+fkFq2PZpE6VDPYas8OBk
x+zFEWR31NxAr8k7QkzdPH5uayOdTyWypSa3qYYHfJmMDOOcyeuMTOGl9z2PW9+T
ViO70JzNP7WsBz1WawGQuBx2L6C5+fDlJqEQBpPu6d/3rkWHiItXKMBFLzQq7B+l
9DsM1+ErVF/6IErd6t0FabTb7GNHmOZtm5O3JcqkBZ1iHxmVi/HxW5m1XT3w7BuN
tEp6/Ic/wXqO05za+7NWSQ0dabIOM3+nvDoqOgxCIJbfJ5xlJdf+2g7cevUHc+vy
PugX6OZMv9QT8FuvBrXPMRuojIw6lMbmkFN5B+K08cgP6kLO2FX5JyUn0gJ0EnFp
INs409Z7d5iBOtB1cU+e7iTRgkril3RMxVuJ/ah8I2zHW1Y1ji/28+Q6RzK9SCew
A8U5HL1rv1tUVz7JNoGdQ/ZFeVweJSi4y9isd2Fes1iKzEGq6qGjoQMclxFWbE3H
F6Vb3yk1/fNQPf0SxTl+3TVgINCpO/P/0GTCbn5fOXb3FPL8564sKzj+slpnuRz2
B2U/2IdL4WY=
=j3Lj
-----END PGP SIGNATURE-----

--Sig_/gGS.QZlT1FfR972AjAqVmZ_--
