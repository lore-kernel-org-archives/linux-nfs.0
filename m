Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C3864FDE58;
	Thu, 17 Sep 2026 17:49:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789667377; cv=none; b=EIr+WC/KfFsQ5bSV/iwufAyIxvvtvP7pkALazWXJIDtDfYjKrxluWPeZ+g0DKgURtbSEXGzmzwjZFGGMxHgKKk29PxSgZC148jJasgqAirzYxrg61lGEHX8yVvtDWXquY/J7D31k9JrIZ7NXeH3E1bW0uQS7qrgDVlfstorXl08=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789667377; c=relaxed/simple;
	bh=qlGLGqUH06pzTCkJSL7fhwohFxkWdIYNz/ZV4aBoKFU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=bmwHmvfh+1fwf3fT9DJqwxLq6iVl9q7WdWJjzRjswDOE4FBLBiE0PBULgnhqrlTZ9n3AqfHoLAg23L7uoeUxoUUR4yY417jBr8VAEaDEqsiV0RvHNW5RdMjll9VTn5U2JMA6MILffRA7ssaPSFcWuiuX7W2lKWGS7hI8mdQ/+w4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F6oMLpHU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F6oMLpHU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0236A1F00893;
	Thu, 17 Sep 2026 17:49:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789667375;
	bh=Z6FUhQvM1fueUk6e12Do3OrY3qA7zAenImxUw4n/zUU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=F6oMLpHU3pduwt5HszTFa2L7DAz/K6YSIxg7aX8Sxo2jrnzWUaPz/k8aQQZhyuENH
	 98kM4TfK8u99EV1K/FDu8LiXDt+0f5u4LsmV9hMzsmK7OI4hQ6dh2AYhBv48jqzWSV
	 7wXBQ8zyzbcukZRO1vNDKDLaM12TNFYLrA7x9CtfnJn1x2Tm0decpcnCW90d5Ya/gn
	 5hUYUZVCkaFPeMRjkeq6ZbcbZVUmoDhQ109G+H/WoQaUobe4Ar/iVNIjK19m8tB9oQ
	 mdLQAlj2/XbqVqIPimVYpC1usU4X28sv1d/SjObdDTDixbeGfjUJOV6041jK4HFfX9
	 PtrzxogargY+g==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 27381F40068;
	Thu, 17 Sep 2026 13:49:34 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 17 Sep 2026 13:49:34 -0400
X-ME-Sender: <xms:Liisam4JbV5gf7K4T41fXZjTTK83uCYPhvO-XxYhDYszVaoiouaeHg>
    <xme:Liisaqur3BuNrpJQgR4uHaMG_qnqXnEr1C738-VWwOgs3N-4VznMZMW8zNK_AcSrA
    MqC4r1sr3mzxCHcS3I5KnAMsHHoZ8sJ-0XGb0aHpRweyH1vu9TXsnim>
X-ME-Proxy-Cause: dmFkZTFgbo5LtZjYkYhdzWE3W3AnMjzTanjxdoOLJV3IM5RMzLBQJ/FHw9J2uHzNWIKnZU
    2Eg6jJ8Yp/j2I9CtuMXI8KfYSOL9qLNUbHCnHJ/+BBzn4JtdjPtx8lAPYY9LJ3KpnhGYZ4
    zITVT8tyYoEt5EJp6WCPZ/yqvFKV2DfJHK6fs8tKrAOoDp8hxGw4U376Kjq+oOMWOdExds
    1Wds+XXhMk0j+UkhcUjbMIykE92Kz1Hs8cgOfHBNrimHpK533XjR4zJHOtjN2L8vdg3AU7
    dhkj1NUXggTCNLLnP4d1VTibnBTVskO2qg/43q68KbkeF6pgrrYdqqjq8WvyqAgZBpZkWD
    TGnmTvk5FDcTVwG09QgNZ/WJ1D+oBoEpvFh4JZQYEAErouUX1IKgodPIaeuDThCnsguCXk
    P/DWWndZj7DX6zQKmZ4Oitdf7CIgVIK6tbbHMzfWkTxUHdLcUVln4oOj47H1HiKyZ9NXgA
    KIUuYky+Hmbk2HBoUi8ZLQ/EmOMACAsd9wIkV2PD5IBlT/hug+7oUlcwpKY8A6dpl8cd+L
    gF2fNf1WDWqxZpWCbBTjl07TF/WmO75YSyeBtALu7iZ3JEgjtyI+VMdn4+nTSeNhkH1p7j
    yC7M7To0xLEGkwxDdI5Iu3S00IAhQkd2aXN7F24tipAPO40OZVZvaAR/ZB3Q
X-ME-Proxy: <xmx:Liisaulc_S2MPlNFhQfmyZN0-6CNXNP5vxo_KNFmYp6D-5BKNgICVw>
    <xmx:LiisavJUE88-LuRXJ_-1RNEbYDPLJ0mQ-1KecG1VtKZ947MjaZPc0w>
    <xmx:Liisaj5mGhvmB7VNyGGG3CxQfcFAhAtPssuV2RLM-8LNsoufLLLL4w>
    <xmx:Liisaj1bcdbnnK3ZimQwTK86Dkv73s_sW4Gq5dRkfFjVsspkQiBOcQ>
    <xmx:LiisapcdgTazdnAyEe4yeBzDT5CobdEe9fxhfcg1-4x4kLPZl0LC6WGr>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id ED23DB6006E; Thu, 17 Sep 2026 13:49:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AUia67BXevYs
Date: Thu, 17 Sep 2026 13:49:13 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Wentao Liang" <vulab@iscas.ac.cn>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 "Trond Myklebust" <trondmy@kernel.org>, stable@vger.kernel.org
Message-Id: <b99eb918-37ae-4bea-8661-b74c8e9b11cc@app.fastmail.com>
In-Reply-To: <20260917162950.2162357-1-vulab@iscas.ac.cn>
References: <20260917162950.2162357-1-vulab@iscas.ac.cn>
Subject: Re: [PATCH] NFS: Fix layout header use-after-free in pnfs_update_layout()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Wentao,

On Thu, Sep 17, 2026, at 12:29 PM, Wentao Liang wrote:
> When waiting for an in-progress layoutreturn to complete, the retry path
> drops the reference on the layout header with pnfs_put_layout_hdr() and
> only then passes the layout header to trace_pnfs_update_layout(). If
> that was the last reference, for example because the layout was torn
> down while the task slept in pnfs_prepare_to_retry_layoutget(), the
> tracepoint dereferences freed memory.
>
> Move the pnfs_put_layout_hdr() call after the tracepoint so the layout
> header is still valid while it is being traced.
>
> Fixes: 2c8d5fc37fe2 ("pNFS: Stricter ordering of layoutget and layoutreturn")
> Cc: stable@vger.kernel.org
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>

This patch is already upstream as commit 13e198a90ca4 (included as part of
Linux 7.2).

Thanks,
Anna

> ---
>  fs/nfs/pnfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 743467e9ba20..aee523134c0f 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2229,11 +2229,11 @@ pnfs_update_layout(struct inode *ino,
>  		dprintk("%s wait for layoutreturn\n", __func__);
>  		lseg = ERR_PTR(pnfs_prepare_to_retry_layoutget(lo));
>  		if (!IS_ERR(lseg)) {
> -			pnfs_put_layout_hdr(lo);
>  			dprintk("%s retrying\n", __func__);
>  			trace_pnfs_update_layout(ino, pos, count, iomode, lo,
>  						 lseg,
>  						 PNFS_UPDATE_LAYOUT_RETRY);
> +			pnfs_put_layout_hdr(lo);
>  			goto lookup_again;
>  		}
>  		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
> -- 
> 2.34.1
