Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 975D6542EC4;
	Tue, 29 Sep 2026 15:22:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790695357; cv=none; b=upMbZmL/8OBm8nxIyh86jB2HOQzkFOT5Fi4tBu/smLod2ZgXu3E3pFDS88NaoW+4HZM5v1MrKDSuhGIbPvUOqTmSqsUJX0D7bjuc38FiDkIigP8cL/5ZZh3Kw3rpTiqlLdgLkvu5abYNxM9qH7MxpXV0I4t7IZ+zEyt7+CuhFCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790695357; c=relaxed/simple;
	bh=XkkZPv8qL8cIATjpi2BapNjuxBGjOL3GtIaK5L9afqk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YxnAETuZHAaQzxTPAxpeaYiTkq0tAMVITRLTdDhlNW/n6h7XvZQzOQ2TT7fkuxgY4Hlj15awW/othkhpw1JSJCG64xD5wGuG2lk1CErrSa5lWZbecAeFy1c5U9Ov3VS9nGUwm5jixfldCoL4jSgcVQXqlu4WaqrdSGovWq2BR4o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=anpnVCGK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="anpnVCGK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 30D171F00898;
	Tue, 29 Sep 2026 15:22:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790695338;
	bh=D/ibpmI5jg1a9kUxODZYU60ZnHvdobAWMypDGAeOo8U=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=anpnVCGKi06BDE9uCt53/px/V/Xclaq+d8LO4yKPPxUSJgf0wPpBbfQ0wAIHNm4vj
	 8Vpn5/NxGqe11Gs10voadlisgh3IYeFXu3g+2SJ+7m3jil4LXAdac5/a4Xipc/L0uU
	 uoM6DQpX+wkJM1Xtnp6/eELm3sKLoLKt7BKykQRKJe1I4BAVkcxtL+mbfq5coubEnd
	 AY+5VfQvWQPP+hPh1TvjrAUVXIVRD2udsWqQvO1pm+PtRRNyRs2M8dIsyxgxYbw2fe
	 VVLle+rliswZIrczTvPrFf+OJ3iwkeEU9REFJ1NId2+NyoFakGOZ6TSqsqwJWcI7hD
	 VZ8XSrwjo6+2w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 30CFCF40066;
	Tue, 29 Sep 2026 11:22:16 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 29 Sep 2026 11:22:16 -0400
X-ME-Sender: <xms:qNe7asNumxTZTAqOUMh5yjMfBOgOCMLTp1Im1fFQbesvZUO55nZ2oQ>
    <xme:qNe7atwuBH0bTHFgDQgRZZI2gbAKYX8VhkuKJBPXxg_z5ueXA34isrO5kfjLkizmi
    EFNvD4NKhvLofMkY7_rQhiAplvDhtlXfnLh2eIXdvSAvUoXwm8-jGE>
X-ME-Proxy-Cause: dmFkZTGHwpvTWnenfdWwDpfZ0uSchfAvPs9YUs2fCTjyTe1/aaP/8o/CAtZEpuBnFlnr3l
    qmTkjOPiHUmeNeOJhaD8lnKlk7EMaLK7X5jKQpwMypkRiS4dvAs3YrNT/c5V6Bk4Ga8MRb
    xPq/javh4ijLGFfdkpos6GxlxyGT42Fwa0ltNIGopZ+Mq1Abfhj0eHx9Lz1wE2F5x+0msE
    VuUjojmKduIXDgawsedlXFbIOAX2g6XJhtdhhvodBfsk+7R/r5zcjPGlwzTbqow/k0fhhB
    KSkSmJEw1/zMzycRq5vhO53cykwQS/OPCRkkdIvcZDxPRXq49tm4EIS2v6w4wGkS37Tlih
    UB9WCh5UmtBTKVoM5jZdVRPrR1i0Y/KGM6FHAXdqhHo3g4SwJzfP4kS1hl+kp6sqa3oe5B
    09PI362u5aRRUNoro1OofwHkHSzL/FrFq/CJzhCpmp9MwcGwLzvwm0apSMBCms1xR1uIii
    arKpKGXFmq7VC4eJ8+APDkopGyFyqzktnwewJR+EDrFxuv09iKewKqVtwVJeGBzDK6vRKq
    muINJMxJgehj51nQY/hRISHFHFnxUA4qXxqSbYIxuozvMtbIXSmX4t9k0Hmo9w1FDElKMl
    aRA8ntUnTlF314tfn5h0SudAXalF4N4JRAjlbU/knq2/TyidO7gi2AcylzGg
X-ME-Proxy: <xmx:qNe7alTNQ8tP03wFnXG8YkXYzgfEyS3-F_ZZKA8_XLoQvUUQJAFCfg>
    <xmx:qNe7ao_jrYdhgYHkVlRJV3PlHwP6Y0lqhmeeWnVQ7QeNozJaz2D9Iw>
    <xmx:qNe7avd7MlJGAeGcMrOiqXfK2cDY7WCfVwKtuR1m2DAw7k5rWntO1A>
    <xmx:qNe7atk68NlURP2riS5zADZafdyfWq3T06kwCJcHcbAilNf3Tw3wPA>
    <xmx:qNe7aixKa69McjO_gKvG8A33X8ZmiyzjDY8l7fSWjGAQWfQLOOiD_yiI>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E740A780070; Tue, 29 Sep 2026 11:22:15 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AozynqqzZJs-
Date: Tue, 29 Sep 2026 08:21:55 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Eric Dumazet" <edumazet@kernel.org>,
 "David S . Miller" <davem@davemloft.net>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>
Cc: "Simon Horman" <horms@kernel.org>,
 "Neal Cardwell" <ncardwell@google.com>,
 "Kuniyuki Iwashima" <kuniyu@google.com>, edumazet@google.com,
 netdev@vger.kernel.org, "Alexander Aring" <aahringo@redhat.com>,
 "David Teigland" <teigland@redhat.com>, gfs2@lists.linux.dev,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Jakub Sitnicki" <jakub@cloudflare.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>,
 "Jiayuan Chen" <jiayuan.chen@linux.dev>,
 "Matthieu Baerts" <matttbe@kernel.org>,
 "Mat Martineau" <martineau@kernel.org>,
 "Geliang Tang" <geliang@kernel.org>, mptcp@lists.linux.dev,
 "Wen Gu" <guwen@linux.alibaba.com>,
 "Dust Li" <dust.li@linux.alibaba.com>,
 "D. Wythe" <alibuda@linux.alibaba.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 "Allison Henderson" <achender@kernel.org>, rds-devel@oss.oracle.com,
 "Philipp Reisner" <philipp.reisner@linbit.com>,
 "Lars Ellenberg" <lars.ellenberg@linbit.com>,
 =?UTF-8?Q?Christoph_B=C3=B6hmwalder?= <christoph.boehmwalder@linbit.com>,
 "Jens Axboe" <axboe@kernel.dk>, drbd-dev@lists.linux.dev,
 "Keith Busch" <kbusch@kernel.org>, "Christoph Hellwig" <hch@lst.de>,
 "Sagi Grimberg" <sagi@grimberg.me>,
 "Chaitanya Kulkarni" <kch@nvidia.com>, linux-nvme@lists.infradead.org,
 "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org
Message-Id: <9a68f8a0-474c-44f4-97fa-bbf05b6de529@app.fastmail.com>
In-Reply-To: <20260929071743.23624-4-edumazet@kernel.org>
References: <20260929071743.23624-1-edumazet@kernel.org>
 <20260929071743.23624-4-edumazet@kernel.org>
Subject: Re: [PATCH v3 net-next 3/9] sunrpc: use sk_set_nospace() and
 sk_clear_nospace()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 29, 2026, at 12:17 AM, Eric Dumazet wrote:
> Use the new helpers instead of open coding the SOCK_NOSPACE
> manipulation, so that TCP can later maintain a cheaper private
> copy of this bit.
>
> No functional change intended.
>
> Reviewed-by: Kuniyuki Iwashima <kuniyu@google.com>
> Signed-off-by: Eric Dumazet <edumazet@kernel.org>
> ---
>  net/sunrpc/svcsock.c  | 4 ++--
>  net/sunrpc/xprtsock.c | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 
> 50e5e7f5b762de28c34d0f58cb0c6feb1e3ce79f..2d8cdee0798d540ba8eae589deaac5bd3ff889fa 
> 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -792,11 +792,11 @@ static int svc_udp_has_wspace(struct svc_xprt 
> *xprt)
>  	 * Set the SOCK_NOSPACE flag before checking the available
>  	 * sock space.
>  	 */
> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	sk_set_nospace(svsk->sk_sk);
>  	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + 
> serv->sv_max_mesg;
>  	if (required*2 > sock_wspace(svsk->sk_sk))
>  		return 0;
> -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	sk_clear_nospace(svsk->sk_sk);
>  	return 1;
>  }
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 
> 7f60723fa64d84887e260e5e130e44cdbec6f850..b97c70c12f627630509510facfd3c3cf96ab6cb6 
> 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -858,7 +858,7 @@ static int xs_nospace(struct rpc_rqst *req, struct 
> sock_xprt *transport)
>  	if (xprt_connected(xprt)) {
>  		/* wait for more buffer space */
>  		set_bit(XPRT_SOCK_NOSPACE, &transport->sock_state);
> -		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> +		sk_set_nospace(sk);
>  		sk->sk_write_pending++;
>  		xprt_wait_for_buffer_space(xprt);
>  	} else
> @@ -1615,7 +1615,7 @@ static void xs_write_space(struct sock *sk)
> 
>  	if (!sk->sk_socket)
>  		return;
> -	clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> +	sk_clear_nospace(sk);
> 
>  	if (unlikely(!(xprt = xprt_from_sock(sk))))
>  		return;
> -- 
> 2.56.0.rc1.315.gc6ed9934b7-goog

For the svcsock.c hunks of this patch:

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
