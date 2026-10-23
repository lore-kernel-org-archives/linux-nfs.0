Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792784145;
	b=Yg7/cqh5iweMMNNB/IsQKSXLyJAJJtaYdaF+Be1jRBZCO4Vinjbr5vNF3j1RIQnS58S9
	 9lQqWO/9187fmVWANkmzsqtdVJEGrypU0IAiPH8aARaoadl9bIJSyPVtOs/7pXI1F7Q2r
	 yeIsZM3C2tpQAoSjTjOVpUVuz1L9z3usfmXse5vXFzFfOsLdjGdUcGwZx2qBKtFzhZlma
	 khBG2H0TMqLMiwtnQON5BK4gWXRFCXMqGqWGGSKjGSAHtcULrWMv4YwAqi76j4xC2ixF3
	 NJtjGVDYkSK1kN9gtDuISqa/3KvZFWK9St2dVMmN2APXBsdTwqDTJtheI6Cpot/Ar0g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792784145;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Zs7T4voI7+RxGzrZ++HmmoP/YnO9yckMQ0Kw6Kbht0k=;
	b=fKQTkZUML6vW9M9S1iGhnUWfZC3/4Cvjkui3rKvCiAvFptwsSyKQiwC1itSROrtZX28j
	 fyOpQmHlHtwzJJE4fO4RF4lnPWYduDF1ZM/9sW1wOZuOugjwTiAoGNF1pgToovr6x+wxr
	 aEL5y2biPnIVCiktDvJ4efvSNBpDePqx9igbldJTUs78/FIRWVBoJOMnxKII6CWGU8PSU
	 iN0yzqM5rh0TOtUepLMgAf04zELToIWjfZLn0zY0kXC/nlQT709aeVbAJ8kQhpjBdBM72
	 SY6NouIFQBbRcnLvUhFmAYBl7RyRxul7oUxDUFIsGWoeJxZSMriMa+RLu4zfQFbWTSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=A0DD4lXs;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0B12606A31E;
	Fri, 23 Oct 2026 19:35:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=A0DD4lXs
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E9661F01825;
	Fri, 23 Oct 2026 19:35:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792784144;
	bh=Zs7T4voI7+RxGzrZ++HmmoP/YnO9yckMQ0Kw6Kbht0k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=A0DD4lXss60vVfZXx6rRdnCsXtIOj/WVdsw/rW47pHjEuqHmQUEU4yDzgkVpREM9j
	 /59XyaP5GEVKF1EE9JgH87lwWRmo3KEDr2DUfPXn9Yyq3SiVcB/koqWIw8zULQpt+A
	 wOMWwvb1AkveR3Cwd6xnwB96khs3ujCEMnSUeq3g4sUdO9a74qG63y1dxXQC1IUsYg
	 VL32FUprkLQ8PapIN6DbISamSOMsaA0Nm/ktD2PVWMAZlSD1Jo7cgPySFC65l4Pl4V
	 IiMRqV+/bNNBY5ER8lv3ggrLvAU+zg5Mhrh70tgJrkKAugY5FhUjSlEVsea7lRWA6o
	 k2+qbZmhA21pg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 60E21F40066;
	Fri, 23 Oct 2026 15:35:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 15:35:43 -0400
X-ME-Sender: <xms:D7fbaunzMAOv8iCTYdk7QSRjiqd9HotGs3zGWt68tMV0RKdzouRaiA>
    <xme:D7fbagoEVhuEOG1OH6iyXlpPLobWg_RA7yE1uCk1Au6z7ri0FwBZJ_WMaL4FlLVAS
    Qftmb7T-vCvYCJVLTuZjZHI4IHxsG91d_lJWps9AnweHn-rzRUws2M>
X-ME-Proxy-Cause: dmFkZTF0Ps9SNVaUJQPiKp6jAEKBtJH3suwWaCJtgK5t5IwPpvijAg27gGGBInaZhdAFz8
    rCwABSnLfE6ZKIRA0+DpPVXkeeuzdDxQmbesG88MGwJtf+FIUv2YwIxXt5SIBB80gRsjbT
    tDJyBHuNQb6uizWbX1oyPUVbvf+DDgEt0I08jdCapzjFVUsNLppx7BRwfXxuh8CKI0A9YD
    TirKFJEy+vpavEmSAgJRgyHmqt4OC6N39lwcLuWrzfqNI3zmeAaq/Xa5r/mZG7AkW6cX2y
    pLiMWWACX+dYaP7DWp4HO2iFw95sHN82RAUfP5PODh+TeVyUPPSOk7yMwD9upN5SFVAMFS
    HS8t3pB/neRzFq/48DZaOHBU7OMQKvA4keVltWtYMxu8zL8vVZEbChWzSaemIC/Npq/RVG
    p6l9pgaqbmc8Sr+/HBzUBla8bD10L7R1KDdiiqGe9osI87Zpgo2b5yr164VMp/mw9ASGib
    d0zkTrGPjJH3U7D5fd0u65K3z0fqbP/OsJzqx0n+zM+gz+pRdTGjsoUFmuKxZBWA2IfqbZ
    p40QxJlYI4FZKKvdrtSxiYik8cirQnJ6XWtzofxBVJazl6PJnTug9HtLtr3khwPu2Kbte3
    zPoZj7bEXRqYaSB7v5qm7TdE4WZCkU/MIIpubHMysFYPXDH4jLehqQcEAIKQ
X-ME-Proxy: <xmx:D7fbaj040DXvTj75qIXxZjMNFhry_KEnCy73vwtCYiviuSuoRP9O7Q>
    <xmx:D7fbauc_S_t2t_fLD9uo8VckSrJKdQFfv92NVC9OhB-BEUpM_B6zLQ>
    <xmx:D7fbaoVQIxjEedRlejv7YXk_pVHm_XFy6SU7uCtZrF-NqHQ-MRHOsQ>
    <xmx:D7fbam_bMRkze1zkoFlAGv0-_T-7kdNXHmEhW5CIRHVX-YVsViHr5A>
    <xmx:D7fbaijIer4azbnPm1GE6Vnmanq4opMvFfGBDn5_bSAhvKH95Cil7SW3>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 417D678273B; Fri, 23 Oct 2026 15:35:43 -0400 (EDT)
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
X-ThreadId: AQ3ibqN4uOeg
Date: Fri, 23 Oct 2026 15:35:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <2edeb013-f54f-44dd-b327-a21481d19601@slotpi15m67>
In-Reply-To: <20261023125033.528835-4-lixiasong1@huawei.com>
References: <20261023125033.528835-1-lixiasong1@huawei.com>
 <20261023125033.528835-4-lixiasong1@huawei.com>
Subject: Re: [PATCH 3/3] xprtrdma: Wake connect worker on device removal
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/23/26 8:50 AM, Li Xiasong wrote:
>  	case RDMA_CM_EVENT_ESTABLISHED:
>  		rpcrdma_ep_get(ep);
> -		ep->re_connect_status = 1;
> +		switch (cmpxchg(&ep->re_connect_status, 0, 1)) {

>  	case RDMA_CM_EVENT_UNREACHABLE:
>  		ep->re_connect_status = -ENETUNREACH;
>  		goto wake_connect_worker;

>  	case RDMA_CM_EVENT_DISCONNECTED:
> -		ep->re_connect_status = -ECONNABORTED;
> +		status = xchg(&ep->re_connect_status, -ECONNABORTED);
>  		rpcrdma_force_disconnect(ep);
> -		return rpcrdma_ep_put(ep);
> +		if (status == 1)
> +			return rpcrdma_ep_put(ep);
> +		return 0;

UNREACHABLE can arrive on an established connection. On RoCE,
cma_netevent_work_handler() delivers RDMA_CM_EVENT_UNREACHABLE to
every cm_id whose cached neighbour hardware address changed, and it
filters only the DESTROYING and DEVICE_REMOVAL states. A connected
cm_id in RDMA_CM_CONNECT passes that filter.

When that happens, the UNREACHABLE case above overwrites status 1
with -ENETUNREACH without releasing the ESTABLISHED reference. The
later DISCONNECTED event then sees status != 1 and skips its put.
The ep and its cm_id are never freed.

Before this patch, DISCONNECTED put unconditionally, so this path
did not leak. Therefore UNREACHABLE needs the same xchg treatment as
ADDR_CHANGE: when the previous status was 1, force a disconnect and
return rpcrdma_ep_put(ep). CONNECT_ERROR and REJECTED cannot arrive
after ESTABLISHED, so those can stay as plain stores, though making
all three consistent would be easier to reason about.


> +	case 1:
> +		rpcrdma_force_disconnect(ep);
> +		/* DEVICE_REMOVAL prevents a later DISCONNECTED event. */
> +		rpcrdma_ep_put(ep);
> +		break;

I don't think this comment is accurate, and the patch description
repeats the same rationale. Leon or Jason can correct me if I'm
wrong.

ib_core removes clients in LIFO order, and xprtrdma registers its
client after rdma_cm. So rpcrdma_remove_one() runs before rdma_cm's
removal handler, and it does not return until every ep on the device
has unregistered. No xprtrdma cm_id ever reaches the
RDMA_CM_DEVICE_REMOVAL state while its ep exists. That is why the
DEVICE_REMOVAL CM event was taken out of this handler in the first
place.

After the forced disconnect here, rpcrdma_xprt_disconnect() calls
rdma_disconnect(), and the DREP or the DREQ timeout still produces
an RDMA_CM_EVENT_DISCONNECTED. The put above is correct, but only
because the DISCONNECTED case now sees -ENODEV from its xchg and
skips its own put. Someone who trusts this comment could later
remove that guard and double-put.

Let's reword both the comment and the description to state the
actual invariant: the first event that moves re_connect_status away
from 1 owns the ESTABLISHED reference.

Also, moving the ESTABLISHED put to ADDR_CHANGE and to the removal
callback means the final rpcrdma_ep_put() for a connected ep can
now happen in rpcrdma_xprt_disconnect(), which frees the ep and
only then calls rdma_destroy_id(). The DISCONNECTED event that
rdma_disconnect() provokes is dispatched while the cm_id is still
in RDMA_CM_CONNECT. If it lands between kfree(ep) and
rdma_destroy_id() taking the handler mutex,
rpcrdma_cm_event_handler() runs with id->context pointing at freed
memory.

Before this patch a connected ep's last put was always inside the
DISCONNECTED handler itself, so CMA ordered the free and the cm_id
destruction for us. The window is narrow, but I don't see what
closes it now. Am I missing something?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
