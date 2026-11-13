Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.112
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794531746;
	b=ahWuaXCYyN3TSqArOH9ANJuBV5NHjOzrrZpPkuHE33pmBvEu5ZAXdOtViO/JopPgTZsg
	 ERBuwZli5Bzh04zktgUOfOtqLHleeRKVE1A73400nU3NvZZUM3Ik+H3SLu6LA5GL9A4ek
	 DvOohdzLRLe24YaAkOdvH9RtoT6UoqVg3D9/5VXtvjSEz/W0N4PiUMma01yilQNZmUiri
	 47CE3giw+cAliN3qtbfIz43QD1eNrVJmDB4CZyZ9G2QaHgkM05enMhlG3mDxquGZaH428
	 kb8XdOId2L7jTkdry+FX+tVKgedj+iUTetyHTcj5tzCpoTZ4nxuMw7BGOZx1sv4ClCA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794531746;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:From:Subject:To:Cc:References:
	 In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=Wr2360MUv187zwJdy1TqlPIL4TyuTyVm7wXb9LIgYWk=;
	b=oqx2Tl3MGf/r7qZY4/fcjoF52pA1FiYf04/WMxJmlWA8KcrszC16jhW6eGGan9z6iGln
	 +a53VpHR+iNCap3+sEekiPqj4YoNcA++qhZbR5hd/SuQd6GyQrQtHCbkuc1vr2kQMMRtJ
	 RNZUfJMV3MMOqmc+LHEo4h6WzWQlbQBxTLSXep32EJaELBvd19XMyQw6qZYHs9Tms+YwH
	 3HND2051S1kA+Sh6Nf3rSK2vF7AHF3/eeOf/0Y+JjwX/jdvRY+Q2vACbgfCPa4vSu91y8
	 Oh2Bx6cbQSqeZGwrUjgIKnO5mocnju1snbYQL0mz2uBxUchCjzZkoxj7u7QTLSYJ47Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=aruCWX4y;
	arc=none smtp.remote-ip=115.124.30.112
Received: from out30-112.freemail.mail.aliyun.com (out30-112.freemail.mail.aliyun.com [115.124.30.112])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A48D606A327;
	Fri, 13 Nov 2026 01:02:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1A48D606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=aruCWX4y
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1794531742; h=Message-ID:Date:MIME-Version:From:Subject:To:Content-Type;
	bh=Wr2360MUv187zwJdy1TqlPIL4TyuTyVm7wXb9LIgYWk=;
	b=aruCWX4ykRNa/BHUv1EZe77sixNAkMkUZGO+HdCoY8fQjN7DgMWlzLMeaDwuKORQbhinOir+hdT1aQRCf7MJMxCLphbTn2oSyPDC0lQlvy4hckMqnmw7cn2nfWg8dj2e8xNoTIRkRQL5zqzaV0sTU93JCMAS/TX178gRv39nOgw=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0XEd9DxQ_1794531741;
Received: from 30.221.145.53(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0XEd9DxQ_1794531741 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 13 Nov 2026 09:02:21 +0800
Message-ID: <4f83b93d-3173-4e04-9b79-df2413c3be18@linux.alibaba.com>
Date: Fri, 13 Nov 2026 09:02:20 +0800
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
From: Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: Re: [PATCH v2] NFS: don't raise i_size for DEALLOCATE in
 _nfs42_proc_fallocate()
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
References: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
 <20261109113244.4136089-1-joseph.qi@linux.alibaba.com>
In-Reply-To: <20261109113244.4136089-1-joseph.qi@linux.alibaba.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Ping...

On 11/9/26 7:32 PM, Joseph Qi wrote:
> _nfs42_proc_fallocate() raises i_size to offset + len on success, so
> that the cached size is not left stale when a delegation blocks the
> post-op attribute refresh.  The helper is shared by all three
> fallocate modes, but DEALLOCATE always carries FALLOC_FL_KEEP_SIZE
> and never extends the file on the server, so punching a hole that
> reaches past EOF now wrongly enlarges the cached i_size.
> 
> The post-op update would normally restore the size from the returned
> attributes, but nfs_update_inode() applies a differing size only when
> no delegation is held, and then only when no write is in flight or the
> new size is larger:
> 
> 	if (new_isize != cur_isize && !have_delegation) {
> 		if (!nfs_have_writebacks(inode) || new_isize > cur_isize)
> 			i_size_write(inode, new_isize);
> 	}
> 
> With a concurrent mmap writer (nrequests != 0) or any outstanding
> delegation, the shrinking server size is therefore ignored and the
> client keeps reporting a file larger than the server has, in violation
> of KEEP_SIZE, until some later revalidation without writebacks happens
> to fix it up.
> 
> Skip the i_size bump for the DEALLOCATE procedure.  ALLOCATE (mode 0)
> and ZERO_RANGE (which nfs42_fallocate() accepts only without
> FALLOC_FL_KEEP_SIZE) do extend the file when the range reaches past
> EOF, so they keep the update.
> 
> Fixes: 35168eb947f2 ("NFS: fix eof updates after NFSv4.2 fallocate/zero-range")
> Cc: stable@vger.kernel.org
> Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
> ---
>  fs/nfs/nfs42proc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index ab86246fc364f..d76bface87f74 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -84,7 +84,9 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
>  		loff_t newsize = offset + len;
>  
>  		spin_lock(&inode->i_lock);
> -		if (newsize > i_size_read(inode))
> +		/* DEALLOCATE implies KEEP_SIZE, so don't extend i_size */
> +		if (msg->rpc_proc != &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE] &&
> +		    newsize > i_size_read(inode))
>  			i_size_write(inode, newsize);
>  		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
>  		if (nfs_should_remove_suid(inode))

