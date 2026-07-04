Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4263F258EFF;
	Sat,  4 Jul 2026 22:31:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783204302; cv=none; b=uH4QB3OMmQwfSjlp3/aYDwXBz04m/+JbCcpMf16uzpDd8iAE6Zr0Ty3MfsrQ6m1d0MlCB38IGEQGonVsqCK2ruJZRxFc3+OK4nvgY1NljhDkfHtqgA4BwSGvw4Gy+TcvgXDvgl4SYfpAV5QAOf9vlSbXMIwmBvkKXcUV4NwFZ1Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783204302; c=relaxed/simple;
	bh=bvNjmCrd9qIYyyjqAKa6MU251i/K6Oqb2WzqLAU0nCY=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=U0yz6heAdtEe7swowmlqRQJYnRwOD6Ipcbo+kogKZX63y2H/8L/gUdfMI+y6ka299+d0NiveYq8qy2rlOVqNdwlg/cGMQbuauLd48b6Z+DZKDOro9lEvZhiKHgBdz9420cYDioCnLuRfSz2yHQ6T+2bItbpv8AL60Hf4MgWo9Uc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=QeP7hgMC; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=DF5ddzd2; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="QeP7hgMC";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="DF5ddzd2"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 4041A140007C;
	Sat,  4 Jul 2026 18:31:39 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Sat, 04 Jul 2026 18:31:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1783204299; x=1783290699; bh=NxRMsN79PkJSYQMYTfX7q0Lm4z/OcL5bx63
	dmcNwN9E=; b=QeP7hgMChLD1s5jC34S3COp16gZio1cA9f7EEtvADNVf5idF0SY
	SkTm4lCwnrO7ewKZSCQWvDwxsFIttNINPIDgm8yIkaF7aqVtGGIPCkwhy8iTFnxx
	vr6JzgO5Bp/tRzOMtmPW9O00XnUh7bXnB2CxxEvABDkTrj5fwcdcNLxhnpTKcpK9
	Nb0a0gwwj7NZMF+Yjdmzy9pcR8alQX4mtoJzFZM7AzH4VceJLlX7v0LuoM2OCiT2
	mYubz+2z1CK5LNHLZN5JBz3j7erbpbLNCSQCPqGzsFAxIkFn3e7fCg4aNJOoIeDK
	svnoL0bV6jab3zrujDfYhWL3tJfNiBkw/qg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1783204299; x=
	1783290699; bh=NxRMsN79PkJSYQMYTfX7q0Lm4z/OcL5bx63dmcNwN9E=; b=D
	F5ddzd2DXYFT28/IEn45n9YCv+HbZw8uDIhU9uhmFRtTnrLqY2MkmL2gPZYIZ64v
	+Cu9YmZW2uh40Oz15F6go1G8U4pDFUwmLKoONe+jUdc/VuwZMNYoAf/OLBYQtezQ
	EpE4Bh/CSp99uY+u0Uf5ppRfUC3KqbKNqlpyZaTksAdGzs0y9OqbQAQD7dGVvqXG
	WQMTDQGUuS+anTNakruELRqZShSNKEDdLQlZkEHPTTHq/doeJ/KR4xQOs8cpuwhs
	3vPDPIVE3ZnJdnVBdtm3LtxFBux9JNNKdKf7D5/Av0PqjV5KNTyD9aeEL2DmHYJN
	AqW96IQV896O/aYLNe4tA==
X-ME-Sender: <xms:y4lJahAkrOGFpajGSyF4_cjmx-CRWVSUIdZGg8AkmRaaqQXUHYyMpA>
    <xme:y4lJapjYWlI-UBb_9RiH5JomkCLAi-H8hQPko72dU7y3bCevI9TWtej_r3Xw_m2dd
    BiJWEKBa3A_40WY8UsiTjDzPeUks3b7WWZbDkNSwSOMNkIEk4c>
X-ME-Received: <xmr:y4lJajNXpVOmReEAI6EhftmtldF6VPETCFX08ZocliLqhEPt2hKUKgtyP_WsHo6r1CzfowvTudkwxSJwNDBV6_RE90II1vQ>
X-ME-Proxy-Cause: dmFkZTE/wTPYMgKq/xP52IeW2BX1uJwr0KWis8X3EwyFNhhkxs8fdi0ZesvCy08XY+/7jM
    E1f7+DlzjRbaFX4aoJWCRwiBBGch/6OkCK4m+f2KukEfyV7wZG57to5WGcSjX1uYTt2OkL
    2kjrgJPAb0HkG3ze9nu2BEVvQpe13eCoqjuz/8Y0vJOEHXXiMK20UqHlNChCoXi4cLXv5b
    QldwfJv61LQZfYGoPUevT+aeoQkmiQcPFfR2lKfCgTgGxggbY0aRoxe0v9ULWnjET9h3Fb
    DN9znigDq/r/c1PTzYZY6afMC4Iie2e5JHA2/74dprUUuPyKdcoVKCM8LlQMFG1G2ucaVb
    xZfgp1XJkrhtp7tJFk7hw5JONAK2kKnDQL8Wbr+PjzC2yVRfNx2ExeyWO6AYzOu8jOKKhS
    57kIDPuAmzsK7UjBdC52EJ9T5rqeU9x7c3lNY7TUmnAyeR3OR0g6tIw6OxqNzLiCq9r3D0
    3RtYD1y7v1+TyZty4Emc4IRBcDuCGKnUPGxSO+ZdTmbAsctaaXpbfI3xFlbouTZQbfK5oD
    0t6P7yOCrYl4S6P3oH1WvACRpoo1ZwWkIpc3pqESIw3A2SHk/za5qHfqJbJh8UwFqo8Cjf
    J9hSI6oc1dKn59jnq6A91PRrOOUzW4i16oI8HVhZ+teb8fi92RNQOqIYiRdw
X-ME-Proxy: <xmx:y4lJap_weaf681_JRl03us881EHp_GEopzkx9cbkc_pqDbNzs4qnIw>
    <xmx:y4lJakeecRRPa3QRXxR0URxceSmG3oa6dmFMlIJXdqnK_qVQ4MJuDw>
    <xmx:y4lJaowOvHZ5euxjLKO7E5fIhaD1XFHfcKDeE4UgxKDx61ASrHay_w>
    <xmx:y4lJapLOUdtOZ9YGPHnVf2LH_2GcSvcQnxOH5mHOQsY7ZG6MIDWk_w>
    <xmx:y4lJas1xw3AwPSMuV_G6oMzMg0gx9wua-bkZB-Y-9MBDPJOYoFsccRvQ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 4 Jul 2026 18:31:36 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Guangshuo Li" <lgs201920130244@gmail.com>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Guangshuo Li" <lgs201920130244@gmail.com>
Subject: Re: [PATCH] nfsd: Fix dentry refcount leak in nfsd_set_fh_dentry()
In-reply-to: <20260704172300.254447-1-lgs201920130244@gmail.com>
References: <20260704172300.254447-1-lgs201920130244@gmail.com>
Date: Sun, 05 Jul 2026 08:31:33 +1000
Message-id: <178320429328.27465.2341140887279902100@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sun, 05 Jul 2026, Guangshuo Li wrote:
> nfsd_set_fh_dentry() gets a dentry reference before checking whether an
> NFSv2 or NFSv3 filehandle resolves to a V4ROOT export. Such filehandles
> are rejected, but the rejection path jumps to out before the dentry is
> stored in fhp->fh_dentry.
>=20
> As a result, fh_put() will not see the dentry, and the out path only
> drops the export reference. The dentry reference obtained by dget() or
> exportfs_decode_fh_raw() is therefore leaked.
>=20
> Add a separate error path for the V4ROOT rejection case that drops the
> dentry reference before dropping the export reference.
>=20
> Fixes: 8a7348a9ed70 ("nfsd: fix refcount leak in nfsd_set_fh_dentry()")
> Signed-off-by: Guangshuo Li <lgs201920130244@gmail.com>

Thanks for finding and reporting that.

Reviewed-by: NeilBrown <neil@brown.name>

NeilBrown


> ---
>  fs/nfsd/nfsfh.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 429ca5c6ec08..2ca5bb5b5e88 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -345,20 +345,22 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqs=
tp, struct net *net,
>  			fhp->fh_no_wcc =3D true;
>  		fhp->fh_64bit_cookies =3D true;
>  		if (exp->ex_flags & NFSEXP_V4ROOT)
> -			goto out;
> +			goto out_dput;
>  		break;
>  	case NFS_FHSIZE:
>  		fhp->fh_no_wcc =3D true;
>  		if (EX_WGATHER(exp))
>  			fhp->fh_use_wgather =3D true;
>  		if (exp->ex_flags & NFSEXP_V4ROOT)
> -			goto out;
> +			goto out_dput;
>  	}
> =20
>  	fhp->fh_dentry =3D dentry;
>  	fhp->fh_export =3D exp;
> =20
>  	return 0;
> +out_dput:
> +	dput(dentry);
>  out:
>  	exp_put(exp);
>  	return error;
> --=20
> 2.43.0
>=20
>=20

