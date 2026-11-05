Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.224
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793841079;
	b=iYy4m0vb1cGNYfRZY0KQ7/vaL4+yQk2IF0rZUTkaCYMHUZpT5etdx98raUAe1yziCxsT
	 MHatmsb3vIBrM7ijUXUZyB3nLuK3CSazah/YwNJz/8vZQj++DTB9Mh9nNS3m10k67t/u2
	 1+O6CKezBrv7TtsrMhCILr/qfNovw0n13Rbt1LOAaRpyOKtIgwXMF7oL7o+Sc+LSsC6tN
	 GWeJ4VgXu4kZlc7eLOKZHUWJ3MnCK8C52E5FtUxbVwZ6WREshTvV/I8nLeK0++9pSL7n1
	 htfzk+nWTAiWaTT81Jn1z5w378XUjhErOnisH0WMSs4rnDlOMWkuPA/CrXYKT2jgV3Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793841079;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=2UlnfVNGDD6KvMEc2fU81K3LEQe/mZwN7o76G/XWM5s=;
	b=bKrIXNXM9tGJosy4SbRYUaTzYwTtihtCifJkkpDuSjDj3qUZYCYW6965XppFMMjaDq69
	 Ki9oHy5zSlr0wPB5QLL40qCzK8huvEGmDNt4ECO0Riu8Ukg/6o6DsY3DLi4FniaJl38os
	 y+kZev7PHYOrJ/Kb/JOgOuAAzDU5OWhTSIXf6fQKfGnIhSZwF4tV122tg5NT/hiujYfos
	 Dcpgin8loeokx8uvKIxw3tmc7gjJbVAqX87Jbiq3ktYGZUxjx0fs6WfrpDushmgxQ04jD
	 sKUJrb/cv7y5MpPHm0afOsBEoZUw58J6OVFe7FWkilp/If3vvfAxnBxIK6JKTmVS2qQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=AtzlCBaZ;
	arc=none smtp.remote-ip=113.46.200.224
Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 598F4606A326;
	Thu,  5 Nov 2026 01:11:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 598F4606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=AtzlCBaZ
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=2UlnfVNGDD6KvMEc2fU81K3LEQe/mZwN7o76G/XWM5s=;
	b=AtzlCBaZdAAK7PW/2RxxZuF3O5U9kqNqHOqZr3+usZ3hWsD75vD1DHHAjBDLN69K87t/D+JoN
	BLAkcNDuIvi3vz32A536gDqVrdVlJFA/ASAmDtEzqVDYL7FlbIehpreFazipnoFBeh8nK82X2fi
	8D3SPhRPG/pvIoAJNgn6jqs=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4jKklT1zbDz1cySG;
	Thu,  5 Nov 2026 09:11:01 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id C6F0C4056C;
	Thu,  5 Nov 2026 09:11:12 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 5 Nov 2026 09:11:11 +0800
Message-ID: <5dcebf01-f1f5-48b0-b5ac-69e7d1c33d24@huawei.com>
Date: Thu, 5 Nov 2026 09:11:00 +0800
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
Subject: Re: [PATCH v2 1/3] rpcrdma: Serialize notification registration with
 device removal
To: Chuck Lever <cel@kernel.org>
CC: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, yuehaibing
	<yuehaibing@huawei.com>, zhangchangzhong <zhangchangzhong@huawei.com>,
	"weiyongjun (A)" <weiyongjun1@huawei.com>
References: <20261103032758.1302493-1-lixiasong1@huawei.com>
 <20261103032758.1302493-2-lixiasong1@huawei.com>
 <03cf178a-bbcf-448e-88bb-84e4dd994baf@slotpi15m67>
From: Li Xiasong <lixiasong1@huawei.com>
In-Reply-To: 03cf178a-bbcf-448e-88bb-84e4dd994baf@slotpi15m67
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems200002.china.huawei.com (7.221.188.68) To
 whupemk300014.china.huawei.com (7.152.185.8)

On 11/4/2026 6:06 AM, Chuck Lever wrote:
> On Tue, 03 Nov 2026 11:27:56 +0800, Li Xiasong wrote:
> 
>> +	mutex_lock(&rpcrdma_device_mutex);
>> +	rd = rpcrdma_get_client_data(device);
>>  	if (!rd || test_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags))
>> -		return -ENETUNREACH;
>> +		goto out_unlock;
>>
>>  	/*
>>  	 * Arm rn_done before xa_alloc() publishes @rn: once @rn is
>> @@ -78,11 +89,15 @@ int rpcrdma_rn_register(struct ib_device *device,
>>  	rn->rn_done = done;
>>  	if (xa_alloc(&rd->rd_xa, &rn->rn_index, rn, xa_limit_32b, GFP_KERNEL) < 0) {
> 
> This xa_alloc() now runs with rpcrdma_device_mutex held, and the
> mutex is module-wide. Every xprtrdma connect, every svcrdma accept,
> and rpcrdma_remove_one() take it. GFP_KERNEL here can enter direct
> reclaim with the mutex held.
> 
> Before this patch, a connect worker that blocked in that wait
> could wait only on its own transport, and every other
> transport reconnected independently. With the mutex held across
> the allocation, a connect worker for transport A that is waiting in
> reclaim on an RPC over disconnected transport B blocks transport
> B's reconnect in rpcrdma_rn_register(). The same holds for an nfsd
> thread in svc_rdma_accept() on a host that also runs an NFS client.
> Device removal queues behind the same mutex.
> 
> The mutex does not need to cover the allocation. xa_reserve() or
> xa_insert() with a slot reserved before mutex_lock(), or
> memalloc_noio_save() around the critical section, keeps the
> serialization this patch needs without holding the lock across
> reclaim.
> 

Thanks for pointing this out. I missed the reclaim dependency while
holding the module-wide mutex.

I'll revisit the allocation path and make sure registration remains
serialized with device removal without introducing this dependency.

Thanks,
Li Xiasong


