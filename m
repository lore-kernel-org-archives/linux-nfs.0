Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B7923947B5;
	Sun, 20 Sep 2026 17:22:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789924951; cv=none; b=TRqHaJ6Gs5Oc2Yn3BoNETJxC5WGgyMnkpT2Xf4zX58Oz2ny7cwHVKuPSK4Y1uf3SEJ3xoIeecvIy12yeQ/5ROdOweaOdpLUhnP8fv5FSWeBe1lc00Wu94zJNKuxhdpAaxqH94DNWCqDcFbrYaXTHoHznGplTIeLsZFFLyRETWH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789924951; c=relaxed/simple;
	bh=JbjQ4r18XuBTuD5lsBHbKl9WSV0D3tVV3qu6d2uk+EU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UYTkRjrj47KR9XeNEKZUmpd7sStk3hyNgqrFETA7aZRe3qjNRmXPSbgLqDCsSOSxS4wkgAEnolaRbFz7+HPr0ZYypDuiXK9SZZ+XgwDFHnCFE7Hcf6gSQ3eXRCF3j6xNdmjehY0MMo9RmykhDAac0dCWtyAoauX4m9gzarvOMGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CbcELAtF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CbcELAtF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D4011F000FF;
	Sun, 20 Sep 2026 17:22:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789924950;
	bh=Y4ryNfrMAsm8KB58Bi7LH/O24NK1iFHFLktP/PM27iI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=CbcELAtFlTvzEZtCVrObVJtRqJJGFhLwPIU+P59v64/8jVGZIPBk544FW2AsUog2x
	 cmz/stKmytZ4xuLPcDIL9pp/UpV2l/UH3VrH3cZKe2VcHpZQBH/1sBy9yTPaHE7EOW
	 hK1WamOQewJd7ctqPIZU9K52ug21l/+qqBwuRZzAVZr5CHUl21/c45F21SYN5/iQBu
	 RAZGNho3QmaWgwtK4LFMrNTr4VPexSR79Y0lxeYwSXwpGQOrqy1D/JKsUhIcPcdTYk
	 +nJVC+VoLuiUAJBdKqXTBPQ9110v2utaw/wxz8xS1gpfSHGVUVQbL+sJXPnJBdbBa6
	 GKXoa+C/yFqAQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7F1D6F40066;
	Sun, 20 Sep 2026 13:22:28 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:22:28 -0400
X-ME-Sender: <xms:VBawakZ4J65jWVf0G46P7Ktfh05ui6-Yx9kJwBdT7Cv_9HFtKBQQsw>
    <xme:VBawaqPt8wyo0t8oarnao-V-Jv6f6217xi_J3Bk8aRJ60ZJjTIanW6XViGA3SSusR
    nNwQltTPQQ1Rz8rK9tW5vOTeV6WsBLxyQk5TZHZRHsl093KGtG_aic>
X-ME-Proxy-Cause: dmFkZTEokurct+LG466RWENb4bS0pYaC0e4jnnVs6OiprIT28ofLr0KANonsHf2clU2ZI2
    HFYB5hnFznGY5wGJ/fDZHv5xyX9N+0aBkfL/+mh3Au05BFKVGjJLeqpObIvauAW/IYcgSb
    alFk+2shdsKjvTS+ivb/SU3ldHLciPcYSGhDG/zgioiF0miRZnMkzbGdSSLdehQsVL1XUb
    XLehGBa5MonBfF7JlEyYAXBSp41ahCVI4kuorFjVoHHiynyxgx87mENcrX9wr9gnRoOvgt
    MzTeSwld6fnVwqG5IEDowlnx3j24X92ZBd4TVOwt5rMw8KsejgZERxMy9H49tr6TKxmKeq
    hqOmnPYZupnhtjTRrrhx3BhDRp86z0XEL2Mv61ASKnikjV/vC6y9kFiU8HHs8yrE+QoXHp
    JAV08wrZ+KuCf085X1fQkzYuTeTLV9Mx+0wc/ZQ248HIgEiqgFWfVswA0t7b2LDOZ9w7MI
    U3EVHNJBeX/9QQoDU7S/FljftMHTo/AHkqNPmymFuyYMuCFWASxTO6R9gqEFMJDFbgttC6
    E6HnFKqW/NKp+VSpUgz9nr63utitQEy8LDdiuYEPPoiwvHm/5965KT5zSeBEy+tYKQHDQn
    Kc9GIrDpp8oqBoqc/XzN4l87vk0Hdtp1pVuliBEZ/LOS7TFtBDhtT2IvRbag
X-ME-Proxy: <xmx:VBawagnE8istvw80pF1RqPiz1zJ5rWM_ANI6bmCj6B5UZjTXp-ZCcA>
    <xmx:VBawarxMDqLVvHgowPCgu1jZ5eofD-DLUyQUnkcYxjiaORWiQjDYpA>
    <xmx:VBawakwwOWH0gu6zSyt-fnF-PpEMkH9yaD79kjeA_fu0xLfFb5XZOg>
    <xmx:VBawai-xc1cWra3E99UOypzF270VZjHDYuqh35cFKBDXHJsX4lHVjw>
    <xmx:VBawas9dhlPpmGd4t94fiqZbO3phZSPWcpUnewa6HjspAsWL6vjEfaYF>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 53A7E780075; Sun, 20 Sep 2026 13:22:28 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AFQlgKekMDrg
Date: Sun, 20 Sep 2026 13:22:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Peng Fan (OSS)" <peng.fan@oss.nxp.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org, "Peng Fan" <peng.fan@nxp.com>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Message-Id: <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
In-Reply-To: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
Subject: Re: [PATCH] SUNRPC: use assign_bit() where applicable
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Sep 19, 2026, at 10:27 PM, Peng Fan (OSS) wrote:
> From: Peng Fan <peng.fan@nxp.com>
>
> Convert open-coded if/else with set_bit/clear_bit the assign_bit API.

The above sentence explains the same thing that the diff body shows me,
so it does not add value.

But I don't have any context here: why is this being done? Is there some
kind of tree-wide clean-up underway so that a new feature can be added,
or is this patch just a one-off change?

Including a URL that points to an explainer, or making this patch part
of a series would help orient reviewers.


> Done with Coccinelle semantic patch:
>     // set_bit -> clear_bit => assign_bit
>
>     @@
>     expression cond, bit, addr;
>     @@
>
>     -if (cond)
>     -        set_bit(bit, addr);
>     -else
>     -        clear_bit(bit, addr);
>     +assign_bit(bit, addr, cond);
>
>     @@
>     expression cond, bit, addr;
>     @@
>
>     -if (cond)
>     -        clear_bit(bit, addr);
>     -else
>     -        set_bit(bit, addr);
>     +assign_bit(bit, addr, !cond);
>
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
>  net/sunrpc/svcsock.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index ef7ac080fcd3..d7fa0d1de3ef 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -352,10 +352,8 @@ static void svc_sock_setbufsize(struct svc_sock 
> *svsk, unsigned int nreqs)
> 
>  static void svc_sock_secure_port(struct svc_rqst *rqstp)
>  {
> -	if (svc_port_is_privileged(svc_addr(rqstp)))
> -		set_bit(RQ_SECURE, &rqstp->rq_flags);
> -	else
> -		clear_bit(RQ_SECURE, &rqstp->rq_flags);
> +	assign_bit(RQ_SECURE, &rqstp->rq_flags,
> +		   svc_port_is_privileged(svc_addr(rqstp)));
>  }
> 
>  /*
> @@ -941,10 +939,8 @@ static struct svc_xprt *svc_tcp_accept(struct 
> svc_xprt *xprt)
>  		slen = offsetof(struct sockaddr, sa_data);
>  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
> 
> -	if (sock_is_loopback(newsock->sk))
> -		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> -	else
> -		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> +	assign_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags,
> +		   sock_is_loopback(newsock->sk));
>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpconn++;
> 
> @@ -1290,10 +1286,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
> 
>  	rqstp->rq_xprt_ctxt   = NULL;
>  	rqstp->rq_prot	      = IPPROTO_TCP;
> -	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
> -		set_bit(RQ_LOCAL, &rqstp->rq_flags);
> -	else
> -		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
> +	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
> +		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
> 
>  	/* Completing one message stops ->read_sock with whatever
>  	 * follows still queued, and no path from here re-arms XPT_DATA.
> -- 
> 2.51.0

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
