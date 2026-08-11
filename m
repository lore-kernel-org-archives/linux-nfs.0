Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D39D3803E3;
	Tue, 11 Aug 2026 19:19:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786475969; cv=none; b=VaOEzziWnACwvkP8oasScchWfC2n69Cp8PSrmwU8Fibc4ujC+qaZ6F3chajqh86l0agdars6Bf3d0Sb6xOWxvz0eeGuzja3yZHOVxrtvQ70/OPET07t7yX8zNeG6NEiUIYs2fIiXVmcpS7r4Ri6AQWVoMTX4YuABYNNkrpBfVBA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786475969; c=relaxed/simple;
	bh=SzLGI6zP1fPh2NFkIhUSWOL3CUV7u/H58bRT6C5gKjE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=AhpckO5fiqGujNi9exXpdS537Z7EPzqHiRhgrb+AslKB0D4IhiQ6hLsS7FpCa6CgDTl1tJYROsemxWqBMe49ngj2jCvXhnWYA3cN1d2ee9Q/cF9KJODVccO3sWCFHqs0jtQCMsKYYO11OSmpDmG0UHzN2zOkkdtC6/D3gX22Fd0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FiEiealh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FiEiealh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 757961F00A3D;
	Tue, 11 Aug 2026 19:19:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786475968;
	bh=fabcWO0cobT0/dWKipsXExyKBL0rpgpsG/uiyilvp14=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FiEiealh9Q+qZc5xDtP5LnMwUChwwxO+qpOD/jET9pboo4Ndw6jgnY4YyvEP9VV4N
	 dcgitBHlRSKbCxk34KfJCEL4lgpMJj1XYZD8Hkozqq+hrFQ75WDH3AGbh0g5ypJ2mz
	 J5yanTG/aO1/fN2oh5prk2HeWZBCypUwRrj0SESG2HC0YwCAzfdqSV4intJIXDAbIE
	 39TaImKZ/OtRarRLAN+ZbQLcqDhDNryFp0gGUJAjd0wfiUoKOwYfVviq3KBC+E19oM
	 L/hazH/rmE6ClpKGhB6D7eF2d+Dg77FzKipCSNfc9SCNa4hY0x/9Dq/CEtKtLqONde
	 WgpULmRtrq6gQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AE34FF40066;
	Tue, 11 Aug 2026 15:19:26 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 11 Aug 2026 15:19:26 -0400
X-ME-Sender: <xms:vnV7arAIyysQMIQRR0drYxIHH8qNwdnTPVehPkxWi6M9M5T88Hl_DQ>
    <xme:vnV7asWmD401k4Axuk7gQuEeo7RCazfgRirHSk7c9CRvNjpCIWd0X2cZNUcByJMVR
    FaMy0nO0R_yQILMs3jLag7dQAKJNELk9F2vW3h7_pfAjZV8kGFFeg>
X-ME-Proxy-Cause: dmFkZTF6iluw1IuR0w9/FYLtYu2DXGcM7sDQ9rlWE7xopi0Ijo3FnEebyjQFHzp73wEcUA
    zZSdY7zjAj72zhN7meSHGPTT6RtRMTezrLJC2Hy+yLkOf3nXNZ1lMAkBHro9SjXJTX8EhI
    6ic0jQsI03u0FjgTd+hT5qvLy3GBySD76EG6wmznKf+/bVxuJ3UV6XsjX0O/ndvkdKTLbA
    pY85zFBFRNI6+tU6LDfdVHq2ziuKTV0pOoqfBJ1Z7Xr/LRknbQwJmry/Pb84fnnpRHji6m
    2Iypy6ynTWb7d2qCijC8PwN0hTWOq+3mlIAoD0lQwXILIsKav7Uiw7Ra0az2kuxxGtLJnB
    Sx7Cg2kvhpwBfXIMZet+IWiQXA25e1PPHBU5MzQDcwZi1gF1aqEmY0p/J/qCPXT2fYOxsw
    6Ma9W8IfqFpawwbyMtvbByVYHu2lnr/BD/YhKSEzP+bY6mKFRmR/CbEEhAIMT9I/d0psPv
    TZfcc5Hk6QWBIE/injytbHZytgKQg7N4FSwSFr+YP0VbWora3YcPRfS0pS9NFaAo33Rnlp
    yt7I/bDME2yal08MDlTyu5nGXZRZgbM1pj3Yq3uTT3PULr8yrVeHqq0JXK8+ceE9h8855G
    antDAecm0p6EnKp1M2OIFK9k3ukpQXSvtZdA2dYIhCJAoVoaSleeoV1azJvA
X-ME-Proxy: <xmx:vnV7ajCpmmTM_OTrogd07fLBk23fVOMNyn4jYvwdMWHhmp4HMJrPXw>
    <xmx:vnV7aoxh0Yb6eIroXmaXf2Mr0xjyqFyBL-m4TXLZM3fMrvNskyO1Rw>
    <xmx:vnV7ahZFOfRX5IEvy0amVKOLdEZP1e4P13p51Ncfr5pNcq-3U-IDcg>
    <xmx:vnV7atQFjrHlTffCocnUwuoiS8oCfFuzKSN6QYl-5Lh43yFuNGmx8g>
    <xmx:vnV7asg7cZ08thTmxwuJPTUAFDUoQUXE0w2DxvAVvqPw2d3ooUFnJ5Ti>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8AABD780361; Tue, 11 Aug 2026 15:19:26 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4afRqWdro9F
Date: Tue, 11 Aug 2026 15:19:10 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "J. Bruce Fields" <bfields@fieldses.org>, "Shuah Khan" <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@gmail.com>,
 linux-kselftest@vger.kernel.org
Message-Id: <e1706a70-d9f8-423e-9462-2d77b2e444b1@app.fastmail.com>
In-Reply-To: <20260811-nfsd-nl-hang-v2-4-c0c92b3953c3@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
 <20260811-nfsd-nl-hang-v2-4-c0c92b3953c3@kernel.org>
Subject: Re: [PATCH v2 4/8] SUNRPC: undo partial rpcbind registrations when
 svc_register() fails
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Aug 11, 2026, at 8:03 AM, Jeff Layton wrote:
> svc_register() registers each [program, version] in turn. On failure the
> caller tears the listener down -- svc_setup_socket() frees the svc_sock and
> svc_create_socket() releases the socket -- but the entries that were already
> set stay in rpcbind, now pointing at a closed port. XPT_RPCB_UNREG is set
> later, in svc_udp_init()/svc_tcp_init(), so svc_delete_xprt() never runs for
> this transport and nothing clears them.
>
> Unwind on failure, and stop the walk there rather than registering the
> programs after it. rpcbind matches RPCBPROC_UNSET on
> [program, version, netid] and ignores the address, so the unwind clears the
> netid, not just the port -- the same granularity svc_delete_xprt() already
> unregisters at.
>
> Assisted-by: LLM
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  net/sunrpc/svc.c | 31 ++++++++++++++++++++++++++++++-
>  1 file changed, 30 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 4f402bbf97ba..9ffa87007004 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1183,6 +1183,29 @@ int svc_generic_rpcbind_set(struct net *net,
>  }
>  EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
> 
> +/*
> + * Undo the [program, version] registrations that this svc_register() 
> call
> + * already made, stopping at version @nvers of program @nprog.
> + *
> + * Note that rpcbind matches RPCBPROC_UNSET on [program, version, 
> netid] and
> + * ignores the address, so this clears the netid rather than the one 
> port.
> + * That is the granularity svc_delete_xprt() unregisters at as well.
> + */
> +static void svc_unwind_register(const struct svc_serv *serv, struct 
> net *net,
> +				const int family, const unsigned short proto,
> +				unsigned int nprog, unsigned int nvers)
> +{
> +	unsigned int p, i;
> +
> +	for (p = 0; p <= nprog; p++) {
> +		struct svc_program *progp = &serv->sv_programs[p];
> +		unsigned int last = p < nprog ? progp->pg_nvers : nvers;
> +
> +		for (i = 0; i < last; i++)
> +			progp->pg_rpcbind_set(net, progp, i, family, proto, 0);
> +	}
> +}

For an IPv4 listener, the port-zero callback falls back through
__svc_rpcb_register4() to rpcb_register(). PMAPPROC_UNSET ignores
its protocol argument, so unwinding a partially successful TCP
registration also removes the mappings for existing listeners on
other transports, I would think.

It might be that the best the kernel can do here is tear everything
down if one registration fails.


-- 
Chuck Lever
