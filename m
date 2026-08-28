Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6AA27463B6C;
	Fri, 28 Aug 2026 14:39:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787927995; cv=none; b=GhB8Q6VqTiVCWGm2GNtQURzT7lY1Emw3ec9jDDJaCMmnGsxxGVNrpGjCEvrfLF5XoUiATGDEyY7F6VsfuCIzkqB6+rwFB1F8xmuHJeQBYu9sy3IuefMZgqr+Zj8m93QrDtLxL80uLiAYj6nl25Y0kDjore0+OfA4FsnbIRlgl+Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787927995; c=relaxed/simple;
	bh=XZJkabDsz1o/isv8GnlIwvHXCQapvDug2lqh0wzM0uA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=bwCw9S9g25UOxHnvmDicGLNQcjsBKkzWw9N7+VdwiV7kEPCtYrtF9+YwYTYRx3G9r/MNTtk1eGSJ/EHSkO1/DH6i9QiouN80QfPc3St9PITJuv+kpmqTa1R5Pnaoojz0MtyOZNlsiqaGDrpPnf/IOtesbHNV7OGXt634Pzp8txA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZOvgczhR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZOvgczhR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D7D81F000E9;
	Fri, 28 Aug 2026 14:39:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787927994;
	bh=WbdV6eyXnQMzQohIWg66E1PllhjkKmNk21VhpQgF4DQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=ZOvgczhRpjakBqo71x01gh2pyyrydUU9UID+2PNXbAeHvJpuuYNdpDGv3gj9a3IeE
	 M9IRbxEK/Uw4ZD9G46Y+GgX+x/tYk/ujap8MmZIunYM3nGmDvlhLJdeFX/nLXPCC85
	 5mMAnwD6yXkOGq+qslOaSSkgYPBm9I+YDGLab3drSOYlJZwvd1gkggpgRk/tXxQyR0
	 Bot0MC+mtwBCTW0mNJm/1p9X39w75wU/3GuEZZqZYBP5i3ybAia9O8bJGyMZ3nC+S+
	 6uGn27WyqoUs2J2ii/pkHkSe9Jf+DnWPLmDirUfGAYDmvGKdTOEdeODgNs2cj8tJMV
	 HWZL2pGkD4knA==
Message-ID: <343cc59a0bf305ea5de8691257930aec4f44cc29.camel@kernel.org>
Subject: Re: [PATCH] nfsd: don't modify a session slot when replaying its
 cached reply
From: Jeff Layton <jlayton@kernel.org>
To: Ameer Hamza <ameer.hamza@truenas.com>, cel@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	alexander.motin@truenas.com, caleb.stjohn@truenas.com
Date: Fri, 28 Aug 2026 10:39:51 -0400
In-Reply-To: <20260824173641.3274260-1-ameer.hamza@truenas.com>
References: <20260824173641.3274260-1-ameer.hamza@truenas.com>
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

On Mon, 2026-08-24 at 22:36 +0500, Ameer Hamza wrote:
> nfsd4_sequence() claims a session slot by setting NFSD4_SLOT_INUSE
> under nn->client_lock. A reply served from the slot's reply cache does
> not claim it, and that distinction lived only in cstate->status, which
> nfsd4_sequence() set to nfserr_replay_cache. Commit cc028a10a48c
> ("NFSD: Hoist status code encoding into XDR encoder functions") moved
> nfsd4_proc_compound()'s cstate->status assignment below the out:
> label, and the replay path's goto out was the one path that relied on
> skipping it. The test in nfsd4_sequence_done() therefore no longer
> identifies a replay, and every replay now stores its reply and clears
> NFSD4_SLOT_INUSE as though it owned the slot.
>=20
> NFSD4_SLOT_INUSE is the interlock: check_slot_seqid() rejects every
> sequence id for a slot that is in use, before replay_matches_cache()
> runs. A replay never sets it, so two replays can be in flight on the
> same slot at once. One can read slot->sl_cred under nn->client_lock
> while the other's completion frees and rebuilds it from the XDR
> encoder without that lock. Two completions can also collide with each
> other and release the same group_info twice. free_svc_cred() leaves
> cr_uid, cr_gid and cr_flavor intact, so the reader passes every
> earlier test in same_creds() and dereferences a NULL cr_group_info.
> From a 6.12.91 production server:
>=20
>   BUG: kernel NULL pointer dereference, address: 0000000000000004
>   CPU: 63 UID: 0 PID: 39015 Comm: nfsd
>   RIP: 0010:same_creds+0x38/0xa0 [nfsd]
>   RDX: 0000000000000000
>   Call Trace:
>    nfsd4_sequence+0x6a8/0x910 [nfsd]
>    nfsd4_proc_compound+0x345/0x670 [nfsd]
>    nfsd_dispatch+0x100/0x220 [nfsd]
>    svc_process_common+0x311/0x700 [sunrpc]
>    svc_process+0x131/0x1c0 [sunrpc]
>    svc_recv+0x7ef/0x9c0 [sunrpc]
>    nfsd+0xa3/0x100 [nfsd]
>   Kernel panic - not syncing: Fatal exception
>=20
> Since v6.14 a live session's slot table can shrink, and the unowned
> store becomes a use-after-free write. nfsd4_sequence() defers the
> shrink while a slot is in use, but it tests NFSD4_SLOT_INUSE, which a
> replay does not set, so free_session_slots() can kfree() the slot the
> replay still holds in cstate->slot.
>=20
> Record the claim in cstate->slot_owned when nfsd4_sequence() accepts a
> request and test that in nfsd4_sequence_done(), so only the request
> that claimed the slot updates its cached reply and clears
> NFSD4_SLOT_INUSE. svc_generic_init_request() zeroes the compound
> response before each request, so the flag starts clear.
>=20
> Fixes: cc028a10a48c ("NFSD: Hoist status code encoding into XDR encoder f=
unctions")
> Assisted-by: Claude:claude-opus-5
> Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
> ---
> Reproduced on an unmodified tree with a client that pipelines two
> copies of a cached request before reading either reply.
>=20
>  fs/nfsd/nfs4state.c | 7 ++++++-
>  fs/nfsd/xdr4.h      | 1 +
>  2 files changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2c1b8b2cbbb5b..a4a75a512e9f0 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5170,6 +5170,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4=
_compound_state *cstate,
>  		slot->sl_flags &=3D ~NFSD4_SLOT_CACHETHIS;
> =20
>  	cstate->slot =3D slot;
> +	cstate->slot_owned =3D true;
>  	cstate->session =3D session;
>  	cstate->clp =3D clp;
> =20
> @@ -5244,7 +5245,11 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp=
)
>  	struct nfsd4_compound_state *cs =3D &resp->cstate;
> =20
>  	if (nfsd4_has_session(cs)) {
> -		if (cs->status !=3D nfserr_replay_cache) {
> +		/*
> +		 * Only the request that claimed the slot may update its
> +		 * cached reply and clear NFSD4_SLOT_INUSE.
> +		 */
> +		if (cs->slot_owned) {
>  			nfsd4_store_cache_entry(resp);
>  			cs->slot->sl_flags &=3D ~NFSD4_SLOT_INUSE;
>  		}
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index b841bc462dac8..5b7edf1893e0a 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -62,6 +62,7 @@ struct nfsd4_compound_state {
>  	struct nfsd4_slot	*slot;
>  	int			data_offset;
>  	bool                    spo_must_allowed;
> +	bool			slot_owned;
>  	size_t			iovlen;
>  	u32			minorversion;
>  	__be32			status;
>=20
> base-commit: 46ff234c7129c7c10ed493413d4f60d0cf4dd1f1

Reviewed-by: Jeff Layton <jlayton@kernel.org>
