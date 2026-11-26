Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795692126;
	b=vHXwqO50KVawiBbuqK8t02IPrXJ4uytnb2sa1Ah5bQBQ6Qa2QrS626Q6gMzMqpKLS7tD
	 A4a+Z97SwdcKGlwIhWPAe9uB+Tt9bMCH2WDCkB1QxXTzVmrMzePSdxvc1T3R2/x4ay5EK
	 uxm7gkvX1JkOpe7lNrigDzruSzf0Q5DhUCEC9iQe9a0PsAwaZL24bioN4OrQNpXlYiy4j
	 uKZtlL+fEvizN3DqVwISfuIgJdTSP8nLUw4DDNZdRj4o4Ztj50seYoSOk/cPgqv9Fae94
	 cByNJfwu3mwuE090r9FtGwvATAFVJz0DIk5zUBi4nrwtr0Mb9T7tjtAd40LRvYjPJ0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795692126;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:In-Reply-To:
	 From:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=lpxeL6mBOuzhgaJ0mcOQe/0z6NpHYTOop99UV9UzchQ=;
	b=SnXhnPwGaTscCOKr7R8jMaopEc5M1Kig3MeJ3XKKDaSTEr4XwufQxRuLcqR6RQkrrbh7
	 HHQ9jmudWHJN9J8wOu5jw2tM+PwyGFOKXwCBIL7n9N9A6OGomoiRjouOTto3KCyNAEiLT
	 59tWYVvSqMeioKUA9YvOhE/6MpTbFN/JBmRLT9gsJAIlhgR0zkPMeeDyAJcCz2/5md8Z2
	 wqLyqD/+9j+7rF/BO+Sg9A0pJtKL6tgeZOl/pFKI/Y/orITwa4Kgd+Qq4zXjeJaUPEWQ4
	 m8ZnabgmOyaY76Y+nTFC9lKu0Bw3jfzw/K9GoA6QHbVXC+T1RHZBD1pC5qyXeDHBLgA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fQYSTRZS;
	arc=none smtp.remote-ip=113.46.200.227
Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 657F1606A682;
	Thu, 26 Nov 2026 11:22:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 657F1606A682
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fQYSTRZS
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=lpxeL6mBOuzhgaJ0mcOQe/0z6NpHYTOop99UV9UzchQ=;
	b=fQYSTRZSi3wT9DO4PLhaWCv/bi1IBeWeNBlqtnNXbhtBMUEAYOzJTBTp5RZ6uLbZRFZi48ecx
	gPQAUupGSYbEjJLw9cnCVTqJ9lqfJS6/XDxL9dq3012mzh49Nb7U2/x9KqJJAaC7G9gJSUJmSHz
	vaRaFSKDNI+wFrLemf1Pisw=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4jZvHr3cHdznTXh;
	Thu, 26 Nov 2026 19:21:12 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id D961740563;
	Thu, 26 Nov 2026 19:22:00 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 26 Nov 2026 19:21:59 +0800
Message-ID: <8cabfc6e-b1c8-4fb7-934d-809254cf582c@huawei.com>
Date: Thu, 26 Nov 2026 19:21:58 +0800
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
Subject: Re: [PATCH v3 1/3] rpcrdma: Serialize notification registration with
 device removal
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, yuehaibing
	<yuehaibing@huawei.com>, zhangchangzhong <zhangchangzhong@huawei.com>,
	"weiyongjun (A)" <weiyongjun1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-2-lixiasong1@huawei.com>
 <187e2fd0-165a-4dc5-a542-6d87d4750bf7@app.fastmail.com>
In-Reply-To: 187e2fd0-165a-4dc5-a542-6d87d4750bf7@app.fastmail.com
From: Li Xiasong <lixiasong1@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk300014.china.huawei.com (7.152.185.8)

On 11/25/2026 12:52 AM, Chuck Lever wrote:
> 
> On Mon, Nov 23, 2026, at 9:18 PM, Li Xiasong wrote:
>> Registration can race with device removal between the client-data
>> lookup, the removing-state check, XArray publication and device
>> reference acquisition. Serialize these operations and client-data
>> teardown with a module-wide mutex, keeping callbacks and completion
>> waits outside it.
>>
>> Enter a NOIO allocation scope before taking the mutex to prevent reclaim
>> from waiting for RPC I/O on a transport whose reconnect needs the same
>> mutex.
>>
>> Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
>> Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
> 
>> @@ -187,8 +209,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
>>  	}
>>
>>  	trace_rpcrdma_client_remove_one_done(device);
>> +	mutex_lock(&rpcrdma_device_mutex);
>> +	ib_set_client_data(device, &rpcrdma_ib_client, NULL);
>>  	xa_destroy(&rd->rd_xa);
>>  	kfree(rd);
>> +	mutex_unlock(&rpcrdma_device_mutex);
>>  }
> 
> Nit: The conventional practice in the kernel is to release resources outside
> the mutex. AFAICT that is safe to do so here; only the ib_set_client_data()
> call needs serialization.
> 

Agreed. I'll unlock right after ib_set_client_data() and do
xa_destroy() and kfree() outside the mutex.

Thanks,
Li Xiasong

