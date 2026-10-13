Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D2BD4ED1B4;
	Tue, 13 Oct 2026 11:03:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791889429; cv=none; b=eVdmTDpYlIq/V23IP2bqyInfayGAK1VFagT+Usz/QsG5gOh1hGO8heXxJKTNr2ebfa4MhJC9QJYJ9wmFaCYgD2ktCd28g+ZQNRpJZRta4fJ+a9xhsyIk/lRg6enPBNylkqTrv1b5Fmqv9LWPdvoRvKcJJf0sY0olkVGfZB5u72w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791889429; c=relaxed/simple;
	bh=IcUpQx0cfcB4WZ9TjO1JA0D5c8EoXbDr5mb/HcHZSnM=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=pemSlm+ys3Qr/5PJOvV1yow0aO8GU1Z9T8OAKuSi3YH9xiTfPKjZcna1898SrwqZvXcmClurORc4xxrI+Ie6gjrtl/7mUKpxCLk14ZmgK/hoP0owLq7E15Bouocrm4cB/QwTNPDD3OqzI0Q+25BUIBwF/GHNUQyM/5WloVUpjL4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FSJl9bP4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FSJl9bP4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0B3991F000FF;
	Tue, 13 Oct 2026 11:03:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791889425;
	bh=BOfuxyaoyfJYpHpkro6gMv4TI/nBVVskOfYfcXUMaoI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=FSJl9bP4Ug4HxP6HQ7f7RSAFuqtl9YQnkMSRwnrAnfBryghdz3ZI9+kX3VYzHl+wd
	 FKzYl//lPzpSjLSTQO/1EToIhySylTfIMo69FCBg+P4MMpEaACUtw10dtp5ave9iJC
	 0trZLxOBs8BaoxM0595F8zTqLlSJ0bj410Iod7chyyIDSR+9vxjkc1/m0B4tWYq6as
	 897Hv0NZXsiEIi4gvQwcEOgCKVCQo8nbxSwnGl0xw+KF2YMUQPavRECpHsPIpCXOuT
	 gfvGTiNMn2rQJI5FYfqGJOYo8+gtKoPjcP7XVTu49TuStx8IjOAtDs+wrUEcnG1amR
	 0Lxt5IggyE3Iw==
Message-ID: <3a6b84453aaa75b654155a699d4f85735df9c48d.camel@kernel.org>
Subject: Re: [PATCH v2] nfsd: prevent a double put of revoked layout stateids
From: Jeff Layton <jlayton@kernel.org>
To: Jinpyo Lee <bint4b13@gmail.com>, linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>, 	linux-kernel@vger.kernel.org,
 bobtobabz@gmail.com, stable@vger.kernel.org
Date: Tue, 13 Oct 2026 07:03:43 -0400
In-Reply-To: <20261013060021.46543-1-bint4b13@gmail.com>
References: <133aa8197620ef4f36a48faa62c207f5ee12c0a0.camel@kernel.org>
	 <20261013060021.46543-1-bint4b13@gmail.com>
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

On Tue, 2026-10-13 at 15:00 +0900, Jinpyo Lee wrote:
> nfsd4_free_stateid() finds an admin-revoked layout stateid with
> find_stateid_locked(), which does not acquire a reference. The layout
> case drops cl_lock without marking the stateid closed, then stops fence
> work and calls nfs4_put_stid() without owning a reference. Concurrent
> disposal can therefore access a freed layout stateid or drop a reference
> owned by another holder.
>=20
> Mark the layout stateid CLOSED under cl_lock so only one disposal caller
> proceeds. Take a temporary reference before dropping cl_lock and hold it
> while stopping fence work and draining the remaining layout segments,
> then release that reference with the final put. This keeps the stateid
> alive even though its IDR owns no reference and its layout segments are
> being removed.
>=20
> Use cl_lock for the CLOSED update in LAYOUTRETURN as well, matching the
> common stateid locking rule. Retain ls_mutex from the last segment remova=
l
> through the CLOSED update, and recheck CLOSED under cl_lock after taking
> ls_mutex in LAYOUTGET. This prevents a stale LAYOUTGET from adding a
> segment after the drain. Also make the newly allocated layout stateid the
> error-path put target and update the status-locking comment.
>=20
> Restrict nfs40_clean_admin_revoked() to NFSv4.0 clients. Its timer is
> armed only by v4.0 revocations, while session clients dispose of revoked
> stateids through FREE_STATEID. Skipping session clients prevents the scan
> from repeatedly selecting a CLOSED stateid that remains in the IDR while
> an in-flight operation holds a reference.
>=20
> The vulnerability research and validation were conducted by members of
> the Tobabz team as part of the Best of the Best 15th program.
>=20
> Fixes: 86b9898920a6 ("NFSD: Handle layout stid in nfsd4_drop_revoked_stid=
()")
> Suggested-by: Chuck Lever <cel@kernel.org>
> Cc: stable@vger.kernel.org
> Assisted-by: LLM
> Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
> ---
> Changes since v1:
> - Address Jeff Layton's concern by using cl_lock for layout CLOSED
>   checks and updates, without a type-dependent stateid status helper.
> - Move LAYOUTRETURN's CLOSED update outside ls_lock while retaining
>   ls_mutex, and update the status-locking documentation.
> - Clarify the LAYOUTGET serialization and v4.0 cleanup restriction.
> - Credit Chuck Lever's suggestion and mark the fix for stable review.
> - Rebase onto nfsd-testing c807415bc69013a5f162264ee0e14f8742c182f7.
>=20
> Validated on the above nfsd-testing base (2026-10-13):
> - Applied cleanly, passed strict checkpatch, and built and booted an x86_=
64
>   kernel with GCC 13.3, W=3D1, Generic KASAN, lockdep, and pNFS block and
>   SCSI layouts enabled.
> - Loopback pNFS SCSI read, shrink, integrity, revocation, and cleanup tes=
ts
>   passed, as did NFSv4.2, NFSv4.0, and NFSv3 read/write, fio CRC32C, and
>   unmount tests. Tracing observed two successful LAYOUTRETURNs reach the
>   modified CLOSED update and release their stateids.
> - Two concurrent FREE_STATEID requests from different slots of one NFSv4.=
1
>   session returned one success and one NFS4ERR_BAD_STATEID. A test-only
>   two-second pause forced the losing request into the disposal window;
>   tracing observed CLOSED, exactly one revoked-layout drain, and one
>   layout-state free.
> - No KASAN, lockdep, refcount, list-corruption, WARNING, or Oops report
>   occurred, and kernel taint remained zero through fixture cleanup.
>=20
> Build note: Existing format-truncation warnings in target_core_transport.=
c
> were excluded from WERROR; W=3D1 and WERROR remained enabled otherwise.
>=20
> The full xfstests suite was not run. Earlier v1 runtime results are not
> used as validation of this revision.
>=20
>  fs/nfsd/nfs4layouts.c | 34 ++++++++++++++++++++++++++++++++--
>  fs/nfsd/nfs4state.c   | 14 ++++++++++++++
>  fs/nfsd/pnfs.h        |  6 ++++++
>  fs/nfsd/state.h       |  5 ++---
>  4 files changed, 54 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 898776c9d..749ace97e 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -312,6 +312,7 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqst=
p,
>  		status =3D nfserr_jukebox;
>  		if (!ls)
>  			goto out;
> +		stid =3D &ls->ls_stid;
>  		mutex_lock(&ls->ls_mutex);
>  	} else {
>  		ls =3D container_of(stid, struct nfs4_layout_stateid, ls_stid);
> @@ -324,6 +325,15 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqs=
tp,
>  			goto out_unlock_stid;
>  	}
> =20
> +	/* A new or looked-up stateid may have been closed before ls_mutex. */
> +	spin_lock(&stid->sc_client->cl_lock);
> +	if (stid->sc_status & SC_STATUS_CLOSED) {
> +		spin_unlock(&stid->sc_client->cl_lock);
> +		status =3D nfserr_bad_stateid;
> +		goto out_unlock_stid;
> +	}
> +	spin_unlock(&stid->sc_client->cl_lock);
> +
>  	*lsp =3D ls;
>  	return 0;
> =20
> @@ -537,12 +547,18 @@ nfsd4_return_file_layouts(struct svc_rqst *rqstp,
>  			nfs4_inc_and_copy_stateid(&lrp->lr_sid, &ls->ls_stid);
>  		lrp->lrs_present =3D true;
>  	} else {
> -		trace_nfsd_layoutstate_unhash(&ls->ls_stid.sc_stateid);
> -		ls->ls_stid.sc_status |=3D SC_STATUS_CLOSED;
>  		lrp->lrs_present =3D false;
>  	}
>  	spin_unlock(&ls->ls_lock);
> =20
> +	if (!lrp->lrs_present) {
> +		/* ls_mutex prevents a LAYOUTGET from adding another segment. */
> +		spin_lock(&ls->ls_stid.sc_client->cl_lock);
> +		ls->ls_stid.sc_status |=3D SC_STATUS_CLOSED;
> +		spin_unlock(&ls->ls_stid.sc_client->cl_lock);
> +		trace_nfsd_layoutstate_unhash(&ls->ls_stid.sc_stateid);
> +	}
> +
>  	mutex_unlock(&ls->ls_mutex);
>  	nfs4_put_stid(&ls->ls_stid);
>  	nfsd4_free_layouts(&reaplist);
> @@ -594,6 +610,20 @@ nfsd4_return_all_layouts(struct nfs4_layout_stateid =
*ls,
>  	spin_unlock(&ls->ls_lock);
>  }
> =20
> +void nfsd4_return_revoked_layout(struct nfs4_layout_stateid *ls)
> +{
> +	LIST_HEAD(reaplist);
> +
> +	/*
> +	 * The caller holds a stateid reference until segment draining ends.
> +	 * Wait for any LAYOUTGET that passed the CLOSED check.
> +	 */
> +	mutex_lock(&ls->ls_mutex);
> +	nfsd4_return_all_layouts(ls, &reaplist);
> +	mutex_unlock(&ls->ls_mutex);
> +	nfsd4_free_layouts(&reaplist);
> +}
> +
>  void
>  nfsd4_return_all_client_layouts(struct nfs4_client *clp)
>  {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 26d2d56a5..1740b86eb 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5873,9 +5873,21 @@ static void nfsd4_drop_revoked_stid(struct nfs4_st=
id *s)
>  		break;
>  	case SC_TYPE_LAYOUT:
>  		ls =3D layoutstateid(s);
> +		if (s->sc_status & SC_STATUS_CLOSED) {
> +			spin_unlock(&cl->cl_lock);
> +			break;
> +		}
> +		s->sc_status |=3D SC_STATUS_CLOSED;
> +		/*
> +		 * The IDR does not own a layout stateid reference. Keep ls
> +		 * alive while draining worker and segment references below;
> +		 * the final put releases this temporary reference.
> +		 */
> +		refcount_inc(&s->sc_count);
>  		list_del_init(&ls->ls_perclnt);
>  		spin_unlock(&cl->cl_lock);
>  		nfsd4_stop_layout_fence(ls);
> +		nfsd4_return_revoked_layout(ls);
>  		nfs4_put_stid(s);
>  		break;
>  	default:
> @@ -7901,6 +7913,8 @@ static void nfs40_clean_admin_revoked(struct nfsd_n=
et *nn,
>  		unsigned long id, tmp;
>  		struct nfs4_stid *stid;
> =20
> +		if (clp->cl_minorversion !=3D 0)
> +			continue;
>  		if (atomic_read(&clp->cl_admin_revoked) =3D=3D 0)
>  			continue;
>  		if (is_client_expired(clp))
> diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
> index 559df0e5b..9b0f17a4d 100644
> --- a/fs/nfsd/pnfs.h
> +++ b/fs/nfsd/pnfs.h
> @@ -75,6 +75,7 @@ struct nfsd4_deviceid_map *nfsd4_find_devid_map(int idx=
);
>  #ifdef CONFIG_NFSD_PNFS
>  void nfsd4_setup_layout_type(struct svc_export *exp);
>  void nfsd4_return_all_client_layouts(struct nfs4_client *);
> +void nfsd4_return_revoked_layout(struct nfs4_layout_stateid *ls);
>  void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
>  		struct nfs4_file *fp);
>  void nfsd4_close_layout(struct nfs4_layout_stateid *ls);
> @@ -93,6 +94,11 @@ static inline void nfsd4_setup_layout_type(struct svc_=
export *exp)
>  static inline void nfsd4_return_all_client_layouts(struct nfs4_client *c=
lp)
>  {
>  }
> +
> +static inline void nfsd4_return_revoked_layout(struct nfs4_layout_statei=
d *ls)
> +{
> +}
> +
>  static inline void nfsd4_return_all_file_layouts(struct nfs4_client *clp=
,
>  		struct nfs4_file *fp)
>  {
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 79dfa47b8..63b581104 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -148,9 +148,8 @@ struct nfs4_stid {
>   * nn->deleg_lock protects sc_status for hashed delegation stateids.
>   * ->cl_lock protects the bits set as one is disposed of
>   * (SC_STATUS_CLOSED, SC_STATUS_FREEABLE, SC_STATUS_FREED) and
> - * sc_status for open and lock stateids. ->st_mutex also protects
> - * sc_status for open stateids. ->ls_lock protects sc_status for
> - * layout stateids.
> + * sc_status for open, lock, and layout stateids. ->st_mutex also protec=
ts
> + * sc_status for open stateids.
>   */
>  /*
>   * For an open stateid kept around *only* to process close replays.
>=20
> base-commit: c807415bc69013a5f162264ee0e14f8742c182f7

Better! I do like the fact that we don't have different rules now.
Sashiko flagged a potential issue with v4.0 handling that needs to be
addressed, however:

https://sashiko.dev/#/patchset/20261013060021.46543-1-bint4b13%40gmail.com
--=20
Jeff Layton <jlayton@kernel.org>
