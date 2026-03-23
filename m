Received: from out-182.mta1.migadu.com (out-182.mta1.migadu.com [95.215.58.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B0042F5A29
	for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2026 18:38:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774291118; cv=none; b=mHo1gFbRdfwuZUXNR/nR01k1WUIu355Afsdm2hY9IXVJ7aSZFOw1Ij4S5t7hJ4zdIKrxj1haMEmIOrkU0llwegGPFE4Y44p5pO2LyZTs9n1Ovo54RXsGoFYAdcD22gG5n/8LqtzlJk3wIOc6NBznuChtLr2vtMz6uTTcN7UPu+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774291118; c=relaxed/simple;
	bh=9zAQOPPXZrLE9As8tHWODwXqS9OjumANAbv6fs3Mhnw=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=TST8803yeKKaJMLKjjgkdoBIDjXoP6NGbiezgTI52wcdPD4hqylbAloXew1+wWsB6iGu0S+TvDvCE+bT0pfYdXbWDCo/t1AWMiKlf8jUAWOdW7Q56r8sTZ8SOyLqzv/OkTKuQ5yZusY+4XSfwydqISAxS0ShYVOWrzbC7NZ1ztQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com; spf=pass smtp.mailfrom=chenxiaosong.com; dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b=ihR/iwj9; arc=none smtp.client-ip=95.215.58.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chenxiaosong.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=chenxiaosong.com header.i=@chenxiaosong.com header.b="ihR/iwj9"
Message-ID: <2d8ce118-2f7a-4b7f-8786-4581b29cb74e@chenxiaosong.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chenxiaosong.com;
	s=key1; t=1774291104;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cr9/0LFyyYkqM0Pl3Rn47qpHPVg9ycKUoMlJD6pGGO8=;
	b=ihR/iwj9opQaeC2aYOw/oDW4g6VvS0xc15eOo1h9NmBXhS7PQ3Y6TbVmve07OXXhbswZ5d
	KV8v4hhNnyDvKhtuPIhhczStJwHvSMcbGHKHjbV0Kmm2+gJX3zSPXeel4drobTC8EAm99u
	+gn4ki6o2knL38XpdrmHem1q50BIu7ymz8ZfrCr/hb0bm8YHHWYpjfqGRASgCxlpEsB8N6
	CpnI4haCxZC5Qr+t1OIcWzTJ4cdAei6RZqJanVcl/47vkXEyc3RoLRSQsWL4LTFqeCEakZ
	gbBXY6sPSaWG5WU54Nm70vLEl1W/eLU1cuIHRefQ7UX0kCe3O5Zqnkw5EIZFlQ==
Date: Tue, 24 Mar 2026 02:37:27 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 17/17] netfs: Combine prepare and issue ops and grab
 the buffers on request
To: David Howells <dhowells@redhat.com>, Matthew Wilcox
 <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>,
 Jens Axboe <axboe@kernel.dk>, Leon Romanovsky <leon@kernel.org>,
 Steve French <smfrench@gmail.com>
Cc: Christian Brauner <christian@brauner.io>,
 Paulo Alcantara <pc@manguebit.com>, netfs@lists.linux.dev,
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 Paulo Alcantara <pc@manguebit.org>
References: <20260304140328.112636-1-dhowells@redhat.com>
 <20260304140328.112636-18-dhowells@redhat.com>
Content-Language: en-US
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: ChenXiaoSong <chenxiaosong@chenxiaosong.com>
In-Reply-To: <20260304140328.112636-18-dhowells@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Migadu-Flow: FLOW_OUT

Hi David,

https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/commit/?h=netfs-next&id=a99af9686490fa9a099679bcbfa1b56c839b8d98

I reviewed this patch in your repository's netfs-next branch (it looks 
slightly different from the version posted to the mailing list) and 
found two issues, the following additional changes are needed:

```
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -161,8 +161,8 @@ static int netfs_unbuffered_write(struct 
netfs_io_request *wreq)
                                         break;
                                 }
                                 netfs_put_subrequest(subreq, 
netfs_sreq_trace_put_failed);
-                               subreq = NULL;
                                 ret = subreq->error;
+                               subreq = NULL;
                                 goto failed;
                         }
                         break;
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 697a47e96d2a..112363f17a84 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -808,6 +808,7 @@ struct netfs_writethrough 
*netfs_begin_writethrough(struct kiocb *iocb, size_t l
         if (bvecq_buffer_init(&wreq->load_cursor, GFP_NOFS) < 0) {
                 netfs_put_failed_request(wreq);
                 mutex_unlock(&ictx->wb_lock);
+               kfree(wthru);
                 return ERR_PTR(-ENOMEM);
         }
```
