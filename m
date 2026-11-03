Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793743595;
	b=dVmhZmE/AtubezvepVuAlmtIasC5MZ5KCoFOInOUfLtF+kCTeXGDI88FUXbQFEczgbaN
	 jIXzWvpHzDhG36WJtaSzKAajBuQzqGlrbdlf+ipeKwNavPFWzyK5WOdwx3EQRWpO/0Dsq
	 DNiiNzm3Xn2wd2958fkuEpSggZfjT5eczssV2OOsjtvz/pUSKt4988ow81dJ2VAAAG/oj
	 NN8Bz5DuK0c/feRj3ZmVDdAyT95aei1vqxEO0PDqvi5SF8gzQEMuv30OS4+zro+9bdYMq
	 zcTB946gEiE6KXE5veininp50KZY1pHNkJynSIYeoXJXuEbjgh2q5peSneqxG+KkdEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793743595;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ScO3ouyZ78uAS6tjXHVJd1EsD1KaADZtYK5J1+vTrG8=;
	b=ohpn2obUcfrOFL6J/MVKQZbdL0SvjSJJ25BVJqapc3is1SJIQvHluR8lErVixwQJAHHC
	 HY0lmvx2rdck9d7cXgY3CO9lPgY2bream8awUDBXuV9eV4Bz1vCAmj1a7KZoyTAzTRV/z
	 XKUSQsCzlx+3K4II1p2ex3zMy2h+1QxxQTuWhLgTtGXMDSk80Wj8MRFhtHdqh+Ld8/rJY
	 ARQR+wLOSWLj6SnVREzf2J845Pc8PciKK6To2qm933DTkZPmVwJzSNju41K106dtnzofn
	 V6CVKfFs6uySJrsEMtgcfdkOSGifWxBm0zIJwJkUjfC6FVx28FmuOP/3w45MTPvTDTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fuiwI82H;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EFC5606A328;
	Tue,  3 Nov 2026 22:06:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fuiwI82H
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9F2361F0093A;
	Tue,  3 Nov 2026 22:06:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793743595;
	bh=ScO3ouyZ78uAS6tjXHVJd1EsD1KaADZtYK5J1+vTrG8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=fuiwI82Ht64U0TSWl1E5S/SG3JOC1zl/bt4xsgh2BxnTfGkWJItTMdKOUvZOAFK8v
	 RCo+NarDw70jfZX7hMiY7ALYFZniLhlmEqFbEp/jeLIhZWO5G4UznXFY8mg6UU1keD
	 GHd4vXgY1dNJWyPeclobasnNREvxdyLiAN8A8vAvImhwXZunoP7wmzLgpDn/wxSxCi
	 UL5TPdHwLxLKq5EMo7ZVM2IqCHnAgzSh4T0imrMEpHLCxdq2V4wKHodMQB3iDoRgYG
	 AAILwCJbcHldvJHAtpuulclhLmFsDSp1hmR9q3+QEL3Ebhm2UaRssjavQ5TiXRXrqc
	 bomD4aB4lwAiQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E74D9F40066;
	Tue,  3 Nov 2026 17:06:33 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 03 Nov 2026 17:06:33 -0500
X-ME-Sender: <xms:6VrqamBDj7kYuxjK99qDUbHvbqfopWF6yL8CDmu-23Q9Nx3ZGy6NoQ>
    <xme:6VrqarXDlvD0rRmS3PoA3-WPp3c8dx-JKpA5zV5dPecsLbAUBGouLmIxiDZvVagpl
    7-CkgSEdCkHZa-0tQR5P7F2fRwiqwDs60uhKfSGNxOT8vpjRuvIPRA>
X-ME-Proxy-Cause: dmFkZTECumSA5LJ8AHw+0jTsotqmb3FtJKMZPMFcrJoKy7KhRwRpt3H5oUe/4oMN5BDOhS
    Q0Xc8eHQOoANtJ6foCG9cRZEX6DBeU+f35gBYGynrYbZaIzdlmDtxoixKbefkxcuWlC3Rm
    bd3Q3c6do7sySi5EdaWaqjW7GOalqnz/fctTTw5+9fUfpieBJtYmTAWg1XCKCaQDQ2jYDv
    tJeSRDuLTCnhDjt0KL9uu8dEef88uvyioaSQYKT+zw9/0yKiDAmwOJRRFzRApsEjm2+/ES
    ck5x5+eae1DYzCsTzdU82KdRpcsC+tZ+zPm6n0YcSfGNb+NZylVcQkDDYsznKaHNb4+bsv
    TKIXgc3j1Cq7GdkP9xGgnpY1JHO0TEpY2ZNVT9NGeEFc8ui7yySauzRLu/9LT6UUovNSNx
    SI/jq92hpEUyUkfuwHUouZaO0IDo2PEhvoEpZXYpvQgqQxTdO+LH8+uLYV2yVajkC1/Amf
    rIuBzXg+ESuWqKzFTLzAuQv9VmDnri3+moSqfJVI8QwbrhgTVD49XI48Z0z6rwf8jR1F8t
    NdC3wsnODBW7LIyavCdO3IazbavKM5RExkmyqqAdYnjb8FwRDwsOIVKHMHIITxir8fzs37
    ATfy8g0CwX1fcSGxWpiN6HtQVNkhCDxBusZUGGakXRzAE3SWCkqjx6jqYWRA
X-ME-Proxy: <xmx:6VrqasR8fQyJUKllhdeQ_nuDGAziZpy1UrVh9sv7dFTaxXeXu4-1GA>
    <xmx:6VrqamK3Fk0ELhhdHnLdYIN9fnzn09Yq-l5SYflPp1K3tpX_hkReqQ>
    <xmx:6VrqauSxgYgTgAPqY4L64sVKlV9sedaaOv9fzH4mxg7T-RwwDFbxeQ>
    <xmx:6VrqauKqcOK2gUZqvyUlIFYlXghjyqxISITkvoZ2-bm0kVxiqqHdtw>
    <xmx:6Vrqah9untQ-Tf4L1YsgI8pu7I2flJnyMGoDLXqh4V-DTzFhT1huUNJX>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C4953782738; Tue,  3 Nov 2026 17:06:33 -0500 (EST)
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
X-ThreadId: AuR77pwDWaMc
Date: Tue, 03 Nov 2026 17:06:13 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <03cf178a-bbcf-448e-88bb-84e4dd994baf@slotpi15m67>
In-Reply-To: <20261103032758.1302493-2-lixiasong1@huawei.com>
References: <20261103032758.1302493-1-lixiasong1@huawei.com>
 <20261103032758.1302493-2-lixiasong1@huawei.com>
Subject: Re: [PATCH v2 1/3] rpcrdma: Serialize notification registration with device
 removal
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 03 Nov 2026 11:27:56 +0800, Li Xiasong wrote:

> +	mutex_lock(&rpcrdma_device_mutex);
> +	rd = rpcrdma_get_client_data(device);
>  	if (!rd || test_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags))
> -		return -ENETUNREACH;
> +		goto out_unlock;
>
>  	/*
>  	 * Arm rn_done before xa_alloc() publishes @rn: once @rn is
> @@ -78,11 +89,15 @@ int rpcrdma_rn_register(struct ib_device *device,
>  	rn->rn_done = done;
>  	if (xa_alloc(&rd->rd_xa, &rn->rn_index, rn, xa_limit_32b, GFP_KERNEL) < 0) {

This xa_alloc() now runs with rpcrdma_device_mutex held, and the
mutex is module-wide. Every xprtrdma connect, every svcrdma accept,
and rpcrdma_remove_one() take it. GFP_KERNEL here can enter direct
reclaim with the mutex held.

Before this patch, a connect worker that blocked in that wait
could wait only on its own transport, and every other
transport reconnected independently. With the mutex held across
the allocation, a connect worker for transport A that is waiting in
reclaim on an RPC over disconnected transport B blocks transport
B's reconnect in rpcrdma_rn_register(). The same holds for an nfsd
thread in svc_rdma_accept() on a host that also runs an NFS client.
Device removal queues behind the same mutex.

The mutex does not need to cover the allocation. xa_reserve() or
xa_insert() with a slot reserved before mutex_lock(), or
memalloc_noio_save() around the critical section, keeps the
serialization this patch needs without holding the lock across
reclaim.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
