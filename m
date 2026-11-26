Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795694917;
	b=f0ZpzjHWYRzuc0mXZY0X20FM15M4zLT2IRyp0ojZx/oIMwVERNg4jc2VnGHrB65Foq5R
	 Wib5GDfbbaoemyJ7RzEfy0nAw8RqMinL33lC/ERJMZ0NR0LfVSQF+OeBJdK1FcPzLa4Ll
	 ZHioxxjtzpPs0OW8PCzaE/akOiwGV9stHB5SJSRa3mRZ3PsuBCYvZNYsSfqFhFcch6vKF
	 tOSQu38sc+pQmYKZVFGqD+JbONBNCbYeMz86zCka05v9BWxxevrvy4CSqHoVGkBaWA7uC
	 WQmmdeOHN+WYs13g5zt0P1PY5bmaXh/nQyd6YRd43TZijSqQHgGhHMmEt+VNCqK8EIA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795694917;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:In-Reply-To:
	 From:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=QKC85Ts+xyxVK/C+TeFLmxbktABJxaqhmjGLCcNn1e4=;
	b=31WBbPi/l9vMEnf0liU8uzLVgqg2EzY0sCzM3u62k7yGX1bI4+AAJ/1Mz0ItRKZK9fC7
	 iX9SK6FboLjkI7e3Il4/CdS0J3kojuU+7Af06GuIDMSQ1Z5L9uYr1LeBRN8YHaoeQn9wI
	 qWBooctNo9DO4Rsk0XGIVqhT3TUa+qZ48ON/c3NpA3S1QsVuqIxGmdnzOo3jOH/xClYnT
	 iKaPSfwqtNYO0cRssOSdj0UEJfOhi8g3BQLLy3xXjR7dfEo8dfHeR6btYb6qDEljrknvs
	 HcnT6Oeb0nHxBbli2VQQsCfsmlfm8GRWTznmlBtRjbLZpKTEb+3BZZU3NJssMWmsqEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=M5EBzfCo;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AD30606A31C;
	Thu, 26 Nov 2026 12:08:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2AD30606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=M5EBzfCo
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=QKC85Ts+xyxVK/C+TeFLmxbktABJxaqhmjGLCcNn1e4=;
	b=M5EBzfCo8Jbho9y1ciCD8TWkQM8iuZcZSHKLZc32vqr6uDs2GGjgBovofB5sXPKbXLlGLFyHz
	8ET/AN2NIV1keaMPOrkx3nJmcus1UQLD+QuqEhAPxiJdBxXSELvQRx3i/k1vSFfZV1Et82imogd
	CWyacF+K/KH1ueS9G4Emtw0=
Received: from mail.maildlp.com (unknown [172.19.162.223])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jZwKQ2pXQz1T4Fv;
	Thu, 26 Nov 2026 20:07:38 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id A9E1740561;
	Thu, 26 Nov 2026 20:08:29 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 26 Nov 2026 20:08:28 +0800
Message-ID: <826aff50-15d9-4a4a-acd5-c3e7e985d975@huawei.com>
Date: Thu, 26 Nov 2026 20:08:26 +0800
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
Subject: Re: [PATCH v3 3/3] xprtrdma: Wake connect worker on device removal
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
 <20261124021842.130141-4-lixiasong1@huawei.com>
 <40af69a1-be6b-4afd-acba-2185a7ad832a@slotpi15m67>
In-Reply-To: 40af69a1-be6b-4afd-acba-2185a7ad832a@slotpi15m67
From: Li Xiasong <lixiasong1@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100002.china.huawei.com (7.221.188.206) To
 whupemk300014.china.huawei.com (7.152.185.8)

On 11/25/2026 1:01 AM, Chuck Lever wrote:

> On iWARP, then, this patch moves the wait from re_connect_wait into
> rdma_destroy_id(). I don't see a way around that in xprtrdma. The
> patch description should still not claim that removal unblocks
> endpoint cleanup on every device type.
> 

Agreed. The worker can hit that wait in rdma_disconnect(), too:
iw_cm_disconnect() waits for IWCM_F_CONNECT_WAIT to clear.
I'll note in the commit message that iWARP teardown can still
wait for the provider's connect reply after the worker wakes up.

> Removing the get/put pairs from the CM event handler also moves the
> last ep put into rpcrdma_xprt_disconnect(), before xprt_rdma_destroy()
> reaches xprt_free(). That ordering closes the stale ep->re_xprt window
> I described in my reply to patch 2/3. Let's mention that ordering in
> this patch's commit message, since patch 2/3 relies on it.
> 

I'll spell out that ordering in the commit message.

Thanks,
Li Xiasong
