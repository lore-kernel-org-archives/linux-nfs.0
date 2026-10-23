Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792778573;
	b=GPSRQZbjTQwjsYsYOmESmikVMcCcjK3coGCGySGZOZxgO+0vsKjNJCA8VOe2FVcSeHOs
	 mypltDsqjTFEnArSbbCeLtXLWgPPGo+dl6rPgEBqAMYamUeH+RhDjDUd36J2P1UvJ1Fci
	 YykDoNr9QgI+cJpuebZkAwLzaPiGEI6Eyyj18JDCYcWB5bZdrOdYGPbBRZsVamfQwm0vk
	 qUIr9efj/ZnyoocN7nbrcbOl3hDWfX2MlRiEtcU6NK16lyTCOz/KflBORybOBEqFiILQL
	 3kS3VqcCUP24qSzbUTNB+y+sv0+1tJ/5l52p8/XWXUuAjuwByu3s1IBkVXZh4YRoWng==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792778573;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=bZrsg2pWespOvQA5Cm/os7o0gRFOlPEwnPF14eOssXg=;
	b=2hFasL52EwtqIiEjawvRzk1f8mILXqHWEcFAbaeJNP5oWfBDkxUeIc0+7JHCLATrSflp
	 w7YtGfXBNyDGNzMb+DOyKZIngB3wJ0YNpCR09CAV7AhN/uGTY2sql1jTiS5aApdJ3OAwE
	 hA8Z9ADJ8Ez5vsi1Koh13TgnZqDmFHpDXod9XTvcGLWOxqSF56pUk1JwvVdxSbobgHCbG
	 Lcbv1xsUWVs4QCXrK/+r+qPGduAQJsG6mk0enljjng17B0Gz8m+3luz6ya3QLLzKh8MpE
	 37GaxFjiLPKgdxtodK8hgpNppXTEjES0iiejGF9c0BSoa4lRTAhwM53D89vVIAEZYaA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Aj+dSzOM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 086EC606A31A;
	Fri, 23 Oct 2026 18:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Aj+dSzOM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 39CB81F01825;
	Fri, 23 Oct 2026 18:02:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792778572;
	bh=bZrsg2pWespOvQA5Cm/os7o0gRFOlPEwnPF14eOssXg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Aj+dSzOMnsNbCR85xA/8UlAwulQhgqVg6s0SrBEqHv9mtw8ZgcDexSbb4CkRT//wi
	 v3kUyDg+++Ja0Q75FYiSDv71UehLwrfB+O7Gnv4AXBNWJMzILACZrSllAliLZkCa15
	 o6aqE2Q/cmr/gIzJqK2q2lQLU0kJAZDMyeKL6yHlOFnWn1CTDHldHlYOIgWBYu4vZP
	 Tc+pMFBrp3jqked8wbIVFEIj2TjVLnjHOzE3Uwp8nuQbfD+MM088uof+nmBDktRrJe
	 Rte9BZoHmWClW4bAguJv/+eSu3vaONzWwBgVGsoFSpLCYyQGwpBVtk7i8ELyfBfOQq
	 yfff6/eg9SPkg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 80E54F40067;
	Fri, 23 Oct 2026 14:02:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 14:02:51 -0400
X-ME-Sender: <xms:S6HbagXwiaqr3QQa8mcKJMCCl0A5tExUO_ARWNRgWdnxCmCwXt3mbw>
    <xme:S6HbavaDigAlOx9NBgiqLnf9j_nbj46ULziwWS7rv6GhMyjeixANJLCLDoRNg_pYO
    gM-WYPMEefKPWVAYpObjVfbEFLaSg_XHynorfWcIEqt1Ll898H2Phs>
X-ME-Proxy-Cause: dmFkZTEsjtUgDJBYap9qhUMKtLl9jqAKBBCnlwmhLjGIDNZw3TLRNdHTHOB8CQWCO1JeDp
    N3Pu+F5dM5iHuZcPbzp9i09R+ylsLhkbbtgt/zFNnqdc8eceJNMzrbAVEPDIH5Lo83I8O0
    fTnjURMbv4p45dKB7JImhqCVy+ht/Nzc3MVaFRSHcGDE7qDBLc2gE8rjAXGydetLjSn+Re
    r957l+gjjUzVbZ7iJ+oRwxWPDUyed3S795zKEv0bK0lWx17hc1QXWn78cGXMy3fZe+4UcP
    i2hXydb20Ke7aQ4kI+xbLKOBui3Gki6zQaeK/i1HxT6zkn97Ax8VvXKgE2MsP+mUfXh7c2
    yPlu8bKhhcspbdWoLwtnPqs0s+3j706W+cAsMKIhXDzHm6U4PaJCpWnY7L4bRikigB43T8
    WkEG1JyeAcOBksaEIOy2x3njkWVZYaSen1VNLp9eovWmKbs6D/hkmChVaITVz5l5syJDsm
    fRiJNrZ307xbgdS7lM6cj45h7YaRXyN+IjvfKlMwLf0YVJhj3rVsImoBsGRUXscOZhtMJa
    oRBKGreY2k2//AdPdV1m4JGXwNNVQno6iW5bTbP8L1YeyOoSU1ABe2h4F9aM2N4LL6j9Tk
    Qm8PiJU+ircvFjjLUtztJ/bzzRX61lY604tCKmiyuxsjUTjQPuTRu3pHKCMw
X-ME-Proxy: <xmx:S6HbakR-jYIoYwXIRdBhFKTcjqGhAL6u0dfa31zw7pk954ikuv1N-w>
    <xmx:S6HbahP_xi-y2UaJmrV_FSuf-jz7hgZTqxB1RnNVkKUFkp0Hk69eJw>
    <xmx:S6Hbai6ylFS0lDbDCtRkMPvMb29bzbEuCQ2VXyR_3mRouaNnGlmjAg>
    <xmx:S6HbasWkd_WwvzEwPKt1PG9Seb72hy94Og311jgMPKo6Gm9aBDagKQ>
    <xmx:S6HbahOWeR7JGc9YMaKxwne2Er0gWAC_-flNWaIl_1fAxLJ9WOwKmhd9>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5945D782738; Fri, 23 Oct 2026 14:02:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A-i9QTM-Cdfw
Date: Fri, 23 Oct 2026 14:02:31 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Zhiling Zou" <zhilinz@nebusec.ai>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 davem@davemloft.net, "Eric Dumazet" <edumazet@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 vega@nebusec.ai
Message-Id: <5f83b574-224f-4db1-a2f9-60f11a236197@app.fastmail.com>
In-Reply-To: 
 <1106d411594bbf7d4ee8deb7f3a0281475c258c4.1792734713.git.zhilinz@nebusec.ai>
References: <cover.1792734713.git.zhilinz@nebusec.ai>
 <1106d411594bbf7d4ee8deb7f3a0281475c258c4.1792734713.git.zhilinz@nebusec.ai>
Subject: Re: [PATCH net 1/1] SUNRPC: reject AUTH_TLS on backchannel requests
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 23, 2026, at 1:55 AM, Zhiling Zou wrote:
> svc_process_bc() processes reverse-direction calls with rqstp->rq_xprt
> set to NULL. A backchannel caller can supply RPC_AUTH_TLS, which selects
> svcauth_tls_accept(). That handler dereferences rq_xprt while checking
> for transport handshake support, causing a NULL pointer dereference
> before the RPC program can reject the request.
>
> Reject AUTH_TLS credentials when no service transport is present. The
> backchannel request is then denied without accessing rq_xprt.
>
> Fixes: 74aaf96feaca ("SUNRPC: Teach server to recognize RPC_AUTH_TLS")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Assisted-by: LLM
> Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
> ---
>  net/sunrpc/svcauth_unix.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 31a1bc60a5f6d..bac38f3ce9a6c 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -1128,6 +1128,11 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
>  		rqstp->rq_auth_stat = rpc_autherr_badcred;
>  		return SVC_DENIED;
>  	}
> +	if (unlikely(!xprt)) {
> +		/* Backchannel requests do not have a service transport. */
> +		rqstp->rq_auth_stat = rpc_autherr_badcred;
> +		return SVC_DENIED;
> +	}
> 
>  	/* Signal that mapping to nobody uid/gid is required */
>  	cred->cr_uid = INVALID_UID;
> -- 
> 2.55.0

Commit a54a573bceaf, "sunrpc: reject AUTH_TLS on backchannel to prevent
NULL-deref in svcauth_tls_accept", now in the nfsd-testing branch,
already addresses this issue. Thanks for confirming the finding!


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
