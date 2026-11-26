Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795694248;
	b=3FGikjrb2U3Tk7JV+2eN50Dl38Kb9nqBuDcz69zaFoaosf7ulKCj/qOa642xIagw6Wmz
	 XVESC/dNGRxkygP0nct3L2rhZIc68FnE30oeLW+OvXCTWR2ftWJCe4aXXsJTh7G+Rtpue
	 JjwuYUIbEz+F9slODlnNFf65WtBcvwm21ZVlha651uKWbmGXDzo2971DylM+PDdaqcb22
	 YLb2XcSTAQUu35bHaclhg+6gU8TKxjRJn8gPNE7PH2CjamloG7z817aHxxiuM7BkGFCel
	 LgElbnXWBWFcULXdfo8mqKMdrrf8Z0genqJn8v8rF7d9PJHOmjPA+6kJFaMmKHkesog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795694248;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:In-Reply-To:
	 From:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=Orjg/Sm3uWrFea5Qd+IH/YEbQtQgcSirRXSwttytYyQ=;
	b=ijPB+xSl22sAwoTIl342cPEW3yowK+l77AEjLVPiMkBDRq03O9MBAkGxmgt6AmEtsWUj
	 bleLQcYIvDFYc8XOVJEm7WT3DO9BMJgjAmCApeDB08dNC0zxz9XRBiGwxI7yDi2l1Ki6L
	 VXb7admA0uEaI1+e8rR8WCLt8qXdM7e1fW6uOWgZSdOVpeGaD0wiFq/nKt9NxVjgVIsx9
	 aH6hYu2LweWr712Qf0b+LnHq5h74hzOIv3wM50tUj0CTQMEWDQtjJZzShW3ZA4bmz5fpC
	 JTBGkbN/eiUMmlcIusYdzj2xH++TEENLpx3Httvi0gZkSRAVWutXe+5EsdjFvtb0Lcw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=5VBd8MWe;
	arc=none smtp.remote-ip=113.46.200.227
Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40B12606A31C;
	Thu, 26 Nov 2026 11:57:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 40B12606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=5VBd8MWe
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=Orjg/Sm3uWrFea5Qd+IH/YEbQtQgcSirRXSwttytYyQ=;
	b=5VBd8MWeQouIX/NZgbHZYWmU6dkfFK3cyfUJlvorUQ2pavMZR9nYI5PiTqza6Fv/vKoHsReFk
	uZU4z0masDC9CU5zgDH929vQkyoTPodUTQNHGXDvdlE9gdtMmktYMxFSli0xocrxuy0BiHdfgzZ
	sY6xMFilWGtSbUVCxXtjkKA=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4jZw4d4z28znTXh;
	Thu, 26 Nov 2026 19:56:33 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 142E44058E;
	Thu, 26 Nov 2026 19:57:22 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 26 Nov 2026 19:57:20 +0800
Message-ID: <294d1cbc-9137-4d13-ad61-625db76bd9f9@huawei.com>
Date: Thu, 26 Nov 2026 19:57:19 +0800
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3 2/3] rpcrdma: Serialize removal callbacks with
 unregister
To: Chuck Lever <cel@kernel.org>
CC: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, yuehaibing
	<yuehaibing@huawei.com>, zhangchangzhong <zhangchangzhong@huawei.com>,
	"weiyongjun (A)" <weiyongjun1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-3-lixiasong1@huawei.com>
 <aa51ee58-3404-494b-bbdc-2f9b6a6a7cd6@slotpi15m67>
In-Reply-To: aa51ee58-3404-494b-bbdc-2f9b6a6a7cd6@slotpi15m67
From: Li Xiasong <lixiasong1@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100002.china.huawei.com (7.221.188.206) To
 whupemk300014.china.huawei.com (7.152.185.8)

On 11/25/2026 12:56 AM, Chuck Lever wrote:

> 
> Can rpcrdma_remove_one() call rn_done() for every registrant first,
> and run the release hooks after the walk finishes? The hooks would
> have to be collected somewhere, because a registrant can unregister as
> soon as the mutex is dropped.
> 

Thanks, Chuck. I'll run the release hooks after the walk.

The server calls svc_xprt_close() from its release hook, so a client
xprt_put() that blocks can still delay a server close if the hooks
run serially. I'll look at that ordering too.

> But "Pin the client transport during its callback" in the patch
> description promises more than xprt_get() provides. Let's reword the
> description or note that 3/3 is what makes ep->re_xprt safe to
> dereference in this callback.
> 

Agreed. xprt_get() assumes ep->re_xprt is already valid. I'll note
in the commit message that the teardown change unregisters the
endpoint before xprt_free().

Thanks,
Li Xiasong
