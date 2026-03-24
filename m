Received: from out-170.mta1.migadu.com (out-170.mta1.migadu.com [95.215.58.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DA573368AD;
	Tue, 24 Mar 2026 07:39:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774338007; cv=none; b=J7k4Pv7WSFd1VxeDP4lY7fNIFI/f1q4N6IvmR8CFSJIm53Nz1rj2y8YlVcNYEJkaiS9SJWplY8vcNVv4KPJyrsAtGjGfVoWV+4zqCmNffLzhGCbnHZXgznruGwgFclyQnTGDEBUZaUMl767zFXE36BjKvLQc0vfOpnqCEcsvyc4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774338007; c=relaxed/simple;
	bh=mi3gdzaUmtn9w/TP53O7kR6uDy0niGdUMjM0cGZaeos=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=DOdb91N2558otxYeKKoBvdYxcWpABdEVsZX2a2gFP8a0sesQPsTz4a3cZed/0uQoxyzfks1IO4Wunq7ipTSj3oZoYo6r4KNMNfJPlS9gtUGzl8L5BaQf0oSTse3D2VNAfArwlkFZd++yyuN3bOMBhs+OtBPxJDg2lyL9B+1YRUs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com; spf=pass smtp.mailfrom=chenxiaosong.com; dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b=aVYGo8QD; arc=none smtp.client-ip=95.215.58.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b="aVYGo8QD"
Message-ID: <c456a6ce-c883-4631-a5c7-5d2255205546@chenxiaosong.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chenxiaosong.com;
	s=key1; t=1774337994;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=5eOENhlVmNFoGhcyrUHBr89Eq8YlcagZTKhzxwQn70g=;
	b=aVYGo8QDJKCgtWnuX3YYyJNBBQk9h054kOklpA3Erm5b6NE/I5cV0UGOiK2Pwm1aCvNXHa
	3pkXx0htAXM2AhwwhNhUaI64M6C/jaGktZyUMtQWE9U27MXqoMhFsrpls0BhhgqFp8JS5j
	HM347bHypBf60h0eBo3YDICFpGg19SxT1BegKfZOCxhS81enNp+fLKWuO2yOrL8CiFDx4H
	0APOygJrHzzq+0BVEyNaghptjEKvw90uWOIFJPTRdrEdNNt1Q3fG5kNOwJOy9+Iz7bfEXp
	nVvM9ljkbQuCkCe+K07S0gQfG5yKSPn4SdGhoFYDiFdRLNm9YMOLcEDeTAC97w==
Date: Tue, 24 Mar 2026 15:38:54 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 17/17] netfs: Combine prepare and issue ops and grab
 the buffers on request
To: David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>, Matthew Wilcox <willy@infradead.org>,
 Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 Leon Romanovsky <leon@kernel.org>, Steve French <smfrench@gmail.com>,
 Christian Brauner <christian@brauner.io>, netfs@lists.linux.dev,
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
References: <a1949f85-2e92-429e-83eb-91a7691b9a9b@chenxiaosong.com>
 <20260304140328.112636-1-dhowells@redhat.com>
 <20260304140328.112636-18-dhowells@redhat.com>
 <2d8ce118-2f7a-4b7f-8786-4581b29cb74e@chenxiaosong.com>
 <63655684a778145167a549b4a6251ccf@manguebit.org>
 <3597849.1774336571@warthog.procyon.org.uk>
Content-Language: en-US
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: ChenXiaoSong <chenxiaosong@chenxiaosong.com>
In-Reply-To: <3597849.1774336571@warthog.procyon.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Migadu-Flow: FLOW_OUT

`netfs_put_request()` only decrements the reference count by one, while 
`netfs_put_failed_request()` (refcout == 2) immediately frees the 
request by calling `netfs_free_request()`.

Since the `refcount == 2` after `netfs_create_write_req() -> 
netfs_alloc_request()`, on the failure path, calling 
`netfs_put_request()` will not free the request.

Please let me know if my understanding is incorrect.

Thanks,
ChenXiaoSong <chenxiaosong@kylinos.cn>

On 3/24/26 15:16, David Howells wrote:
> It doesn't matter exactly, as the only difference really is whether it gets
> bumped over to a workqueue, but it's probably better to avoid that if we can.

