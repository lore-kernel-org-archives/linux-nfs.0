Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E861346E63
	for <linux-nfs@vger.kernel.org>; Fri,  5 Jun 2026 22:39:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.51
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780699164; cv=pass; b=niDQvhgq3Xla4JSDijLWC6mxRvLQMZ1PKuGufL7eWI4Rt5iJc3n74pgJSkKaO1iPdzqgITpY6sQzHUnmgwgVjNp7XgEUszOiDB9xlbanxAb6wKyQwcI53Byj4bKn4BxQZ8e3Zl1jyvPQikc3o3mSsPTZ0Wf0FrYCAFxzAOYEwGk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780699164; c=relaxed/simple;
	bh=FnXrjnkNI33tVdfHYkYQx3ixiIoGOgfo4flzDs56Vb4=;
	h=From:References:In-Reply-To:MIME-Version:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=hhS5BBsh0LephQRYk8VYQpTJqEJuJ1/tqFr/UzUyE0Vs+PVA4O/6dQCdWk2JgW9ZEUerD29YlJPE13JDp1z/84JsdgjVRBr5D0d01apRNEn7DE3bF26rfbN133j9ePkJcxkBlAfFak9Pc20GhybGAIVKChkTBsTOTikONuJh+Fg=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=fail smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=FpRyl6hB; arc=pass smtp.client-ip=209.85.128.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FpRyl6hB"
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4905529b933so24375175e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Jun 2026 15:39:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1780699161; cv=none;
        d=google.com; s=arc-20240605;
        b=RKmcqxu/S/ApYWxvLswflpKZgkXepzFHiTdCbfU0o0SA6OS89sNiohGJ5Limq9SeZQ
         eaN+YXPDait1gPc+Vk6GnegbK4sa263dp2t/kdJL2T62kq6sQ2hbGtxFJaD9XWhXwgeG
         Gt/XUCiCw5F5TN4R2Vmgw098s6Q/eQc3UffUOpjCO4EU66v5Otcoh28g7AANkvKGg0C+
         umac4ZwAhonwF+HrL/oOk33nFegjswwRmMQgY5zPMNt5HnPo2mVQ14PNHCD0Jl0QErED
         rWYi38Yut7vC6VTFZRMXiGcj8S97DsTkl1JFK0emz6wjAjhWWPGpCNolb7otKFJoG2JA
         /1VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=cc:to:subject:message-id:date:thread-index:mime-version:in-reply-to
         :references:from:dkim-signature;
        bh=Fc6W6oIkjMbqytM9E/cvVD3Cas3uXp/UlRnjJ0px6I0=;
        fh=zclRT0AL/VU5GNEzXpWBMxRZa9n+H0QFGVGjNlhFdfI=;
        b=R4o4QMCq+aAlnNJkGitbDkPW9CrvGUbmnaHNxq6XnU0ed3vh25eMlyqj88gVOIMiHJ
         tLu4JNBR8LCwLNDYvmhwsmb1aBKv8z4oZktHeDeTyFfqQbcv1dkJSw6CM8VCplb0vuhJ
         Xs2ouX+ksCM1GSfypw0Ntluv4vHGnzYQjXBZAkB+MOQ9TuFXZ8gs2KsGPVDi5dnJUA/h
         of1LnmlffkGdF6l1yB6hCS9cDVDO9v2NW8tndgnWvShVH/eFOabuvS0nCGsTxvPh38jB
         Odc/mIk7iqixLLv92GQo5UDggtw/lky+9XiIwEg/vE+B7kuWTOAAVxYSVuH2A4N0+tBe
         yLjA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1780699161; x=1781303961; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:thread-index:mime-version:in-reply-to
         :references:from:from:to:cc:subject:date:message-id:reply-to;
        bh=Fc6W6oIkjMbqytM9E/cvVD3Cas3uXp/UlRnjJ0px6I0=;
        b=FpRyl6hBOA1tRKzb1NYQRH0n5h6zJWNP7+Vv/Jv6xlzl1q5POyjrRAKg75ilawF8dz
         YZf/6fIl1gg2pxLmwnBTzoONP8G+Q23F6GFFah6w7jPrNhz3J8wKTN662LnutQJ0HwZo
         AeR6I8ldnH8XmocD7OeiGdDpjrMAQd4AYc7Pfxvvns9ShM6H5YQk+Ymaybv+3wFkNYNz
         4HRIQc8svHQusKq/c+zTw8DNwHt6aqIktSNVS+Wju7VVbEg4qUr8dMAFSJMO4ybKA8Di
         X+EDBghkYvXAE8lUjoI+U7QOOSbSxWSUTG+XIh3m4W5AofZJDaa99EkfXXwOGfyM44J7
         tXRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780699161; x=1781303961;
        h=cc:to:subject:message-id:date:thread-index:mime-version:in-reply-to
         :references:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Fc6W6oIkjMbqytM9E/cvVD3Cas3uXp/UlRnjJ0px6I0=;
        b=cO74uByD7pdeozI1X2UByAuFrtuiaRvPqJOwW6CqHyTjymMKsbdFzbBqXz2Upvd30N
         uXZ7EBnLBk3hBZ2/lfzqhe4eWGvkablD2zuIQpws++hih15EqYT5qOkIefSbXRGt0t5V
         JfS567u1ENWO+V1SKOKGhkdwnArWw39x+Ep7bRU67g7xbCfI8sooBKK4+EcorfuVaNVy
         vnElHDaa6pGAnIfLhbjxaKjlJWnjmM/Wh3zrdtPy8ZsO8f49ZpE0Et0BRmYIU0wsB+ua
         ce2MUTiJnwmyaN28u4+VYf7wl9s7ca2XzjlO2QJkSSjzVvZPMr4lrNBWdNc94klCQ1Ih
         bUKA==
X-Gm-Message-State: AOJu0YyKH1AHEWQjIuCQmml/XX4GgY3fhe5HWW2/ktthI1QrMdoKeDAk
	ztg//UGA2vuMwmu4wOl6/iIRMp6XQNGhT96y1IM9puWnzjG/2lZ3elY1flyyO09F4T31cjKgLIk
	IVyTmc8FVk89GYwEY9X71Wk0sgU7a9phfzuwn/67ngwYRphTU5p+o
X-Gm-Gg: Acq92OGAswcdE5jGkDWqo5cooXTXccNu1fDHbMJGkynTHPgmTo4p0SnzrjR/1+4enVd
	Y1Kk3Hl/zrIL3N2uott22ft0dkJ6QXll23Z6DDTXhP4virj2I8FLibnlayTt84Nj6JBOtCXu6PF
	/JUqRTZ6F/2bRpkoi+iYUpygNGjgd53xRfp2tqtG3zUeEQ4bFDzrWT6FJVOvrlDw+FlDUU9dkh7
	7rsss6xRh3BkyWO6E1j8Nn2rABQp+OUmIZQ1ps/aJwvJ1YUNMfQOcroqF4Xw3tEAUQu0OqQGFJ5
	tJYYOEwwMIUXWV+07Fzz+7e6Cf4=
X-Received: by 2002:a05:600c:8215:b0:490:a1be:6b01 with SMTP id
 5b1f17b1804b1-490c2560493mr100406745e9.4.1780699161033; Fri, 05 Jun 2026
 15:39:21 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
References: <20260605223118.75092-1-cel@kernel.org>
In-Reply-To: <20260605223118.75092-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQIiV4E/dqzlDyccSLfgm6X2NNlNbLWlyTfw
Date: Fri, 5 Jun 2026 16:39:20 -0600
X-Gm-Features: AVVi8CdXBg5Y8jbUNOnF8jvT6U-MYB1M6GFzsUq2DqSnz6vAYtQ5xwc8jaW0bKE
Message-ID: <32141f1303369612966329d18bc37c0d@mail.gmail.com>
Subject: RE: [PATCH] svcrdma: Avoid direct reclaim when allocating Read sink buffers
To: Chuck Lever <cel@kernel.org>, Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset="UTF-8"

Thanks Chuck, give me a few to test it out!

> -----Original Message-----
> From: Chuck Lever <cel@kernel.org>
> Sent: Friday, June 5, 2026 4:31 PM
> To: Mike Snitzer <snitzer@kernel.org>
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org; Chuck Lever
> <chuck.lever@oracle.com>; Jonathan Flynn
> <jonathan.flynn@hammerspace.com>
> Subject: [PATCH] svcrdma: Avoid direct reclaim when allocating Read sink
> buffers
>
> From: Chuck Lever <chuck.lever@oracle.com>
>
> svc_rdma_alloc_read_pages() passes __GFP_NORETRY, which limits the
> allocator to a single round of direct reclaim and asynchronous
compaction per
> attempt. Under memory pressure or fragmentation that round can take a
long
> time, and the fallback loop repeats it at each order, multiplying the
stall while
> the RPC waits for its Read sink buffer.
>
> The contiguous allocation is opportunistic: when it fails, Read sink
buffers
> come from the pages already in rq_pages[]. Direct reclaim effort buys
little
> here. Allocate with GFP_NOWAIT instead, which omits
> __GFP_DIRECT_RECLAIM so the allocator takes pages only from the free
lists
> and returns NULL immediately when none are available. GFP_NOWAIT retains
> __GFP_KSWAPD_RECLAIM, so a failed attempt still wakes kswapd to
replenish
> higher-order pages in the background, and it already includes
> __GFP_NOWARN. __GFP_NORETRY has no effect once direct reclaim is off.
> skb_page_frag_refill() takes the same approach for its opportunistic
high-
> order allocation.
>
> Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> Fixes: 18755b8c2f24 ("svcrdma: Use contiguous pages for RDMA Read sink
> buffers")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_rw.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
>
>
> Given the perf symbol resolution inaccuracies I can't swear this will
fix the
> issue, but here's a stab at it.
>
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> index 587e4cd29303..efde26cac961 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> @@ -746,10 +746,9 @@ int svc_rdma_prepare_reply_chunk(struct
> svcxprt_rdma *rdma,  }
>
>  /*
> - * Cap contiguous RDMA Read sink allocations at order-4.
> - * Higher orders risk allocation failure under
> - * __GFP_NORETRY, which would negate the benefit of the
> - * contiguous fast path.
> + * Cap contiguous RDMA Read sink allocations at order-4. Higher orders
> + risk
> + * allocation failure under GFP_NOWAIT, which would negate the benefit
> + of
> + * the contiguous fast path.
>   */
>  #define SVC_RDMA_CONTIG_MAX_ORDER	4
>
> @@ -758,9 +757,11 @@ int svc_rdma_prepare_reply_chunk(struct
> svcxprt_rdma *rdma,
>   * @nr_pages: number of pages needed
>   * @order: on success, set to the allocation order
>   *
> - * Attempts a higher-order allocation, falling back to smaller orders.
> - * The returned pages are split immediately so each sub-page has its
> - * own refcount and can be freed independently.
> + * Attempts a higher-order allocation, falling back to smaller orders.
> + The
> + * allocation is opportunistic: it takes pages only from the free
> + lists,
> + * without direct reclaim, so it fails fast under memory pressure. The
> + * returned pages are split immediately so each sub-page has its own
> + * refcount and can be freed independently.
>   *
>   * Returns a pointer to the first page on success, or NULL if even
>   * order-1 allocation fails.
> @@ -775,8 +776,7 @@ svc_rdma_alloc_read_pages(unsigned int nr_pages,
> unsigned int *order)
>  		SVC_RDMA_CONTIG_MAX_ORDER);
>
>  	while (o >= 1) {
> -		page = alloc_pages(GFP_KERNEL | __GFP_NORETRY |
> __GFP_NOWARN,
> -				   o);
> +		page = alloc_pages(GFP_NOWAIT, o);
>  		if (page) {
>  			split_page(page, o);
>  			*order = o;
> --
> 2.54.0
