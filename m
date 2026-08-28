Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F36BC46D562
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 14:42:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787928150; cv=none; b=oTNuiGrWd53klzhX4xvWL7FlbgilLZyh2tUoBpswCir354D6e24k0rbJ5ItazljKMfrcocf+XOt4/9brUMfpoJjNLZ6JgSFN3xlBzXXeCIJveYCDuOEhEtjpsVhgSgS8htip70Cy7s357w02BQpkTtCILCJXwMT4ea8vXEExcaU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787928150; c=relaxed/simple;
	bh=FgekZkCBBXdf7cwYT/+MZegQu6T+ZB3UFGKlibLFRWU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=iFk6yjuzKe1q8t1A5y4DIXF5hq0iXzGViD2oad9/WKtM1IM/w5HzWPy1bLXr/KAt5lQYMiP7B4xImZKrCPMyzvr6o4D+cGl1I4J3dR8v8h2R1UXY2K4KtD73DwsthPEaBJlv6Ul0Y2FghFw0b3TT6Lw8ei2uxuyPKqUSCKCNRF0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ja18iit/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ja18iit/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 053751F000E9;
	Fri, 28 Aug 2026 14:42:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787928148;
	bh=FMS5q0erf8m1kz94ONWC+u7/s7LWXFEIlZA4e+TiLFw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=ja18iit/mgXbBu4tFt2rw+PPlu9hpCKiiUlJL4x7nBYTURQ2GJ4tDTZ6zNNfVnXhq
	 wW2P1zuY4eTbPau0sIr4hG3GFe1Di2kZPE5wCPIMRBU/Z/MshwVSOVRKiWDjgl5kb7
	 WwJgiQ+K5yGYtZsonH2x9AY8a0E9DWhiS6vdwxj1Zij2sXtLzNMY1F4b/mu/bUIVip
	 auTaYpqrEVBo5JutVGiUu9sCO3HBaAGaj9wweXCa7J4XXKUkAu4h0+ImeSSk/S014v
	 zgHBh1xRYn557edFhF/96oSRWOUql3yhl2zn1NoaOAIwJv45jQQaKEgk49eOUyrdCZ
	 Y0CfZPJotYJlQ==
Message-ID: <9768f723beed33c611e36075504b07b1e8e493a7.camel@kernel.org>
Subject: Re: [PATCH 2/2] NFSD: Rework be32 nfserr definitions
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 28 Aug 2026 10:42:26 -0400
In-Reply-To: <20260826194444.148243-2-cel@kernel.org>
References: <20260826194444.148243-1-cel@kernel.org>
	 <20260826194444.148243-2-cel@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-08-26 at 15:44 -0400, Chuck Lever wrote:
> fs/nfsd/nfserr.h builds NFSD's internal __be32 nfserr_* values
> by wrapping the version-agnostic NFSERR_* status codes from
> uapi/linux/nfs.h in cpu_to_be32(), which it reaches through its
> include of linux/nfs.h.
>=20
> A subsequent patch replaces that include with the xdrgen-generated
> linux/sunrpc/xdrgen/nfs2.h. The generated header re-supplies
> only the eighteen NFSv2 status codes; the NFSv3 and NFSv4 codes
> that nfserr.h also uses (NFSERR_INVAL, NFSERR_JUKEBOX,
> NFSERR_RESOURCE, and the rest) would be left undeclared.
>=20
> Respell those definitions in terms of the version-specific
> NFS3ERR_* and NFS4ERR_* codes from linux/nfs3.h and linux/nfs4.h,
> and switch the one bare NFSERR_MOVED in nfs4xdr.c to NFS4ERR_MOVED.
> The wire values are unchanged; NFSD no longer depends on the
> version-agnostic NFSv3 and NFSv4 names.
>=20
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfs4xdr.c |   2 +-
>  fs/nfsd/nfserr.h  | 129 +++++++++++++++++++++++-----------------------
>  2 files changed, 66 insertions(+), 65 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 5bfbeb87394e..00ddaac499c6 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3213,7 +3213,7 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u=
32 *bmval1, u32 *bmval2, u32
>  	    *bmval1 & ~WORD1_ABSENT_FS_ATTRS) {
>  		if (*bmval0 & FATTR4_WORD0_RDATTR_ERROR ||
>  	            *bmval0 & FATTR4_WORD0_FS_LOCATIONS)
> -			*rdattr_err =3D NFSERR_MOVED;
> +			*rdattr_err =3D NFS4ERR_MOVED;
>  		else
>  			return nfserr_moved;
>  	}
> diff --git a/fs/nfsd/nfserr.h b/fs/nfsd/nfserr.h
> index 9b9df7aab220..d1c434b834b2 100644
> --- a/fs/nfsd/nfserr.h
> +++ b/fs/nfsd/nfserr.h
> @@ -11,76 +11,77 @@
>  #define LINUX_NFSD_NFSERR_H
> =20
>  #include <linux/nfs.h>
> +#include <linux/nfs3.h>
>  #include <linux/nfs4.h>
> =20
>  /*
>   * These macros provide pre-xdr'ed values for faster operation.
>   */
> -#define	nfs_ok			cpu_to_be32(NFS_OK)
> -#define	nfserr_perm		cpu_to_be32(NFSERR_PERM)
> -#define	nfserr_noent		cpu_to_be32(NFSERR_NOENT)
> -#define	nfserr_io		cpu_to_be32(NFSERR_IO)
> -#define	nfserr_nxio		cpu_to_be32(NFSERR_NXIO)
> -#define	nfserr_acces		cpu_to_be32(NFSERR_ACCES)
> -#define	nfserr_exist		cpu_to_be32(NFSERR_EXIST)
> -#define	nfserr_xdev		cpu_to_be32(NFSERR_XDEV)
> -#define	nfserr_nodev		cpu_to_be32(NFSERR_NODEV)
> -#define	nfserr_notdir		cpu_to_be32(NFSERR_NOTDIR)
> -#define	nfserr_isdir		cpu_to_be32(NFSERR_ISDIR)
> -#define	nfserr_inval		cpu_to_be32(NFSERR_INVAL)
> -#define	nfserr_fbig		cpu_to_be32(NFSERR_FBIG)
> -#define	nfserr_nospc		cpu_to_be32(NFSERR_NOSPC)
> -#define	nfserr_rofs		cpu_to_be32(NFSERR_ROFS)
> -#define	nfserr_mlink		cpu_to_be32(NFSERR_MLINK)
> -#define	nfserr_nametoolong	cpu_to_be32(NFSERR_NAMETOOLONG)
> -#define	nfserr_notempty		cpu_to_be32(NFSERR_NOTEMPTY)
> -#define	nfserr_dquot		cpu_to_be32(NFSERR_DQUOT)
> -#define	nfserr_stale		cpu_to_be32(NFSERR_STALE)
> -#define	nfserr_remote		cpu_to_be32(NFSERR_REMOTE)
> -#define	nfserr_wflush		cpu_to_be32(NFSERR_WFLUSH)
> -#define	nfserr_badhandle	cpu_to_be32(NFSERR_BADHANDLE)
> -#define	nfserr_notsync		cpu_to_be32(NFSERR_NOT_SYNC)
> -#define	nfserr_badcookie	cpu_to_be32(NFSERR_BAD_COOKIE)
> -#define	nfserr_notsupp		cpu_to_be32(NFSERR_NOTSUPP)
> -#define	nfserr_toosmall		cpu_to_be32(NFSERR_TOOSMALL)
> -#define	nfserr_serverfault	cpu_to_be32(NFSERR_SERVERFAULT)
> -#define	nfserr_badtype		cpu_to_be32(NFSERR_BADTYPE)
> -#define	nfserr_jukebox		cpu_to_be32(NFSERR_JUKEBOX)
> -#define	nfserr_denied		cpu_to_be32(NFSERR_DENIED)
> -#define	nfserr_deadlock		cpu_to_be32(NFSERR_DEADLOCK)
> -#define nfserr_expired          cpu_to_be32(NFSERR_EXPIRED)
> -#define	nfserr_bad_cookie	cpu_to_be32(NFSERR_BAD_COOKIE)
> -#define	nfserr_same		cpu_to_be32(NFSERR_SAME)
> -#define	nfserr_clid_inuse	cpu_to_be32(NFSERR_CLID_INUSE)
> -#define	nfserr_stale_clientid	cpu_to_be32(NFSERR_STALE_CLIENTID)
> -#define	nfserr_resource		cpu_to_be32(NFSERR_RESOURCE)
> -#define	nfserr_moved		cpu_to_be32(NFSERR_MOVED)
> -#define	nfserr_nofilehandle	cpu_to_be32(NFSERR_NOFILEHANDLE)
> -#define	nfserr_minor_vers_mismatch	cpu_to_be32(NFSERR_MINOR_VERS_MISMATC=
H)
> -#define nfserr_share_denied	cpu_to_be32(NFSERR_SHARE_DENIED)
> -#define nfserr_stale_stateid	cpu_to_be32(NFSERR_STALE_STATEID)
> -#define nfserr_old_stateid	cpu_to_be32(NFSERR_OLD_STATEID)
> -#define nfserr_bad_stateid	cpu_to_be32(NFSERR_BAD_STATEID)
> -#define nfserr_bad_seqid	cpu_to_be32(NFSERR_BAD_SEQID)
> -#define	nfserr_symlink		cpu_to_be32(NFSERR_SYMLINK)
> -#define	nfserr_not_same		cpu_to_be32(NFSERR_NOT_SAME)
> -#define nfserr_lock_range	cpu_to_be32(NFSERR_LOCK_RANGE)
> -#define	nfserr_restorefh	cpu_to_be32(NFSERR_RESTOREFH)
> -#define	nfserr_attrnotsupp	cpu_to_be32(NFSERR_ATTRNOTSUPP)
> -#define	nfserr_bad_xdr		cpu_to_be32(NFSERR_BAD_XDR)
> -#define	nfserr_openmode		cpu_to_be32(NFSERR_OPENMODE)
> -#define	nfserr_badowner		cpu_to_be32(NFSERR_BADOWNER)
> -#define	nfserr_locks_held	cpu_to_be32(NFSERR_LOCKS_HELD)
> -#define	nfserr_op_illegal	cpu_to_be32(NFSERR_OP_ILLEGAL)
> -#define	nfserr_grace		cpu_to_be32(NFSERR_GRACE)
> -#define	nfserr_no_grace		cpu_to_be32(NFSERR_NO_GRACE)
> -#define	nfserr_reclaim_bad	cpu_to_be32(NFSERR_RECLAIM_BAD)
> -#define	nfserr_badname		cpu_to_be32(NFSERR_BADNAME)
> -#define	nfserr_admin_revoked	cpu_to_be32(NFS4ERR_ADMIN_REVOKED)
> -#define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
> -#define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
> -#define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
> +#define	nfs_ok				cpu_to_be32(NFS_OK)
> +#define	nfserr_perm			cpu_to_be32(NFSERR_PERM)
> +#define	nfserr_noent			cpu_to_be32(NFSERR_NOENT)
> +#define	nfserr_io			cpu_to_be32(NFSERR_IO)
> +#define	nfserr_nxio			cpu_to_be32(NFSERR_NXIO)
> +#define	nfserr_acces			cpu_to_be32(NFSERR_ACCES)
> +#define	nfserr_exist			cpu_to_be32(NFSERR_EXIST)
> +#define	nfserr_xdev			cpu_to_be32(NFS3ERR_XDEV)
> +#define	nfserr_nodev			cpu_to_be32(NFSERR_NODEV)
> +#define	nfserr_notdir			cpu_to_be32(NFSERR_NOTDIR)
> +#define	nfserr_isdir			cpu_to_be32(NFSERR_ISDIR)
> +#define	nfserr_inval			cpu_to_be32(NFS3ERR_INVAL)
> +#define	nfserr_fbig			cpu_to_be32(NFSERR_FBIG)
> +#define	nfserr_nospc			cpu_to_be32(NFSERR_NOSPC)
> +#define	nfserr_rofs			cpu_to_be32(NFSERR_ROFS)
> +#define	nfserr_mlink			cpu_to_be32(NFS3ERR_MLINK)
> +#define	nfserr_nametoolong		cpu_to_be32(NFSERR_NAMETOOLONG)
> +#define	nfserr_notempty			cpu_to_be32(NFSERR_NOTEMPTY)
> +#define	nfserr_dquot			cpu_to_be32(NFSERR_DQUOT)
> +#define	nfserr_stale			cpu_to_be32(NFSERR_STALE)
> +#define	nfserr_remote			cpu_to_be32(NFS3ERR_REMOTE)
> +#define	nfserr_wflush			cpu_to_be32(NFSERR_WFLUSH)
> +#define	nfserr_badhandle		cpu_to_be32(NFS3ERR_BADHANDLE)
> +#define	nfserr_notsync			cpu_to_be32(NFS3ERR_NOT_SYNC)
> +#define	nfserr_badcookie		cpu_to_be32(NFS3ERR_BAD_COOKIE)
> +#define	nfserr_notsupp			cpu_to_be32(NFS3ERR_NOTSUPP)
> +#define	nfserr_toosmall			cpu_to_be32(NFS3ERR_TOOSMALL)
> +#define	nfserr_serverfault		cpu_to_be32(NFS3ERR_SERVERFAULT)
> +#define	nfserr_badtype			cpu_to_be32(NFS3ERR_BADTYPE)
> +#define	nfserr_jukebox			cpu_to_be32(NFS3ERR_JUKEBOX)
>  #define nfserr_delay			cpu_to_be32(NFS4ERR_DELAY)
> +#define	nfserr_same			cpu_to_be32(NFS4ERR_SAME)
> +#define	nfserr_denied			cpu_to_be32(NFS4ERR_DENIED)
> +#define	nfserr_deadlock			cpu_to_be32(NFS4ERR_DEADLOCK)
> +#define	nfserr_expired			cpu_to_be32(NFS4ERR_EXPIRED)
> +#define	nfserr_bad_cookie		cpu_to_be32(NFS4ERR_BAD_COOKIE)
> +#define	nfserr_clid_inuse		cpu_to_be32(NFS4ERR_CLID_INUSE)
> +#define	nfserr_stale_clientid		cpu_to_be32(NFS4ERR_STALE_CLIENTID)
> +#define	nfserr_resource			cpu_to_be32(NFS4ERR_RESOURCE)
> +#define	nfserr_moved			cpu_to_be32(NFS4ERR_MOVED)
> +#define	nfserr_nofilehandle		cpu_to_be32(NFS4ERR_NOFILEHANDLE)
> +#define	nfserr_minor_vers_mismatch	cpu_to_be32(NFS4ERR_MINOR_VERS_MISMAT=
CH)
> +#define nfserr_share_denied		cpu_to_be32(NFS4ERR_SHARE_DENIED)
> +#define nfserr_stale_stateid		cpu_to_be32(NFS4ERR_STALE_STATEID)
> +#define nfserr_old_stateid		cpu_to_be32(NFS4ERR_OLD_STATEID)
> +#define nfserr_bad_stateid		cpu_to_be32(NFS4ERR_BAD_STATEID)
> +#define nfserr_bad_seqid		cpu_to_be32(NFS4ERR_BAD_SEQID)
> +#define	nfserr_symlink			cpu_to_be32(NFS4ERR_SYMLINK)
> +#define	nfserr_not_same			cpu_to_be32(NFS4ERR_NOT_SAME)
> +#define nfserr_lock_range		cpu_to_be32(NFS4ERR_LOCK_RANGE)
> +#define	nfserr_restorefh		cpu_to_be32(NFS4ERR_RESTOREFH)
> +#define	nfserr_attrnotsupp		cpu_to_be32(NFS4ERR_ATTRNOTSUPP)
> +#define	nfserr_bad_xdr			cpu_to_be32(NFS4ERR_BADXDR)
> +#define	nfserr_openmode			cpu_to_be32(NFS4ERR_OPENMODE)
> +#define	nfserr_badowner			cpu_to_be32(NFS4ERR_BADOWNER)
> +#define	nfserr_locks_held		cpu_to_be32(NFS4ERR_LOCKS_HELD)
> +#define	nfserr_op_illegal		cpu_to_be32(NFS4ERR_OP_ILLEGAL)
> +#define	nfserr_grace			cpu_to_be32(NFS4ERR_GRACE)
> +#define	nfserr_no_grace			cpu_to_be32(NFS4ERR_NO_GRACE)
> +#define	nfserr_reclaim_bad		cpu_to_be32(NFS4ERR_RECLAIM_BAD)
> +#define	nfserr_badname			cpu_to_be32(NFS4ERR_BADNAME)
> +#define	nfserr_admin_revoked		cpu_to_be32(NFS4ERR_ADMIN_REVOKED)
> +#define	nfserr_cb_path_down		cpu_to_be32(NFS4ERR_CB_PATH_DOWN)
> +#define	nfserr_locked			cpu_to_be32(NFS4ERR_LOCKED)
> +#define	nfserr_wrongsec			cpu_to_be32(NFS4ERR_WRONGSEC)
>  #define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
>  #define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
>  #define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST=
)

Reviewed-by: Jeff Layton <jlayton@kernel.org>
