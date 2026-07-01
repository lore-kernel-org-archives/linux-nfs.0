Received: from fout-b6-smtp.messagingengine.com (fout-b6-smtp.messagingengine.com [202.12.124.149])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2889239085;
	Wed,  1 Jul 2026 22:37:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.149
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782945442; cv=none; b=OcGvg2WJhhpD2NFCwTxEXn4nOyFI/drX9kia4Fb2cvSE8Eu7SYapkKft/3eJAt1QH3J8cBDL3ZNk2sq2XnDBFset7pinBk0eTIlYcHz0OBjmniYaabvBi8FYeQhjZfP7Pm877gfQXipF0IwjmO1EAsC69bPaiTxHtUGrKVJ4ql8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782945442; c=relaxed/simple;
	bh=Ou15KDQNEa61pHjgNawwfWDnMpRp2KEYsqZh95pWJkY=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=IAc8bzx/g0Jf9inXApuEy2Sf99A+RvM+Ca2xd4lG3TIkC2ec8bgZ7jg3ioicrs8nO+sxjdrCrJRrTxTEMdbSnOqOmevLqPV9L3TWnVfI9PDyuMwxMVegg+SwQxx56jdDbaYPERPzu+2ayjsa93slgX4Om3RXm7+E1zQFfPpQImc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=nIhH+3uN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=AeQJuq+/; arc=none smtp.client-ip=202.12.124.149
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="nIhH+3uN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="AeQJuq+/"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 195AC1D00073;
	Wed,  1 Jul 2026 18:37:20 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Wed, 01 Jul 2026 18:37:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1782945439; x=1783031839; bh=41L/rh/6AEhDVhOoeprSLl1rzDrdvFnmcdf
	QwI8OZ9I=; b=nIhH+3uNYNrFZ4hDmtYR8BnCLBxKW3E6ULsEI4oFTxVyPLJwGiM
	Kw0uHmJo0Sc5BQnUBdCmeOS/0mCqu9utud2DzclHz7xzhFAx+E3RZFRZaNC4z9w1
	bx9j3+6jcB91HKu7fOKo+o4/VX5uzCuRMVnQvF/Syi5VW+zTqzgTSMbcghuTeNmy
	JUCryMTy3gM/G3/P+0UMPY658ojBR5n06ACor//vLN6wqsNl7VTHg7UX0oZvjt/2
	HhlUWFSa7xTGj1ZVWWd7M6j2lgo4zwOkNshalZkNPGwppG2mkRu3PH527y4O3E6K
	whhwBfwwKhX2lzxCB+ZkqI38Tr6Oo/kK8TA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1782945439; x=
	1783031839; bh=41L/rh/6AEhDVhOoeprSLl1rzDrdvFnmcdfQwI8OZ9I=; b=A
	eQJuq+//zCxbiOIVxybZAqQyF0pKE28gd5vVify3EVccYM4qSzsrhkLaCfxeT8Cd
	i8VxpCvu/QIoEjAI8v4LhJ4bPYN5QrDJZA1EdM5Q2svjUURQHmTsqBXsDd782BN7
	G5SU+Q7I6wLBSA8t1IenzvqKVRyziFtlLHd3w3HMaQbo+NDWyBWosfsteXtrHCfJ
	xNETU9B3ErxbBo9Z9Udt5XNsdG+y6bB/nrcxsiOGjPApmInJ2G1x1SnklE5YIQyh
	q2FYYL8s95x9UyPsVRsti5YKN+9HpMDJZaL5QUgjBv5BCrHsHSlR2/IRqiMBok7o
	v/VtfhbkylY3jM7Cc3LFA==
X-ME-Sender: <xms:n5ZFanoIKkJuvsba6zMM9Z-O_T2dEEO4UthNri8i-ZXyr3CbZX-Kbw>
    <xme:n5ZFamnth5mrkdufxWr77VixqQOmMUshv2-sSxaSeYyvuAQOpSeliILXJFYmJF7Uh
    FMk8dRVJOfpaQSdk-4F9JKXUKyspINc3Uomsr0aOOHjFJhUxII>
X-ME-Received: <xmr:n5ZFaoebeOqlhir9Is1hHwdkyT4ZhM6Vw3PP8MITsY3SvwfsXYqI6hEQSW5esIe8yZBU31ZfHi1-vkVJx1QX-tpC7XbTmgU>
X-ME-Proxy-Cause: dmFkZTGeoJ2IVBp8qSvW33FMe6SRJYvgYfGW8Bh+0R7Jayy31Y56lADtivbLYLzTDommiF
    apprkWlgd1u77PuWHtvk594PXpp27odzUdoMIcAR+vTuiprwA8gdZIUQfWuLN+98E3a8oh
    fxGtLcCi3fIlyvtKBqIu3BTC9RcxRNoXLNkwsfJtdzfeAaLffa2kXxBI1cHZi1QemuT5mK
    Z+MCE12iMvFTp0GZdR/JmP2TGkZ72AZNyuUbN4XvJk6frZOz0LDWcAOeo/ABTYJwrsfKhf
    QLM9VU32+6tlCMiBue27IUzYdLhfikEPGP1jSF1tWjxqgmqK/+K/Ae+8v/rkr5G9040JEV
    gGZB5mnBAThn/3wNZw4P2PMzMy1Hj4XX8Kx/HdEcgolz++HUtSSmHY3jI7IQrzQ4FzW86b
    4z6ExjcihXhV0oEyIGt3jPkdkha300SrtZNrXaH1AIXXCtgB/sHOyJRwFbleoarhzACwuv
    Afa0qgSYHIuSB9peU8C7T5I8LyUCIIAIEZ4Y4wtO39oWaTxJCeZ8SJL+xJ7Fj5wvQcj+Dn
    rov3c/s7Lh9cm2yNgS+Md5x/SUMNXElz2e2ZSCZT0CObpIyLpIA79RyLuzWSscG1hOQfvL
    +yAXLgxRY37EnOIRLQHOvxNzEyWdPhFWOJtPa5z7pGTCY6jYfzZJGFCP472A
X-ME-Proxy: <xmx:n5ZFaqo4K7UnmDsHx-8OvgF4FugH7o1LTh7IRxqg04zUDmjlRsbtKA>
    <xmx:n5ZFaqPYDmp4qQhNaVh8Uyd-eAprr0JkHSi160cAvSdYJpDiQqxnPg>
    <xmx:n5ZFaliWBAfmvDAy4-vIDRA_aZYh4pIS7LxNmQEkihRGiUEnbSkQ5Q>
    <xmx:n5ZFaltMzXhvma9P8tJpZ1wL6VUJVd4Wx0J1XoxYs82g0h-5Jj8Zdg>
    <xmx:n5ZFaleBGrgtUdKQGlU7GCGc65l81kZ5-nXhryevbdtgD26-XQ7vSA3t>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 1 Jul 2026 18:37:17 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Chuck Lever" <cel@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH v4 3/4] sunrpc: guarantee a thread per CPU-bearing node
 when auto-distributing
In-reply-to: <20260701-sunrpc-pool-mode-v4-3-b3d867e4c8f9@kernel.org>
References: <20260701-sunrpc-pool-mode-v4-0-b3d867e4c8f9@kernel.org>
  <20260701-sunrpc-pool-mode-v4-3-b3d867e4c8f9@kernel.org>
Date: Thu, 02 Jul 2026 08:37:14 +1000
Message-id: <178294543416.27465.13728385295856292815@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 02 Jul 2026, Jeff Layton wrote:
> svc_set_num_threads() spreads the requested thread count evenly across
> the service's pools. In pernode mode each pool maps to a NUMA node, and
> svc_pool_for_cpu() steers an incoming transport to the pool for the node
> it arrived on. When fewer threads than pools are requested, even
> distribution leaves some nodes' pools empty, and a transport steered to
> an empty pool has no thread to service it.
>=20
> Floor each CPU-bearing node's pool at one thread when auto-distributing a
> non-zero count, so no such pool is left empty. The resulting total may
> exceed the requested count. This only affects the auto-distribute path
> (a single-value array, i.e. svc_set_num_threads()); callers that set
> per-pool counts explicitly via svc_set_pool_threads() are unchanged and
> may still set a pool to zero. Nodes without CPUs (e.g. memory-only nodes)
> get no thread, as nothing is steered to them.
>=20
> Assisted-by: Claude:claude-opus-4-8
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  net/sunrpc/svc.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index c9fba7edaace..ae93a6f51087 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -837,6 +837,12 @@ EXPORT_SYMBOL_GPL(svc_set_pool_threads);
>   * are multiple pools then the new threads or victims will be distributed
>   * evenly among them.
>   *
> + * When @nrservs is non-zero but smaller than the number of pools, even
> + * distribution would leave some pools empty. Since each pool maps to a
> + * NUMA node and only services transports steered to that node, every
> + * pool whose node has CPUs is instead guaranteed at least one thread.
> + * The resulting total may therefore exceed @nrservs.
> + *
>   * Caller must ensure mutual exclusion between this and server startup or
>   * shutdown.
>   *
> @@ -861,6 +867,15 @@ svc_set_num_threads(struct svc_serv *serv, unsigned in=
t min_threads,
>  			--remain;
>  		}
> =20
> +		/*
> +		 * Don't let a node's pool sit empty while threads are
> +		 * being auto-distributed: a transport steered there would
> +		 * have nothing to service it.
> +		 */
> +		if (threads =3D=3D 0 && nrservs &&
> +		    nr_cpus_node(svc_pool_map_get_node(pool->sp_id)))

svc_pool_map_init_pernode() uses for_each_node_with_cpus() so we can be
certain that each node which has been allocated a pool will have at
least 1 cpu.  Thus that last condition isn't needed.

I would probably address the problem outside the loop with

if (base =3D=3D 0 && nrservs !=3D 0)
   /* We need at least one thread per pool for correct functionality */
   remain =3D serv->sv_nrpools;

or similar.  But your version works too and this isn't
performance-critical code.

Reviewed-by: NeilBrown <neil@brown.name>

Thanks,
NeilBrown

