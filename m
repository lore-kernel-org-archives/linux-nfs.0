Received: from fhigh-a4-smtp.messagingengine.com (fhigh-a4-smtp.messagingengine.com [103.168.172.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA4893BB670
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 22:20:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785277227; cv=none; b=U7fcerdW2Bd9fv5ASRLKkr4XcldkF5nU1chvV/hxnvVgcuxharfLaukjQeaVf2a3v4940GbM0tsxVxlvERgREMLrYUV9OJ0giYs5zL4dLldzCx9RU/UWSoMoAFbPmasU7jO9HFCN0V65jiE49ZNlXqvJsSFr2WiH/yt/K6zwutQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785277227; c=relaxed/simple;
	bh=Zh4Yhi3Tywh+/QQobU9Ee9bq+f4XS8QCzAp5NH7zedQ=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=VohnKDLqB1iqaMPYrCbezqKt1DNZJOvGqtP3UsTTLqLZZ+fYbGaXz3zpFCA0ceMNeEeeu35NA5QoNfzrFicb74bnEBY7bw8Byx4c5lTfwMxR8jqmBUkuosaMUrR/E4+kELEOmCz+8gkXWeNdRko+BcMba7TS6kiKPiamn4ov300=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Xa0sRwap; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=olEOF2aI; arc=none smtp.client-ip=103.168.172.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Xa0sRwap";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="olEOF2aI"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfhigh.phl.internal (Postfix) with ESMTP id B8D2A1400163;
	Tue, 28 Jul 2026 18:20:24 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Tue, 28 Jul 2026 18:20:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1785277224; x=1785363624; bh=iNioRlkQgHpAT7qtuEMaAlXwPhUZ+lms+jb
	hK+1eNaw=; b=Xa0sRwapIYgaK5s6o082EuqrznT20Nv5US6sUb9mNXkwOfVAw1F
	OKkhPupMZk6Zj3gHVX/yma2s1YuZrmIMwhaaG7wfIJ0aTB+zgv9aUTJPSLLXXmva
	tZZ3rvSo6PhhZjIjEBv1mHi0BdignMmuhJK4N5B65f5IP1G2hVAkkgi+4LlGn5DE
	y3H/YttScQqOsZK2ruUt8YYcwliNfHJpAO8c6MjXpofd/V/2fxGTuPp9yeRE8JBK
	8hSR9uKv5zBqoGnAW5OQ4HPjwjybtoWs2os9whCDswoCMpw223wZOy58IY4bk0MO
	bCqw+4EROGo8OHKQn7Illxa6KTlNtUegv7A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785277224; x=
	1785363624; bh=iNioRlkQgHpAT7qtuEMaAlXwPhUZ+lms+jbhK+1eNaw=; b=o
	lEOF2aI3gGiYOkB5LZ5OAxb0s/GNa3PjLmacPCtYeB7deAqsxzbgeli65Bn/dS21
	2kbqHOJOy17+phuNfWTw9KCKt24KyRIfQVY4VRqSIWiNNhLEQINB952oyjTvR0Wv
	3UUrM2/wRbKme+NKL+bbaFqA/gABlNotmh+5rGR56dIXM1IpbwV0FHSul/ux4+aY
	XO8xoxamPwH4w75H+5iBWfwCJgrWbnLB3STpTGEWpoeh1Vntx27kkb67crZf+4/A
	sXTeK2iZkrjA8Tf7mzKQYJgT9i/CN6UA2cvnY4g+KoDGNL/2dQ5GZ47yCnNuU0EM
	QwHvZz/8QHRdfGxGkjsvQ==
X-ME-Sender: <xms:KCtpaq27Z1nu4OcOuj8q4kp3-GMGQuPM5KY9T0vFzj81wmMU3ioK3Q>
    <xme:KCtpagyYtUTKj1aCBqXyaf85xUhrMVIBO5d7bJw4Ugaj-9UJSPXMJ6K7EV8eUgRSC
    W971v8Rl-omo6R9y36E5j0fTbSvTP4eBTvtv80Z2aP4HtbJ3Q>
X-ME-Received: <xmr:KCtpasvfv0Nvl2ow1OAusjev5xV_x_KSldOkWPxEybmJPo4kvitnHdANSLdumJ-d5KmHI1e41c7vPQrq1V-aXvYm-ljjHH0>
X-ME-Proxy-Cause: dmFkZTFPbqVXSo8qOEuHKvHwMj3TIFX4qU+c9TuEPJj/WQ4CR+qMFeSVN+okTA4UQN7i/A
    RL/tUfaK21zyzcdIzIhns4Z0ZmevYD225H1Y0+bpNqjpGP2BQ5YJQhHCLVW6L+v8JfY6jA
    mvglJIGbQ6IBp3hLuhblbf8maSTC3phlwoXueyCndNfwqoVEJgE78dGIUJNhaDtXTCiDNE
    TPlM3mgMpLGVNghKH0aYB+bqWUlB7+AoXQgjoq2qzP/lDxIdV2+VH9d2uuCHvUdBJDQN+p
    Hnm+UAgGK2hrW1J7+xv7ZaTNGX1qLxdMgUzkkp9IqdnP5qqB4eBlyxN8mwZEIup3ckpFWP
    zhS/++QOtCxI4dmipk6mxB2rM5si7no9UVj5148YVbFLHTi/4b4tJY/CEQKjwAyvaFH5IE
    h1v70NV4QhnSzoAVkbVfazjSAuOsJEQ3B5E8vcClYMlVtAKJFVJ/2odx5iB124+kkH6qae
    Ao7DcpICVk1rXPKm+VhVelA3l2OipKVuDZk5IgTC5HBDDPwklcDW94/cH/QV3uOFx1WWwz
    dEyq8nodY/9soD9g+Rp81Izydf4QMzglfKaMRJRS+RCT2+HbEp+qsrYUOk0WQiEr+2OG8B
    8id3jYlBTw9EEb7wggAK13HvAhDLQ8yhZGLFoNiczcv6vJzyIChsUs/a6IAQ
X-ME-Proxy: <xmx:KCtpaiwb1HgaowtgYAGPdgfAhjF7PneCkVJUaPWwSdgH4GY-4lxALw>
    <xmx:KCtpavDovp03I1J4KwCkEkGkoWaCSFOFAgqP9mPErupzpTbjTgZQ-Q>
    <xmx:KCtpagftAByvgAlEcyzS0q_aFKZpQbieTQK-rBT9K3frTy4sXBolcw>
    <xmx:KCtpapms1WOC0ISInVFd1gJoglXZZUYE1jf14NxusxBByW6Xun0CvQ>
    <xmx:KCtpagUHoX8si3lFaOw478TadKMFKWWEB4TZYjBQcV3gMmI5OsldlRE8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 28 Jul 2026 18:20:22 -0400 (EDT)
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
Subject: Re: [PATCH v2 5/5] NFSD: Don't apply NFS version-specific behavior to
 LOCALIO requests
In-reply-to: <20260728165911.462534-6-cel@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
  <20260728165911.462534-6-cel@kernel.org>
Date: Wed, 29 Jul 2026 08:20:18 +1000
Message-id: <178527721881.279875.2278782862210871597@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 29 Jul 2026, Chuck Lever wrote:
> LOCALIO serves NFS clients of every version through one entry point,
> so no protocol version is associated with such a request.
> nfsd_set_fh_dentry() selects version-specific behavior anyway: its
> switch keys off fh_maxsize, and nfsd_open_local_fh() passes
> NFS4_FHSIZE because that is the size of the buffer it copies into, so
> LOCALIO lands in the NFSv4 arm. fh_getattr() keys off fh_maxsize too
> and does run on a LOCALIO open, adding STATX_BTIME and
> STATX_CHANGE_COOKIE to the mask it requests: work on filesystems that
> compute them for a caller that never reads them.
>=20
> nfsd_open_local_fh() only verifies a handle it received, so it has no
> maximum size to state. Pass NFSD_FHSIZE_UNSPEC as nlm_fopen() already
> does, which selects the switch arm that applies no version-specific
> behavior, and state the bound on the copy out of struct nfs_fh as
> NFS_MAXFHSIZE.
>=20
> Suggested-by: NeilBrown <neil@brown.name>
> Signed-off-by: Chuck Lever <cel@kernel.org>

Thanks for putting in the extra research to get a fully baked
solution instead of just using my half baked idea.  I like what you did
a lot.

For the whole series:
 Reviewed-by: NeilBrown <neil@brown.name>

NeilBrown


> ---
>  fs/nfsd/localio.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfsd/localio.c b/fs/nfsd/localio.c
> index 4110be02b750..33b56d1b3f44 100644
> --- a/fs/nfsd/localio.c
> +++ b/fs/nfsd/localio.c
> @@ -11,7 +11,6 @@
>  #include <linux/exportfs.h>
>  #include <linux/sunrpc/svcauth.h>
>  #include <linux/sunrpc/clnt.h>
> -#include <linux/nfs4.h>
>  #include <linux/nfs_common.h>
>  #include <linux/nfs_fh.h>
>  #include <linux/nfslocalio.h>
> @@ -54,7 +53,7 @@ nfsd_open_local_fh(struct net *net, struct auth_domain *d=
om,
>  	struct nfsd_file *localio;
>  	__be32 beres;
> =20
> -	if (nfs_fh->size > NFS4_FHSIZE)
> +	if (nfs_fh->size > NFS_MAXFHSIZE)
>  		return ERR_PTR(-EINVAL);
> =20
>  	if (!nfsd_net_try_get(net))
> @@ -67,7 +66,7 @@ nfsd_open_local_fh(struct net *net, struct auth_domain *d=
om,
>  		return localio;
> =20
>  	/* nfs_fh -> svc_fh */
> -	fh_init(&fh, NFS4_FHSIZE);
> +	fh_init(&fh, NFSD_FHSIZE_UNSPEC);
>  	fh.fh_handle.fh_size =3D nfs_fh->size;
>  	memcpy(fh.fh_handle.fh_raw, nfs_fh->data, nfs_fh->size);
> =20
> --=20
> 2.54.0
>=20
>=20

