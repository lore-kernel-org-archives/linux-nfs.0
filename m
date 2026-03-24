Received: from out-174.mta0.migadu.com (out-174.mta0.migadu.com [91.218.175.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F1C8239567
	for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2026 01:04:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774314265; cv=none; b=O5oOWG4qUtY0MBOMXBNbrVCdo1XI/HE8S+qlW9wNxohiZ/CQoaOGcqucdectEOq+tjLpoqXzfNCyksfn6n2hTUIrHDe7LbMZH5nueUDYmEOGbt6LyuACF1gwwjBpqqfj5DyCuhj+4uStDO2nwbDbu3D38tW44u+Jp9M1b9bw7rM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774314265; c=relaxed/simple;
	bh=VCBWYnp25rctm2RL0ZGr6yuNE7P6effUaZZkJOEqG4g=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Ze6ak7qWx8ju/O5oLglZk/wrGd6T96D0LXMWR7ebKFuGovmFtxr5YTm/h3ERHm8/cUdFnCfPto/jy00kFgFU7nx7CoVBS2D2oKAkgP6G6wm2GE8+YCDFOysebAcLyp09wtvgGDFgeu0kN6av7Y4beeBpO/barMyA+cO2FA1/1Ss=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com; spf=pass smtp.mailfrom=chenxiaosong.com; dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b=EnaS0NnL; arc=none smtp.client-ip=91.218.175.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b="EnaS0NnL"
Message-ID: <a1949f85-2e92-429e-83eb-91a7691b9a9b@chenxiaosong.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chenxiaosong.com;
	s=key1; t=1774314251;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=wYB7aOLuuY4WEpXNaPnEw3hBO7I/ba2yl9abrDSlF+4=;
	b=EnaS0NnL5rSLKHG0i7K4ZsSpjkOYn7Ci9qQB0DaMsPs2Fx0culu8tggklKHwAehxV0IYiC
	0A8fzr5POg+oSf6E9/PWj5de52Opn5QSxijYOtdOASXrIGzsFWF+tsa1ZHFuN8lCXap9sm
	JIYPsxKGiU+fU/gaeP7rTX0/mcvxWRFM6tW4wM1KiZB9ephOwsB+POVQNNwzm8r/qWnT0n
	Rbj5QPmi2EVj+Dm5GRglDmY2muoguEmESvdUqe+ltRm7DA/x4hwKlKxg9FWkluYx7XN8Sd
	8Ozk6K+9ut95LIqTaeDQvyhqFvyW8RJSg2n36MfRcjXOAhybHNKggI2vkriBcA==
Date: Tue, 24 Mar 2026 09:03:29 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 17/17] netfs: Combine prepare and issue ops and grab
 the buffers on request
To: Paulo Alcantara <pc@manguebit.org>, David Howells <dhowells@redhat.com>,
 Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>,
 Jens Axboe <axboe@kernel.dk>, Leon Romanovsky <leon@kernel.org>,
 Steve French <smfrench@gmail.com>
Cc: Christian Brauner <christian@brauner.io>, netfs@lists.linux.dev,
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20260304140328.112636-1-dhowells@redhat.com>
 <20260304140328.112636-18-dhowells@redhat.com>
 <2d8ce118-2f7a-4b7f-8786-4581b29cb74e@chenxiaosong.com>
 <63655684a778145167a549b4a6251ccf@manguebit.org>
Content-Language: en-US
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: ChenXiaoSong <chenxiaosong@chenxiaosong.com>
In-Reply-To: <63655684a778145167a549b4a6251ccf@manguebit.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Migadu-Flow: FLOW_OUT

In netfs_writeback_single(), on the failure path, should we call 
netfs_put_failed_request() instead of netfs_put_request()?

```
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -1041,7 +1041,7 @@ int netfs_writeback_single(struct address_space 
*mapping,
         return ret;

  cleanup_free:
-       netfs_put_request(wreq, netfs_rreq_trace_put_return);
+       netfs_put_failed_request(wreq, netfs_rreq_trace_put_return);
  couldnt_start:
         mutex_unlock(&ictx->wb_lock);
         _leave(" = %d", ret);
```

Thanks,
ChenXiaoSong <chenxiaosong@kylinos.cn>

On 3/24/26 06:44, Paulo Alcantara wrote:
> Thanks for the review.  The above is still broken as it wolud cause an
> UAF on @subreq as we're putting it with netfs_put_subrequest() and then
> dereferencing it afterwards.
> 
> Besides, we could also get rid of 'subreq = NULL' as it is currently a
> no-op -- including in other places.
> 
> Let's wait for next patchset from Dave, though.

