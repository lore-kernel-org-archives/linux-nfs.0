Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C61242DB7B9
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 07:23:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788765792; cv=none; b=MoRT4tsy3SRks8AxokMy50loEVI0SKAnfVt5tvnuIg2gyO1ICs0pB2PVuIuT276tTRq8uw6zylZfwTWYYBycQ7hVRc3JYwy9LH6Rh1RewXeYJAaYVQcKTRfSpgrV9+4EO7wL7dWeRcEKFO4wf4qSaRV44fxaKzrKC3GuLJ8s1ug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788765792; c=relaxed/simple;
	bh=+1NtoZrRQACaWZa4Yr4B+NuC9M6J5lBbTyeIAWFEyQE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=BkiI2agN41ZWPbF1471FbOi790vq02eHbDZ5HfZGYuAs4mlhkJbr1b1nvDOxIb/eGQ0wGw1ZQixk2YIAVKnBxdtLj6nq8QgEVeFlrnugJq3rxdbH5WltGW0CBukLUfa2vEC00UGgubZT7ebQJqnLztjgR0Q8aSjf+mbMK1Spn04=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Sz31LSrA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ltrcP7Jd; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Sz31LSrA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ltrcP7Jd"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.stl.internal (Postfix) with ESMTP id AAA3D1D000D2;
	Mon,  7 Sep 2026 03:23:08 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Mon, 07 Sep 2026 03:23:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1788765788; x=1788852188; bh=un/7Qd6f2HyI80xEIfUy3lmh0/J8Tb6O2Qq
	pFWNZ8HM=; b=Sz31LSrAbqut+1m/ebsk5Gjhw1G46rh8zqz+m6WnhmfEUsrWmgW
	3RG3MhgMHy3Sw9YMIU+Q2CFxoZp5UNHzB0u8z7/XcllhiMUK5b/CM+JvDoUocBJT
	mXOUmvDrNDlpntV8r0JY/14UhgY+mziLH6cYLKg1QhbprpJhsEVMh+RpkSS2U504
	9W6HYbdaXWLOQDddoVZt7MFCMGWR9Jd5FItd3fyRKBRhYwhpnEV5q5W5/PuYWM9Q
	Wdr4e10sAMnrXBiejKJTQFw4N6boBZNVjQgkFTJdChcBvTwNgYKX6xnX0UqM0rhe
	Ge7WzJVrXiSjR9EMx3ZC72Oo7D88jTBiXWw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1788765788; x=
	1788852188; bh=un/7Qd6f2HyI80xEIfUy3lmh0/J8Tb6O2QqpFWNZ8HM=; b=l
	trcP7Jdv8tzPd1/qwNa87On2KeWzQVTvE99SIN2j5+J/V0Rj6ccDMbpBVW6AQf77
	BIVWGdXLuAcTAwSffEZ9ruqSf0RY76llE+V50sbLn0oMnNo1ryWrCb7IOYf4HnXW
	ljaZB9N/3TJEp3i4wUkPgt4nKunzQVmbdnISUpt6ZjQL1+qBjdFGddpmrT+5MO9q
	2Eg5+CQM4ZFSL58K9PjSC8zqt+g5Bw2Aue/7yoJLBao/80B1CP3QnF6h0YA3fyWZ
	tWjId8JUGNK0cBXs3YA0RVVwNE6wIGBtN1BLB+Mjg6zA4Urcd75I8Q5JCVgq2kYS
	nQuIQVg2RIcZLxSt8wHcw==
X-ME-Sender: <xms:XGaeahk2PbETULBZ3BUGQ7ktVLveE4s6MFetAoq1Tll3hJEfZSvMSw>
    <xme:XGaeagjAJ_q_r-tH9qkisH4DUsqx79_Xsn_EGltn7cjf-uqEAYqGNsfoAxKTBjEgi
    gAEyPipbQ_xGqmd2-lIREQQjpA1xvD-HbCmFtVPdz5m5bNZPw>
X-ME-Received: <xmr:XGaeahdOl3n5ZKacUDW74skal77dOTfpQrUhFeyDlRMBiXelNIejDMhrFifotp6aB76ZKYt0Hpy3DEs9ftEfuzyMEM5aOck>
X-ME-Proxy-Cause: dmFkZTGkG1SmOVGGbf1AE3fPsPoUMPtrPT3S6CerzWmLwz/1kPTYCdotPa30Sxhm2lCsxW
    HC6P9DJ08VeZupUUSY0I8XQgcW93v3uhjVJxJ55ZJcM1eZOq2XYYTkXwYOYSns+dhTFglt
    C4+4qM9IvR8MrphrdpmOcd4omr+yLmAmgfqMXsAoUo6RrZc40WcOEX1lOElorpVG+TLwmJ
    4DUlnHI2vVwTZzJ+ATH3k0q98x0VQ7Icsmr3UWBE4jgO2anrrtXPMS+HYwlzdEUBUDchFe
    BjtA5AAb3a8WhHT1wpy6rrGnRfOsVkZ+DJLsnArvGsrTlnkuJNQlFZhs1NKuhYOKxgRMjY
    +3j4UQRG9KGIOeZtg1WSKhXgpzL4H2ctamfzn/xrf0KChH0lL4ERKalSmAjtqW/MjH61Tj
    k7I+lOr4elHnbc18CJO4z0E1GRbRHm02d61qJMe3GDrakB36bTvVkQZzOBm9UYW2GUBRxs
    Q/K+obbEIcLqkfXJvus1fZAujIBzeaRirYrqVNW0o3+T0GEsz0TxkODzhC3c7eJEo0zX+3
    b5yE259dZ63H/tGjCmwAWfFyIl4LtM3EdNI7PQPYr154Fn6hW8WGfu7ItiRg+gOqPvnAC8
    hgrLXFnXcam5VuuIQYZ1u4JLxDiQ9XTciBw30Ot6QCFSBZHYc6owPRqGJX8w
X-ME-Proxy: <xmx:XGaeaohZtogxtdnfJOrn_Qh04aTIVuqXCpMdEn7L4InIzR74v3uexA>
    <xmx:XGaeahwe6unl2aYalWCp133ARC9fahKz7hTTnTg_rG6GaSPRwj9tFw>
    <xmx:XGaeasMYvIgry-tJ4fvD2f9xSlRjFQu2VQ-53x6E2k6hTcf7KIySqA>
    <xmx:XGaeaqUzIjLx4c84hYCGbY8u5RMvdyttpvmJXHzADEJVkZdeAV-J2Q>
    <xmx:XGaeanFAQ5We1byEjk3Tfc_hgp-1F68HoJkhNQpeJ1y80Nys3RwJj2lJ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 7 Sep 2026 03:23:06 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1] NFSD: return NFS4ERR_EXIST for a guarded OPEN of a
 non-regular object
In-reply-to: <20260906184141.3453309-1-cel@kernel.org>
References: <20260906184141.3453309-1-cel@kernel.org>
Date: Mon, 07 Sep 2026 17:23:01 +1000
Message-id: <178876578199.207413.3228251239274631622@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 07 Sep 2026, Chuck Lever wrote:
> Commit db8b567ffa98 ("nfsd: (almost) always open file in
> nfsd4_create_file()") moved the regular-file type check ahead of the
> createmode logic. A GUARDED4, EXCLUSIVE4, or EXCLUSIVE4_1 OPEN that
> finds a directory or symbolic link under the requested name now fails
> with NFS4ERR_ISDIR or NFS4ERR_SYMLINK instead of NFS4ERR_EXIST.
>=20
> RFC 8881 Section 18.16.3 requires NFS4ERR_EXIST when a guarded create
> finds any object under that name, or when an exclusive create's
> verifier does not match. The type-specific errors in Section 18.16.4
> apply to opening an existing file, which only UNCHECKED4 does.
>=20
> Fixes: db8b567ffa98 ("nfsd: (almost) always open file in nfsd4_create_file(=
)")
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfs4proc.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>=20
> Neil, I'll apply this to nfsd-testing. It should be in time to get
> into nfsd-next before v7.4.
>=20
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index bb74eef43938..3a82af381a8d 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -430,7 +430,17 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_f=
h *fhp,
>  				       oflags,
>  				       open->op_iattr.ia_mode);
>  	if (IS_ERR(open->op_filp)) {
> -		status =3D nfserrno(PTR_ERR(open->op_filp));
> +		int hosterr =3D PTR_ERR(open->op_filp);
> +
> +		if (open->op_createmode !=3D NFS4_CREATE_UNCHECKED) {
> +			switch (hosterr) {
> +			case -EISDIR:
> +			case -ELOOP:
> +			case -EFTYPE:
> +				hosterr =3D -EEXIST;
> +			}
> +		}
> +		status =3D nfserrno(hosterr);

Thanks but I don't think this is the best place to fix it.
I think it would be best to put the fix in do_lookup_open() so that
it's behaviour more closely matches vfs_lookup_open().

I'll send an alternate patch.

Thanks,
NeilBrown


>  		open->op_filp =3D NULL;
>  		if (status =3D=3D nfserr_noent && create_status)
>  			status =3D create_status;
> --=20
> 2.54.0
>=20
>=20

