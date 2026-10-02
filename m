Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 871583BFE3F
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 07:20:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790925622; cv=none; b=KQ+4Cl16qFFSFS3aNECbbHDZjAkCUs83WjPdVDvq+reQVw0vY1QTkwg2Vsi/6N+Q/D8WR33D4T4NI1vwNnX24IjIyyGaaRHGarc0DwFFHBjARMPbqw/9o9cLyFvuKalU5o/BqKFzaIlN/AracMHB7e/z7M+7IOrbUR45Me0bv+U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790925622; c=relaxed/simple;
	bh=WG1fLkkb2B1qJuD0v6HV+6meCD2Qqsv/I2NnKEeNAx0=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ZRfKm58G/T9SBEZifh9wu0+V2G0dNx4iiY5YStdhmsVPUONVxZy4k3IyGaUxslaqhQV60Wq2AvxJnbDSGS5h+AnQNEUi5EkUSFR7qsqlzkTVH7i/DZiufTbtMGqxmqCbcopIX31Wz8RqCxik2Zd/H7VfinikR+W1+UQWoh4F2gs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F61mqJDd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F61mqJDd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7A72D1F000FF;
	Fri,  2 Oct 2026 07:20:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790925620;
	bh=2ksT7AtWgEjRX52ALuK99iYSiCNVf6xZrHdk8vgEMgE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=F61mqJDddLR9C2KV/3o+uqA1shBTy73NgG1pxTjzysB9aq4AHqtBMf+ZVZwaHQ/H5
	 aspPOT7TB11I2Fg/TTLuLcJQt0NxrrwAvArIYZtSwGjGtP7k+Qn5R/HbxvIT0I4fvg
	 59Kp+4wmwkBPhqmShGSWgWiK7QvH0/BU6FoCv9teoqyauChqxLv3IZxaz8IsNpS4Ca
	 xukcJKiE7UXiqYB/QTycNYNCMpiHceIb5t6hnuYtn0N9BcB5+ovHlbYIXoo8nl7UMm
	 Iyu/RgUrljJziuPaALdjNkt+OMEi5mguRxNT1A319pB5z4FKpKg+O1eEx0lHuQpM/6
	 qGyX+gqseYixA==
Message-ID: <6ad7a2fd190a94aa3b2592314b79109d21f38436.camel@kernel.org>
Subject: Re: [PATCH v2] nfsd: pin source client while using COPY_NOTIFY
 stateid
From: Jeff Layton <jlayton@kernel.org>
To: Hyunsol Mun <muumthf@gmail.com>, linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>, 	bobtobabz@gmail.com
Date: Fri, 02 Oct 2026 08:20:16 +0100
In-Reply-To: <20260930053915.299362-1-muumthf@gmail.com>
References: <20260930053915.299362-1-muumthf@gmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-09-30 at 14:39 +0900, Hyunsol Mun wrote:
> A COPY_NOTIFY token can resolve to a stateid owned by the source client.
> find_cpntf_state() drops its source-client reference before returning
> that stateid, so concurrent source-client expiry can free sc_client
> while stateid validation or the caller still uses the stateid.
>=20
> Add a local nfsd4_get_client() helper as the counterpart to
> nfsd4_put_client(). Return a paired client reference from
> nfs4_preprocess_stateid_op() when lookup crosses through COPY_NOTIFY
> state. Keep it until the caller releases the returned stateid; internal
> and error paths release it locally.
>=20
> An unprivileged NFSv4.2 client with access to the exported file can execu=
te
> the OPEN, COPY_NOTIFY, source-client replacement, and token READ sequence=
.
> Four hundred natural trials reached the protocol path without reproducing
> the report, so a reliable timing-assistance-free trigger was not
> demonstrated.
>=20
> For deterministic validation, a test-only kprobe delayed nfsd_permission(=
)
> after COPY_NOTIFY state lookup. The module only widened the race window; =
it
> did not allocate, free, or modify an NFSD object. Validation used the
> nfsd-testing base recorded below. On the unmodified KASAN kernel, five
> trials registered four delayed calls and reproduced the source-client
> use-after-free in nfs4_put_stid(). With this patch, five trials registere=
d
> five delayed calls and produced no KASAN report or kernel failure. Three
> token READs returned NFS4_OK with 23 bytes; two returned NFS4ERR_EXPIRED =
as
> client replacement won the race.
>=20
> The full KASAN kernel built with CONFIG_WERROR without a compiler
> diagnostic. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests passed=
.
> A source reproducer, timing-module source, complete logs, and the kernel
> configuration are available privately on request.
>=20
> The vulnerability research and validation were conducted by members of
> the Tobabz team as part of the Best of the Best 15th program.
>=20
> Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
> Assisted-by: LLM
> Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
> ---
> Changes in v2:
> - Describe current timing-assisted baseline and patched results.
> - Add full-build and NFSv4.2/NFSv3 smoke-test results.
> - Keep nfsd4_get_client() local to nfs4state.c.
>=20
>  fs/nfsd/nfs4proc.c  | 31 +++++++++++++++++++++----------
>  fs/nfsd/nfs4state.c | 34 +++++++++++++++++++++++++++-------
>  fs/nfsd/state.h     |  2 +-
>  3 files changed, 49 insertions(+), 18 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 7df60abfb..d5b5f59f1 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1144,7 +1144,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_com=
pound_state *cstate,
>  	/* check stateid */
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
>  					&read->rd_stateid, RD_STATE,
> -					&read->rd_nf, NULL);
> +					&read->rd_nf, NULL, NULL);
> =20
>  	read->rd_rqstp =3D rqstp;
>  	read->rd_fhp =3D &cstate->current_fh;
> @@ -1342,6 +1342,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
>  		.na_dpacl	=3D posix_acl_dup(setattr->sa_dpacl),
>  	};
>  	bool save_no_wcc, deleg_attrs;
> +	struct nfs4_client *stid_clp =3D NULL;
>  	struct nfs4_stid *st =3D NULL;
>  	struct inode *inode;
>  	__be32 status =3D nfs_ok;
> @@ -1358,7 +1359,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
> =20
>  		status =3D nfs4_preprocess_stateid_op(rqstp, cstate,
>  				&cstate->current_fh, &setattr->sa_stateid,
> -				flags, NULL, &st);
> +				flags, NULL, &st, &stid_clp);
>  		if (status)
>  			goto out_err;
>  	}
> @@ -1375,8 +1376,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4=
_compound_state *cstate,
>  			}
>  		}
>  	}
> -	if (st)
> +	if (st) {
>  		nfs4_put_stid(st);
> +		if (stid_clp)
> +			nfsd4_put_client(stid_clp);
> +	}
>  	if (status)
>  		goto out_err;
> =20
> @@ -1439,6 +1443,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_co=
mpound_state *cstate,
>  	struct nfsd4_write *write =3D &u->write;
>  	stateid_t *stateid =3D &write->wr_stateid;
>  	struct nfs4_stid *stid =3D NULL;
> +	struct nfs4_client *stid_clp =3D NULL;
>  	struct nfsd_file *nf =3D NULL;
>  	__be32 status =3D nfs_ok;
>  	unsigned long cnt;
> @@ -1451,13 +1456,16 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
>  	trace_nfsd_write_start(rqstp, &cstate->current_fh,
>  			       write->wr_offset, cnt);
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
> -						stateid, WR_STATE, &nf, &stid);
> +						stateid, WR_STATE, &nf, &stid,
> +						&stid_clp);
>  	if (status)
>  		return status;
> =20
>  	if (stid) {
>  		nfsd4_file_mark_deleg_written(stid->sc_file);
>  		nfs4_put_stid(stid);
> +		if (stid_clp)
> +			nfsd4_put_client(stid_clp);
>  	}
> =20
>  	write->wr_how_written =3D write->wr_stable_how;
> @@ -1484,12 +1492,12 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct =
nfsd4_compound_state *cstate,
>  		return nfserr_nofilehandle;
> =20
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
> -					    src_stateid, RD_STATE, src, NULL);
> +					    src_stateid, RD_STATE, src, NULL, NULL);
>  	if (status)
>  		goto out;
> =20
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
> -					    dst_stateid, WR_STATE, dst, NULL);
> +					    dst_stateid, WR_STATE, dst, NULL, NULL);
>  	if (status)
>  		goto out_put_src;
> =20
> @@ -1954,7 +1962,7 @@ nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
>  	/* Verify the destination stateid and set dst struct file*/
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
>  					    &copy->cp_dst_stateid,
> -					    WR_STATE, &copy->nf_dst, NULL);
> +					    WR_STATE, &copy->nf_dst, NULL, NULL);
>  	if (status)
>  		goto out;
> =20
> @@ -2498,12 +2506,13 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct =
nfsd4_compound_state *cstate,
>  	struct nfsd4_copy_notify *cn =3D &u->copy_notify;
>  	__be32 status;
>  	struct nfsd_net *nn =3D net_generic(SVC_NET(rqstp), nfsd_net_id);
> +	struct nfs4_client *stid_clp =3D NULL;
>  	struct nfs4_stid *stid =3D NULL;
>  	struct nfs4_cpntf_state *cps;
> =20
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
>  					&cn->cpn_src_stateid, RD_STATE, NULL,
> -					&stid);
> +					&stid, &stid_clp);
>  	if (status)
>  		return status;
>  	if (!stid)
> @@ -2536,6 +2545,8 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nf=
sd4_compound_state *cstate,
>  	nfs4_put_cpntf_state(nn, cps);
>  out:
>  	nfs4_put_stid(stid);
> +	if (stid_clp)
> +		nfsd4_put_client(stid_clp);
>  	return status;
>  }
> =20
> @@ -2548,7 +2559,7 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd=
4_compound_state *cstate,
> =20
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
>  					    &fallocate->falloc_stateid,
> -					    WR_STATE, &nf, NULL);
> +					    WR_STATE, &nf, NULL, NULL);
>  	if (status !=3D nfs_ok)
>  		return status;
> =20
> @@ -2612,7 +2623,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_com=
pound_state *cstate,
> =20
>  	status =3D nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_f=
h,
>  					    &seek->seek_stateid,
> -					    RD_STATE, &nf, NULL);
> +					    RD_STATE, &nf, NULL, NULL);
>  	if (status)
>  		return status;
> =20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bbc16dd22..43906f87e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2805,6 +2805,15 @@ static void __free_client(struct kref *k)
>  	kmem_cache_free(client_slab, clp);
>  }
> =20
> +/**
> + * nfsd4_get_client - acquire a reference on an nfs4_client
> + * @clp: the client to be acquired
> + */
> +static void nfsd4_get_client(struct nfs4_client *clp)
> +{
> +	kref_get(&clp->cl_nfsdfs.cl_ref);
> +}
> +

If you're going to add this helper, then you should convert all of the
other places that call kref_get() on this object to use it, ideally in
a separate patch.

>  /**
>   * nfsd4_put_client - release a reference on an nfs4_client
>   * @clp: the client to be released
> @@ -8504,7 +8513,8 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stat=
eid_t *st,
>  }
> =20
>  static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
> -			       struct nfs4_stid **stid)
> +			       struct nfs4_stid **stid,
> +			       struct nfs4_client **stid_clp)
>  {
>  	__be32 status;
>  	struct nfs4_cpntf_state *cps =3D NULL;
> @@ -8524,10 +8534,13 @@ static __be32 find_cpntf_state(struct nfsd_net *n=
n, stateid_t *st,
>  	*stid =3D find_stateid_by_type(found, &cps->cp_p_stateid,
>  				     SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
>  				     0);
> -	if (*stid)
> +	if (*stid) {
> +		nfsd4_get_client(found);
> +		*stid_clp =3D found;
>  		status =3D nfs_ok;
> -	else
> +	} else {
>  		status =3D nfserr_bad_stateid;
> +	}
> =20
>  	put_client_renew(found);
>  out:
> @@ -8551,6 +8564,7 @@ void nfs4_put_cpntf_state(struct nfsd_net *nn, stru=
ct nfs4_cpntf_state *cps)
>   * @flags: flags describing type of operation to be done
>   * @nfp: optional nfsd_file return pointer (may be NULL)
>   * @cstid: optional returned nfs4_stid pointer (may be NULL)
> + * @cstid_clp: client reference paired with @cstid (required with @cstid=
)
>   *
>   * Given info from the client, look up a nfs4_stid for the operation. On
>   * success, it returns a reference to the nfs4_stid and/or the nfsd_file
> @@ -8560,10 +8574,11 @@ __be32
>  nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
>  		stateid_t *stateid, int flags, struct nfsd_file **nfp,
> -		struct nfs4_stid **cstid)
> +		struct nfs4_stid **cstid, struct nfs4_client **cstid_clp)

The bug seems possible (esp given the fault-injected reproducer), but
this function is really devolving into a big mess. It would be very
nice to move the COPY-specific code into a dedicated helper that is
only called from the COPY-related codepaths. Consider reorganizing this
code along those lines.

>  {
>  	struct net *net =3D SVC_NET(rqstp);
>  	struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> +	struct nfs4_client *stid_clp =3D NULL;
>  	struct nfs4_stid *s =3D NULL;
>  	__be32 status;
> =20
> @@ -8579,7 +8594,7 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>  				SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
>  				0, &s, nn);
>  	if (status =3D=3D nfserr_bad_stateid)
> -		status =3D find_cpntf_state(nn, stateid, &s);
> +		status =3D find_cpntf_state(nn, stateid, &s, &stid_clp);
>  	if (status)
>  		return status;
>  	status =3D nfsd4_stid_check_stateid_generation(stateid, s,
> @@ -8605,11 +8620,16 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp=
,
>  		status =3D nfs4_check_file(rqstp, fhp, s, nfp, flags);
>  out:
>  	if (s) {
> -		if (!status && cstid)
> +		if (!status && cstid) {
>  			*cstid =3D s;
> -		else
> +			*cstid_clp =3D stid_clp;
> +			stid_clp =3D NULL;
> +		} else {
>  			nfs4_put_stid(s);
> +		}
>  	}
> +	if (stid_clp)
> +		nfsd4_put_client(stid_clp);
>  	return status;
>  }
> =20
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 1a0da82cb..7910dabb4 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -911,7 +911,7 @@ struct nfsd4_async_copy;
>  extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
>  		stateid_t *stateid, int flags, struct nfsd_file **filp,
> -		struct nfs4_stid **cstid);
> +		struct nfs4_stid **cstid, struct nfs4_client **cstid_clp);
>  __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
>  			    stateid_t *stateid, unsigned short typemask,
>  			    unsigned short statusmask,
>=20
> base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8

--=20
Jeff Layton <jlayton@kernel.org>
