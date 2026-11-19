Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124540;
	b=F0hBh4HCk500mnzq1FRV3CjpJrjakdRQj7jtkTtM4VbqV3k4qDcsT02OE2/Izi6J/Pmh
	 bnljDPBU69qGPYQAI1tRQ8gD73Im0KkRY9hliinTdfVy/HmLWXh65A83FcA4F8EFb3uWq
	 XNobdeoDgfzC8RUNPdQDpAeAX50pIK3HG9JGqBsAM7d9qpe+cELCX5RHLJL/iUTv8krT9
	 6Sl6OxVKo+DWPTsxtEtbmuXB8DkycO93iGaI3ItDN0vrvnLsVDwhlJZYVyahu8ZrOHzH+
	 rNRWAfDb3i09zDyWipr6LhJnkkEREJlvIoaYiveyby1ttPhWnj+IcS27EogKmaxWfJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124540;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=CDCf9TfG+CaO/g2AR70iueskKVq+2RjIoYyrci6cuFo=;
	b=3CTHNdhPVfUIniDd5PHu06qTNOFRtK87/5fPaGO4uEhA8+xVtHCvpg3D8Z2Jya7YS7y/
	 f9HYUQz+3HE7vDp7A9lKdoPbyJ/5FAn6kbGF8jyoy351g6JsIO0i9ZUuVsG80Zu7R7Rht
	 RBH5g6wBIF6VRcvLE2a9k84I28EJBVo934purvLHt4o7qosiSy7UlzxixYFOD/WHYyO/L
	 cZlgAG6jIIT096P5t/9rb9aDJz8KV40baMg0Qy/6zEZQ7dGcFUeZQL19T3pCyFnwrjmgM
	 5+IUjAttowCxO3Lix0Ks3uL5P/QaEDSBTLNCqK9DcyuOXp6FN+7kWyFZFKmKpnEBHOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RuGdXP1a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CEEA606A32A
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:42:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RuGdXP1a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A66A71F000C6;
	Thu, 19 Nov 2026 21:42:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795124539;
	bh=CDCf9TfG+CaO/g2AR70iueskKVq+2RjIoYyrci6cuFo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=RuGdXP1aF+6ROs9hCvAOChI4VSiEt4a3ebd5Ns0rIXUogXQaJbRIgcavLjTXekExB
	 zniBpvRkzek9mjWsSyyt5J33YinDo/L/bQzwsdVGfJchQ3V67uhXV+Jdwec2qJerL9
	 hOGziX40gkldTtFM6cMV0m90jyHkwq8yQ331RuR2aKsogPDKLBFSLw/xu7D/q4xBTx
	 CH+cLY8fgK1E1e/ao/NFcywhG5u0AKp4BqCPkUzrMdledI6PayhnCquLss4HnovfbR
	 sUKuNwuqLA8VtXKUSgFTDeEVlqu3fhdnK300432lehVlh4eaNZImExoiRF4A+s2Vzr
	 39xtED2k8SvLg==
Message-ID: <5039f48347ea0f9e3aee411604c6f9cf95c29481.camel@kernel.org>
Subject: Re: [PATCH] nfsd: enforce export checks in nfsd4_restorefh() and
 nfs4_check_file()
From: Jeff Layton <jlayton@kernel.org>
To: Dominik Maier <dmnk@google.com>, Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org, 	dmnk+artist@google.com
Date: Thu, 19 Nov 2026 13:42:19 -0800
In-Reply-To: <20261119192331.2695154-1-dmnk@google.com>
References: <20261119192331.2695154-1-dmnk@google.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-3.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Thu, 2026-11-19 at 20:23 +0100, Dominik Maier wrote:
> When an NFSv4 compound saves a filehandle from a UID-squashed export
> (all_squash or root_squash), switches current_fh to an unsquashed export
> via PUTFH, and then restores the saved filehandle via RESTOREFH,
> nfsd4_restorefh() duplicates save_fh back into current_fh without
> recomputing the worker thread's subjective credentials via
> nfsd_setuser().
>=20
> In addition, when nfs4_check_file() finds a cached nfsd_file on a
> stateid, it calls nfsd_permission() directly instead of running
> fh_verify() for fhp (unlike the uncached nfsd_file_acquire() path).
> Because PUTFH and SAVEFH defer security-flavor checks via
> OP_HANDLES_WRONGSEC, both post-RESTOREFH operations and cross-export
> COPY/CLONE operations (via nfsd4_verify_copy()) can skip nfsd_setuser(),
> check_xprtsec_policy(), check_security_flavor(), and originating-port
> checks on the cached-file fast path. While nfsd4_restorefh() has omitted
> credential restoration since early NFSv4 compound support,
> nfs4_check_file() and commit b7342204253a ("NFSD check stateids against
> copy stateids") expanded cached-stateid checks that bypass fh_verify().
>=20
> Call nfsd_setuser() when restoring save_fh in nfsd4_restorefh()
> (preserving deferred OP_IS_PUTFH_LIKE WRONGSEC handling) and call
> fh_verify() on the cached-file branch in nfs4_check_file() to match the
> uncached branch.
>=20
> This issue was discovered by an AI-assisted code review tool (ARTIST)
> and validated in QEMU against an unmodified v7.4-rc3 kernel without
> kernel modifications or error injection. A standalone reproducer is
> available on request. The fix was build-tested with KCFLAGS=3D-Werror and
> checked with checkpatch.pl --strict.
>=20
> Fixes: b7342204253a ("NFSD check stateids against copy stateids")

nit: Sashiko says the Fixes: tag may be wrong.

> Cc: stable@vger.kernel.org
> Signed-off-by: Dominik Maier <dmnk@google.com>
> ---
>  fs/nfsd/nfs4proc.c  | 9 +++++++++
>  fs/nfsd/nfs4state.c | 4 +---
>  2 files changed, 10 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3a82af3..1e7abe5 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -49,6 +49,7 @@
>  #include "xdr4.h"
>  #include "nfs4ctl.h"
>  #include "vfs.h"
> +#include "auth.h"
>  #include "current_stateid.h"
>  #include "netns.h"
>  #include "acl.h"
> @@ -847,9 +848,17 @@ static __be32
>  nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cst=
ate,
>  		union nfsd4_op_u *u)
>  {
> +	int err;
> +
>  	if (!cstate->save_fh.fh_dentry)
>  		return nfserr_restorefh;
> =20
> +	if (cstate->save_fh.fh_export) {
> +		err =3D nfsd_setuser(&rqstp->rq_cred, cstate->save_fh.fh_export);
> +		if (err)
> +			return nfserrno(err);
> +	}
> +
>  	fh_dup2(&cstate->current_fh, &cstate->save_fh);
>  	if (HAS_CSTATE_FLAG(cstate, SAVED_STATE_ID_FLAG)) {
>  		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid=
_t));
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 567a856..8e5c3ca 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -8434,9 +8434,7 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp, struct nfs4_stid *s,
> =20
>  	nf =3D nfs4_find_file(s, flags);
>  	if (nf) {
> -		status =3D nfsd_permission(&rqstp->rq_cred,
> -					 fhp->fh_export, fhp->fh_dentry,
> -				acc | NFSD_MAY_OWNER_OVERRIDE);
> +		status =3D fh_verify(rqstp, fhp, 0, acc | NFSD_MAY_OWNER_OVERRIDE);
>  		if (status) {
>  			nfsd_file_put(nf);
>  			goto out;

Reviewed-by: Jeff Layton <jlayton@kernel.org>
