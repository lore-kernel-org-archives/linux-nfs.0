Received: from fout-b2-smtp.messagingengine.com (fout-b2-smtp.messagingengine.com [202.12.124.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D35C8634C
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 01:49:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782438563; cv=none; b=pJ8ZIAbxuUFepEFSsGzlsrdWvGudU31oCyKvVXWGhIkENs3DMpFb1TldOj/tK2OGIjQG0Gx+lPG2BazT/RqyRDS+eq/umu6Ea/OD8AjI/t3OneZ3r4nSlVpSngj5I+IxEpnWly1ufz4LeQaLj1ZROKK866nCHD+VcGOym1D1hVk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782438563; c=relaxed/simple;
	bh=gcYEdd+vw3nmcMK7dziyAOcD0Xc4d7ZpZqStZ6KaO+M=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=ulhFz+fJfYG6wm7bvCFWTkuNeqp4rrI4YP/LdFWE7CJpGXeDF8kWXLARY5e9LaRlgwaiqhmb85co7cpej1CTzxuAMC01P1Nn8lL2ezuw75c30dNxrxirkbij/Ms6mQMOu7fe6Nzn44041InamR9NEvFWKRO4AW1EO5Q3Q8nR1QI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=PgWq6cXN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=WfDJD9ei; arc=none smtp.client-ip=202.12.124.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="PgWq6cXN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="WfDJD9ei"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfout.stl.internal (Postfix) with ESMTP id 853471D00101;
	Thu, 25 Jun 2026 21:49:20 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Thu, 25 Jun 2026 21:49:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1782438560; x=1782524960; bh=Z3cKT7RhWYeEhtBEjcoHBKZXLRWmWacSIP2
	RU45Img0=; b=PgWq6cXNIqEv/syR4jSGjy6+0vh4Ju7DJ3ldUkS31iGhs/QlyDA
	j1cjw+mraR4uLgBcGYIjukjF3WPtEYi1mTkRH9sftlZ2e2U+0BIE8gj/Af+yfbcP
	i/yyELn1/cPKf8MlMl6qy0LmJo8K643p/v2Sh1tzLQeE+6yX//WJV3VT1DgWaL6E
	ZWGluTSD1yaVlnKJUpQrgqVbISrFKYVg4AMeCNmslx68W28ns8yzuqjhxEkcIJeE
	6n1spReR13qfX3NJnSwptL/XibOeDT0Nqz95u0C4JBKaVb3+T7B7dCzE/EaX3flK
	8iyA+CU5lppXXXApm0tS1FXzb2PRcdmdspQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1782438560; x=
	1782524960; bh=Z3cKT7RhWYeEhtBEjcoHBKZXLRWmWacSIP2RU45Img0=; b=W
	fDJD9eieRbSUbDnMN1hoZozf6PnuEvehhGgfAzfdltjosq0ri2ItNett6NjHrjeQ
	98kNviHnL9n5/MNrVd9/dH+lFq9KM4s1Zf3tq9jaSbZCGAAFxfbkTVGcnff7RZCV
	iFtffovhVrb55w5K6Te+u4Y4yZJshlp8ofNuqfiXw7pk1Y2mGbwPQ6H5IhQ/rIS7
	Vd0akDWpY089mx1r+mXA+FcTM4Z2pWhysph7mGGbgWE0YZVUgoomVyxZBuFevTsP
	Xn47cNPvkEl9dhUJXW+8vbdHV59xBrM0wknPxrfDTnbNneY4Fc8l/wVqsPyGko/K
	4+o3QqiacaOwzZay8sABQ==
X-ME-Sender: <xms:oNo9arl9_zWMH7hozYufp1vOa9VALbKZl2cyqIDs3iXhjrgNFH296A>
    <xme:oNo9ahHCFtwJ_FZd_O7gI0-R0GVT795ORoETFkOP7IGylmYqT5SBK5CANTQepiBLN
    KQu2S0wPwyBQ0IAlwgyrP0PH8AR9AXcNaxpgFrSkekytechjw>
X-ME-Received: <xmr:oNo9aj7D-7juxKRaNhvCqZcov_MGwz4tGcNm2ylOh4C0PMU6iFK0ZFZDqKvIcTKpN_Rg6mr2rxuYRqm0idgufsSoCdOoctg>
X-ME-Proxy-Cause: dmFkZTGlA4PbXdtm07gLsrpjNfpqdCpfAyfa6W2F+SMWp8HEySifPilF5GEPzUArL5lEJL
    g8NCZpQqpsGcYChNGj2vYZP2ouqAdJv/6j3flRBasu93oSxDV43UaujdnozKtw5jBW28WD
    cZgbOGQuLzq0LfyD2Fp0uje83n3R4HEb9Z4a+iIY8Wr48t6SYL/REHbeiK/5DrI+vG1TMH
    aB2PwndqjcUujNG5n4SngcVE8A3K9fjAMeyTDWJ607e8nPh38vDQYhwMIfO8b5pdjL08ao
    M+bjP0Ni3d/X1rNGGURSUv3ubh07JTj0STkTbY8uFi6i5K6n0h5b/Zp/nPUVoZYPCI4ypZ
    kuMbxDKqg9bU71zMopqDNc8BIRHgMnIhAtae+sIBpzdnYqxi0DmR48rqs49yiLJn/Rltzg
    nqc2Jeh//zM5TZ25LkTmzb2S9JhVCFitYb2KG8SmQDW4nWrwUVnXE1I8yUkU1Jar77i9cJ
    muxjTR01KP6Ye078prdtRg99Us2BxT7o/1pULeQpPvMNFEbZqQljuX2/fc3n0KcyUHMn3L
    OzcClnt0hPnAm+xaD/rCmFyc0NG4WlJZZlRDqVcAj7A9Kw+Tn/lTa2b99seAq4hlcUvslv
    7elf7bUyVFDfTZFp5y9cxBlJftuKAEAfl32v76jc/0EbmuY77xkXhkuhT8Ew
X-ME-Proxy: <xmx:oNo9aplDc0RNl_1a86RRtEClbE7Q1_HB0sj_l_JqpafUQlwzO619DA>
    <xmx:oNo9aooSkPr6TpOlylED7Ijx40pis0WC4MigRo0EnvB9SEeQ5OY7Gg>
    <xmx:oNo9aotAhTXxsSwg0MfnfypMThvsZH2mnzi-XIBkt29ViYJ-OcJ4Mg>
    <xmx:oNo9atG4t_9L9Rz0GlJqy7ZhDfsCvjwpCdSbuhXfdeXAboGQ_fqn5A>
    <xmx:oNo9akbj1zh6rVdvelaFwAkZ-VUfm8Yg41whAlASp_VTxxn6WLELatP2>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 25 Jun 2026 21:49:17 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Olga Kornievskaia" <okorniev@redhat.com>
Cc: chuck.lever@oracle.com, jlayton@kernel.org, linux-nfs@vger.kernel.org,
 neilb@brown.name, Dai.Ngo@oracle.com, tom@talpey.com
Subject: Re: [PATCH 1/1] lockd: fix GRANTED_MSG handling
In-reply-to: <20260625211852.31972-1-okorniev@redhat.com>
References: <20260625211852.31972-1-okorniev@redhat.com>
Date: Fri, 26 Jun 2026 11:49:15 +1000
Message-id: <178243855549.27465.5550787515518801190@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 26 Jun 2026, Olga Kornievskaia wrote:
> GRANTED_MSG is a server-to-client callback, so it runs on the client,
> where nfsd never registers nlmsvc_ops. The nlm4svc_lookup_host()/
> nlm3svc_lookup_host() helpers are for the server-side request handlers
> (TEST/LOCK/CANCEL/UNLOCK), which reach nlmsvc_ops->fopen and must
> reject requests when nfsd isn't running. GRANTED_MSG only calls
> nlmclnt_grant(). Instead, of calling nlm4svc_lookup_host()/
> nlm3svc_lookup_host() (which results in a client failing a GRANTED_MSG
> call) call nlmsvc_lookup_host.
>=20
> Fixes: 62721885e861 ("lockd: Use xdrgen XDR functions for the NLMv4 GRANTED=
_MSG procedure")
> Fixes: 6c534ad999b6 ("lockd: Use xdrgen XDR functions for the NLMv3 GRANTED=
_MSG procedure")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
> ---
>  fs/lockd/svc4proc.c | 3 ++-
>  fs/lockd/svcproc.c  | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index 080dffce9d8e..b73004a7987e 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -872,7 +872,8 @@ static __be32 nlm4svc_proc_granted_msg(struct svc_rqst =
*rqstp)
>  	struct nlm4_testargs_wrapper *argp =3D rqstp->rq_argp;
>  	struct nlm_host *host;
> =20
> -	host =3D nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false=
);
> +	host =3D nlmsvc_lookup_host(rqstp, argp->xdrgen.alock.caller_name.data,
> +				  argp->xdrgen.alock.caller_name.len);
>  	if (!host)
>  		return rpc_system_err;
> =20
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index dce6f6e3fd40..d410b8c69893 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -901,7 +901,8 @@ static __be32 nlmsvc_proc_granted_msg(struct svc_rqst *=
rqstp)
>  	if (argp->xdrgen.cookie.len > NLM_MAXCOOKIELEN)
>  		return rpc_garbage_args;
> =20
> -	host =3D nlm3svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false=
);
> +	host =3D nlmsvc_lookup_host(rqstp, argp->xdrgen.alock.caller_name.data,
> +				  argp->xdrgen.alock.caller_name.len);
>  	if (!host)
>  		return rpc_system_err;
> =20

Reviewed-by: NeilBrown <neil@brown.name>

That is a subtle difference between nlm4svc_lookup_host() and
nlmsvc_lookup_host().  I wonder if making the names more distinct would
help...

Thanks,
NeilBrown
