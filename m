Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793736724;
	b=JhCPMzhu/jzK1/Ww8+1k6mwux5ELEp4ofxvSjtG/ZjqZhlnlPnlRS7KLpUGhlvrwtJ/L
	 a7xBigIllYsoPenz83dWUE8xpD79l6ku/1YaURa93kodlta/7iQDbgxivuevX7vXwcFyc
	 p9N0gReAdKVvnnpj8gzanZ7/S0Thd59L/pWuY/2mYIhTJafkCg4Y0AnbFYrkt0rmCy4Ot
	 eqSNTyEJ2LLJHQNrBcBCMpJSIrtKNtzGP4nzu9LG5Ini8bCWEyyo1TukWB4xg/r7+Bnsg
	 wQLRqLr5/29HvQL+x8UbdSRgE31yvXqHwr6y2uUSPu/EhqhgqZobeJkNtic9Ras2eeQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793736724;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=LeE+MWHrgTUB+WqcVRjNoSznYn2YjEIF4vFqibDol/c=;
	b=VYf4kXLwooxt83RqpNIvmLTjvYZOLMuTkK9sc5I7GpQrgYUV96x+NS07bIbUHqP97Ifi
	 +XabuS8zJZfjhtWqMtmsuFsYibBFaKKp6dNj0kHi7ExxPNa1qIsQMmEHf01Dr25OcJb4x
	 TmjP3c6+bm8HAcVhIpNQk/N50SMBCEoPQ0mYKJ8d8g1Y9DjREpaXqVJBIndiWN1aeAB8n
	 +xEQQ9uU29qdML5cyvkLNp2ylTm7XSGQatVI26s6xpTcvnVFaBrWnwIRTneu0IWGftTA+
	 fsS+Yw6bxehT6IghQSZuoDVPf2rbFSFCJs/N9Gj+2peCPCmYn04099BZ5zb4iw+I0ZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nes1fXq7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 476EF606A326
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 20:12:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nes1fXq7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD34E1F00919
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 20:12:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793736723;
	bh=LeE+MWHrgTUB+WqcVRjNoSznYn2YjEIF4vFqibDol/c=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nes1fXq7L2igAH8deqnyXgj0e53fG5p266sj4EPimth/rUMuupevnHMIGqg2IlQsa
	 LHuDEngWPQ0NmXBZKhyyAppEGYXB5liiSjy/VtA9mT6VjdWADQ2ZHKC00+7vBU0amy
	 Jgkvb6QCqH4gA8eLseUWg159zM8/UKwQaWxO01M9VGv0K1khz7simkfgrLT638hR9i
	 3SAYZijah+7zXa6cXDfrjUSqjeWLMnPJUsJj24MG0Pr13ZNNmr/YZwEdktgUy80Ofj
	 TLoLSUN4dcoYpE2xa0e5SJrdx71oJ1poqHX1mCYM7mj/p2h3NWPc5Z60IQJ4enyUWL
	 8Fc+lJUM8jhNQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id DB5FEF40067;
	Tue,  3 Nov 2026 15:12:02 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 03 Nov 2026 15:12:02 -0500
X-ME-Sender: <xms:EkDqat43DqiqEn1S8bkDgUsGIQdctP2eQ3mJblJFfwFxnwjoH7nZgg>
    <xme:EkDqalsRdjRsqHc9cHHstPRll5Ej4Juz2owdWapSkW91Za_DccOf83MITxBPDQWQc
    DfMFVLWBSZevp1t9Lcf4n8lBHS30hmPVYtY9vEWyn69Q5sAFRsivJo>
X-ME-Proxy-Cause: dmFkZTGAXZViUWwjBMrfXV7CSJrQ/aIOylfJL9jSNMEjw+emr4njSek6v+Ngp/MRGkdcLg
    YH3jLAIJh1mmqunJHQxdxMSoXm6to0XLzs6gHUO9duAo6JPn1neMY+Vu5GALFrtlhd1eWT
    y9JqAgKDMxwRdY6Z6mS0NCDgfeu4msUS8oBJ+NmojxAX4bAeVT+vyjtHvoPsOndDOVNzU5
    fIokcRWbTv80yrmlm8g79iOFZ8D+FHt3P/S5NG7kOCyH1HLeWORc4E23etjnSV7/1JSCFG
    Bo8G+l6XmHT/MTA6apvSvXDj+6QVFzpMXQNpVRY6NNWJCTpPzEbIvmq2BQM27GeQ0TBnjY
    eLkB4ikOC90FhXGc7/L7IU2NFNU/gctKWZDPcq1/Fcadh9UqSqC9D20y+ZItIIH5nRzHjA
    PLtIGtDWYcSNoS2uCTLsIZmCCEL3GWFrcrJ8t9JMgACrdeErI2bnRCbCk0mVHTcS7oscSo
    76yb8UsNtx5F5dptgEgeRNXnUyo9pYxExHdNv+7uzHrCpE19F3NxBOAdSffOYqMKRm62gj
    jKtuGW11MfdrGfcHBPkqoIm3FUw5ZweAxL0bFgcGQ2OHySfwhZA5+lgbNiOujLF3NMoyjY
    +zChgUTOAwQmtrNtuKp3UBhLPWTr8PxvVfbMYlsTobeKEzZ1XGI58Tu6G47A
X-ME-Proxy: <xmx:EkDqanmZVa8GMSamEDf0XsReBSFeL-QgrglNRZdsqGS1krTl1vsr4w>
    <xmx:EkDqahv1DRRHvylpFpSimkum7h43F3467AFLJ4zmd58t-zUs758AIQ>
    <xmx:EkDqal8xHhbO9ZgBqGlJpPlTD7bqTccNXfduS3d3tSm8Orus8AoKlA>
    <xmx:EkDqarOJa_bdXDjXtVkU1wefct4wMkKYkhiQ04o_JIpEjEa1BJbSHw>
    <xmx:EkDqajEwmukqt5mE_dIleY_6FvIUaH8x7a-zvKSiEfSHYWjBcJ1Kl6z4>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BD611B6006E; Tue,  3 Nov 2026 15:12:02 -0500 (EST)
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
X-ThreadId: AOJsgsVqV2Ts
Date: Tue, 03 Nov 2026 15:11:42 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Joseph Qi" <joseph.qi@linux.alibaba.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <0c67f568-586b-456a-be28-65d2ea16b633@app.fastmail.com>
In-Reply-To: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
References: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
Subject: Re: [PATCH] NFS: don't raise i_size for DEALLOCATE in _nfs42_proc_fallocate()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Joseph,

On Tue, Nov 3, 2026, at 1:16 AM, Joseph Qi wrote:
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
>  fs/nfs/nfs42proc.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index ab86246fc364f..914499d30d47e 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -84,7 +84,16 @@ static int _nfs42_proc_fallocate(struct rpc_message 
> *msg, struct file *filep,
>  		loff_t newsize = offset + len;
> 
>  		spin_lock(&inode->i_lock);
> -		if (newsize > i_size_read(inode))
> +		/*
> +		 * DEALLOCATE always carries FALLOC_FL_KEEP_SIZE and never
> +		 * extends the file on the server, so only ALLOCATE and
> +		 * ZERO_RANGE may raise i_size here.  A wrongly raised size
> +		 * can persist: nfs_update_inode() ignores a shrinking
> +		 * post-op size while writebacks are outstanding or a
> +		 * delegation is held.
> +		 */

Is the comment really necessary? It's just restating things from the commit
message, and could quickly go stale if the behavior of nfs_update_inode()
ever needs to change in the future.

Thanks,
Anna

> +		if (msg->rpc_proc != &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE] &&
> +		    newsize > i_size_read(inode))
>  			i_size_write(inode, newsize);
>  		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
>  		if (nfs_should_remove_suid(inode))
> -- 
> 2.39.3
