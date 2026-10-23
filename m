Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792721592;
	b=xlMAt2t3N6eXPhhJIF2GMq9ml5wPP51XZB2JC6/Aum2fMBTaFK3p/HpZKHjMSz4XXuMw
	 lCpylUP6r4pcZjQZpkDdSfMiuePYeY27DXENSrYCb0ROialC6QfPDQ5PcERzL2HBh2bZd
	 hYuKSv7z1vLlOCX9hPLZdXChMs/t17zfQuG+/0nO+D0gZZFbt4YEXSIR2hd8X2TL/qMa8
	 nbJMJb2WUQI2hKGspTYAYViNUgF9ACCpG3bzEnBWpRPJ/oTOnr/nsVh2iO08Cr+a61dyJ
	 dPJCOsuMHUnQRo+LI245o3S3W9r2FAUdUA8LJBC8OnDPJp61MQR44E9sm/hJc6Cc32A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792721592;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=Uw5Phl+jnGQlfGydObsNY6zvTlA90v7yxA5srNSw0TA=;
	b=UecXBr1mN0HiMdZdoiT13zuYOCFfrh9YRw4eeFrdERwkLHGdZALC4qXLP/V1Wcvy+k97
	 XBmvevAF1hLyfhzu4JXYvBMSOLP2E6wm2t7zzRhQUzqkgPARN8BIkykg4iILbQdeY/rIA
	 culno31kkmoolrGB518HG+zGONZt6R2CCi8mIz7h9hbjq7hDIpOvOzqHSaWaZdHWCHTzo
	 Mi4OGr5pl0DaLhHMWHDox/PaSUmKBk4AX/8sqe0G52nn5ZC2EJPB06/xLiFLvhMB2DMH3
	 ahoYFkUAmNoUHubjOPC4I1CY9sFiNbEAj7IiMSpwxi/r0FNSdmX9QbvDbmqQrMZnAFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=XQ7wAWX7;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="O/7H0bze";
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5B1C606A325
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 02:13:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E5B1C606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=XQ7wAWX7;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=O/7H0bze
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0A8CF7A01D6
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 22:13:11 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Thu, 22 Oct 2026 22:13:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1792721590; x=1792807990; bh=Uw5Phl+jnGQlfGydObsNY6zvTlA90v7yxA5
	srNSw0TA=; b=XQ7wAWX7V5xbdJzVhweiWm+ng8gZpEOV3cFlY64UU/seWxzs10R
	axZbR2/2hmNVeR19bNavJYYS9ODHG4cNH9ltftr0wQyTbYUznsMyFWqWPESSRl0x
	fbKWpsNFJ3bAoh+xLqgcrtJNsvypUfrvJ830y1jJzOa7FLQc7KtnNx4Ol16r+wLL
	aG2mBmp5hqHH0vpX7nN35bHkHngdlO3KRHQ0PnNfkQSIiXP2OnQeGXHedOtraX7+
	A2rLFG1TmpKrEBDJfho6iS9aYHzXAd+7WIjt0iuIWX2giMhJnpqc38XFm4NYzfuF
	T0BZamTXMLPokr8XL+PcLql328x6hM5ltog==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1792721590; x=
	1792807990; bh=Uw5Phl+jnGQlfGydObsNY6zvTlA90v7yxA5srNSw0TA=; b=O
	/7H0bzeMsVY6te6i7zjKhSN5RNIFUDTCOj/j0MMz6vX7Z6Cp3kNJRfJb5Go0b4X5
	DyL5y9G7ZGTXrOpTE3a6GPmEAjF3UBOOuEmK9YSkOaW7c8P55HRGf+VIj4EEHCAq
	z+FWeD9vLtPxOLfFgXP1uP5Z/NKuapb2lgEQzE9+V8b/zwPSQeKgjoPdlEG12GXg
	3PPwWgCIlntJVLG/M2oh2rJySDYNRiWx9MKioSDgLfoxGDWYQw25PyV7h1yqfPhl
	/RsReLxGI2Itb2Q1972yKaY/Y94LdSevwOEG0PzwJMJ3g3E6foxXhwTcatYQ9Bnf
	UdEBGFWFv8leN+aFFE2Lg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792721590; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:Rvp6AQH2MXeV2QrQS1PKnla1aKLLFCTLiC2D2a2X5kzrkiU
	1ANbetnXg9NN7V1j9untcLiG8dohz9WVPZKVyiMroKk69dcxNiR/1gqzQdA87/Ae
	ce2po5b/3KuSeV/h7ICqDSxmuYhMU+UhTob9vzQahLV8qQNJ6EgdwaeDAtZQswPi
	3DLHEIyplJrA4zOKimFGYG0OFwc1/xBljXzOGPiBrt1EPsths+eXmfRxfGc++LoW
	C/qO+1E/+RYE7HTDTDq0rV8NucYc7VF26nUfi0CCop4t0c8nswL1VxB6jvKuED6f
	zA5tlbEtmUrHNGzjg5g060R3tcPdoUZIll71ZWQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:KL4MpElFCwPxBmhQ30a2jZdliYQy8Jd0U7UQ2guYkUY=:h2qW+d5UBjraUGnf5cx1HCMv9rVqr7a0oDls1LZR6Vs=;
X-ME-Sender: <xms:tsLaauYrOidHhDrBG8caTtFUEE5VqWrkiXr2n13ROvw4tW-jOjkcvw>
    <xme:tsLaajpZC-IuxkMwlPwUqnKtKw-cldv9gGI0L8L0YmJ9pGmS4dcBK_dlQO-ET-0UY
    HW15dKK97RVjC25663WrNM2NRFJqIzc7pgLN69YPVRNnGBnAyfx>
X-ME-Received: <xmr:tsLaarP1uukBE-ECzvvjfoDr0OT33eiU-D7n2nfQaLt31Kx-kPfkjnBRaHlMnafnhdkCNAaW951JylAExW7byW3_b5gw4Gc>
X-ME-Proxy-Cause: dmFkZTFdvXPd9Ea6sfdEYENBRwHvLMtEyCrkneRCdXYWqX0yLlrcASxmZ7h+qgcOBmSIC6
    uNn2m16QaS2p9iqJOQ73TXyKx9Ob2u8GpeKnma7EwKE8YXdLDM36J6/Uq4J3RRSbXbarjQ
    vTvJMRPBqo4qod5t36JT7xkzCc+RX8WpGBxmM2CIe/ZcZq8lcv6p0DcD50lSQj8Zsz5Ql3
    Oy61Mr1F030V00a40GdmPjdybNZ02g7ZSDxUfHP8iRaaseOcaV9Xg7ilpAwZRAQWOoNEm6
    j5sn1jedYA36aMPMq0p2mD306HwuE71UBg2gWS7qvb5biicLV86UpUX0ddIs82DznfIHBZ
    v64JhAZpq1zjwdmxtZJ535ea+W70iOx4oQIHS/2TtvqZtlREDAFOJSWSpYzjPKi6+tLljK
    +ffjFRosudEHZqkJzrD+JRzTttEOxAR2YI5PeVu5RUT7evU3VraB/MsXHzSBqtVjyMLaXw
    8ZNyf5OGO3Ozhar2Q2gBgXGxmRcIv0QODWZ3df4UG7cXCKrxQYOTg2vYSvwdMnIycJPSqM
    lwitFP5XyeLCLgpFtUPmd3ps9zeWALjJ+bKBidAZUaSU/VerU2gQAJuUCRNe6vse3MqOe1
    f6PIBTP1N3u1PPGno9/afXgpyyQJQnR8r9DeI4gJzmSA+2Y56V9rQ11O2csQ
X-ME-Proxy: <xmx:tsLaamrdDMdL8LlF_ZMHISYR6C0SjWWOpapwjLQdmDC4LQ4noLrhRg>
    <xmx:tsLaaodW1KCp0jJFNu1mg5jJfGbGAEWEYMIjPeL9f-IMio4x8KqDsw>
    <xmx:tsLaakSB52jJeUex_OjRJy3P28rnBS2X7wA1goz-zNLSUOTWymP1aQ>
    <xmx:tsLaapZ9Pz_HvKmWO-TeKB14NEqSCj-j-mrioe2XyIRPR30r7kC-HQ>
    <xmx:tsLaapZ6h-sHUdvQP1xt2Zz5QvIew-C57ZdFmo_v6bJtdcMQcGdd8qST>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 22:13:08 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Mohammed Alquraini" <mohammed.saad.alquraini@gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix use-after-free in svc_age_temp_xprts_now()
In-reply-to: <20261022205357.3239985-1-cel@kernel.org>
References: <20261022205357.3239985-1-cel@kernel.org>
Date: Fri, 23 Oct 2026 13:13:06 +1100
Message-id: <179272158618.2068970.8461283113546660302@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 23 Oct 2026, Chuck Lever wrote:
> svc_age_temp_xprts_now() moves each matching temporary transport
> onto a local list under sv_lock, then drops the lock and walks the
> local list without holding a reference on any of them. In the
> meantime svc_delete_xprt() can take sv_lock, unlink the same
> xpt_list node, and drop the transport's last reference. An idle
> temporary transport holds only that one reference, so a peer FIN
> that arrives between the two loops frees the svc_sock out from under
> the second loop. The notifier then sets XPT_CLOSE in freed memory,
> and svc_xprt_enqueue() reads xpt_flags and xpt_server from the freed
> object and queues that object on a pool for an nfsd thread. KASAN
> reports a slab-use-after-free in svc_xprt_enqueue() under
> nfsd_inetaddr_event(), with the object freed by svc_sock_free() on
> an nfsd thread.
>=20
> The two-phase walk dates from when the second loop called into the
> socket layer and could sleep. Commit 546125d16142 ("sunrpc: don't
> call sleeping functions from the notifier block callbacks") moved
> that work to the nfsd threads, so nothing left in the second loop
> needs sv_lock dropped. Mark and enqueue each matching transport
> under sv_lock in a single pass, as svc_age_temp_xprts() already
> does, so that svc_delete_xprt() cannot unlink and free a transport
> the notifier is still touching.
>=20
> Fixes: c3d4879e01be ("sunrpc: Add a function to close temporary transports =
immediately")
> Reported-by: Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
> Signed-off-by: Chuck Lever <cel@kernel.org>

Reviewed-by: NeilBrown <neil@brown.name>

Everything being moved into the locked region is safe in that context,
so this is a nice simplification as well as being a bug-fix.

Thanks,
NeilBrown


> ---
>  net/sunrpc/svc_xprt.c | 16 ++++------------
>  1 file changed, 4 insertions(+), 12 deletions(-)
>=20
> Mohammed, thanks for the report. Please test and report your results.
>=20
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 5db42e53be62..076c624fe675 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -1075,29 +1075,21 @@ void svc_age_temp_xprts_now(struct svc_serv *serv, =
struct sockaddr *server_addr)
>  {
>  	struct svc_xprt *xprt;
>  	struct list_head *le, *next;
> -	LIST_HEAD(to_be_closed);
> =20
>  	spin_lock_bh(&serv->sv_lock);
>  	list_for_each_safe(le, next, &serv->sv_tempsocks) {
>  		xprt =3D list_entry(le, struct svc_xprt, xpt_list);
> -		if (rpc_cmp_addr(server_addr, (struct sockaddr *)
> -				&xprt->xpt_local)) {
> -			dprintk("svc_age_temp_xprts_now: found %p\n", xprt);
> -			list_move(le, &to_be_closed);
> -		}
> -	}
> -	spin_unlock_bh(&serv->sv_lock);
> -
> -	while (!list_empty(&to_be_closed)) {
> -		le =3D to_be_closed.next;
> +		if (!rpc_cmp_addr(server_addr, (struct sockaddr *)
> +				&xprt->xpt_local))
> +			continue;
>  		list_del_init(le);
> -		xprt =3D list_entry(le, struct svc_xprt, xpt_list);
>  		set_bit(XPT_CLOSE, &xprt->xpt_flags);
>  		set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
>  		dprintk("svc_age_temp_xprts_now: queuing xprt %p for closing\n",
>  				xprt);
>  		svc_xprt_enqueue(xprt);
>  	}
> +	spin_unlock_bh(&serv->sv_lock);
>  }
>  EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
> =20
> --=20
> 2.54.0
>=20
>=20

