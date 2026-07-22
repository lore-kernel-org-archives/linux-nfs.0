Received: from out-174.mta1.migadu.com (out-174.mta1.migadu.com [95.215.58.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DEB9440A1F
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:36:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784738176; cv=none; b=RtnS6d8Ps8vRVX/iI22TA82w8OPlaqmka0s8ac4FMerlIH/HhqwbHRBSfZb4Ss7cE5bCCqpyPJvsbFMx9UpaCGJjIFBZxayx0pf36jRvxZ9qEllYmQE65b67eZ+XCecFCuUSnLUbw8wCpqgNjIYYSnIh6PpQ5Z2Z45HnMQxlKA0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784738176; c=relaxed/simple;
	bh=t8rRxABCJAA0QH02Y6VgB5C2lYe3Fs3kR4DaqQ1K9bE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QnmJBxhlOsBw8jro3PAPaUR4c/SZUzWmig14U17pgobL5cQU8W03mHjr/hRoilHJrNinKW3JgH8LjNKUwfiD3ePo8tnMWnBkNH90mPtm4JpE5119g2E39wysXGvrFNKY+QTCSRHZ/j2ikeQM9TAGNkzIdKCDbwPZ13d7rpj1VGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=RuTQ2dXC; arc=none smtp.client-ip=95.215.58.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="RuTQ2dXC"
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1784738171;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=bkKbSDToe7oNwQvcp8YwOTva5uUO6i2CXklEvla485M=;
	b=RuTQ2dXCRsKcy1/kVacuK79/2l9Sxb195ZTSUvuelQx2WQefKsjkPfpci1ZEDmJjdyfExO
	emo9F9G1tT5sV9WtqueZ6HGevrY/k82dYd8vEzxboVD9OBTDuou0yd4nO8I5vMtuNUqmqZ
	hnONdAbmlv36HARWV7BoN92iBYteSEI=
From: Usama Arif <usama.arif@linux.dev>
To: Christoph Hellwig <hch@lst.de>
Cc: Usama Arif <usama.arif@linux.dev>,
	baoquan.he@linux.dev,
	akpm@linux-foundation.org,
	chrisl@kernel.org,
	kasong@tencent.com,
	nphamcs@gmail.com,
	shikemeng@huaweicloud.com,
	youngjun.park@lge.com,
	ryncsn@gmail.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	linux-mm@kvack.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] mm/swap: revert to single-folio writes for synchronous swap devices
Date: Wed, 22 Jul 2026 09:36:00 -0700
Message-ID: <20260722163601.1421253-1-usama.arif@linux.dev>
In-Reply-To: <20260722130615.3163560-2-hch@lst.de>
References: 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT

On Wed, 22 Jul 2026 15:06:07 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Kairui Song reported that zram benefits from submitting each folio
> directly instead of batching up I/O because the classic LRU scanning
> benefits from clearing the folio writeback bit in the scan loop.
> 
> Accommodate that by kicking off reads for synchronous devices for

s/reads/writes/ ?

> each iteration.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/page_io.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 


Change makes sense.

After the commit message fix above, feel free to add

Acked-by: Usama Arif <usama.arif@linux.dev>


> diff --git a/mm/page_io.c b/mm/page_io.c
> index e4fa7ffffe8b..c984a4023a65 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -358,7 +358,16 @@ static void swap_add_folio(struct swap_io_ctx *ctx, struct folio *folio, int rw)
>  	}
>  	bvec_set_folio(&sio->bvecs[sio->nr_bvecs], folio, folio_size(folio), 0);
>  	sio->len += folio_size(folio);
> -	if (++sio->nr_bvecs == ARRAY_SIZE(sio->bvecs)) {
> +
> +	/*
> +	 * Write out the iocb if we filled it, or if the device is synchronous.
> +	 *
> +	 * The latter is to work around expectations in the classic LRU code
> +	 * which make synchronous clearing of the folio writeback flag in the
> +	 * reclaim path beneficial.
> +	 */
> +	if (++sio->nr_bvecs == ARRAY_SIZE(sio->bvecs) ||
> +	    (rw == WRITE && (sis->flags & SWP_SYNCHRONOUS_IO))) {
>  		if (rw == WRITE)
>  			swap_write_submit(ctx);
>  		else
> -- 
> 2.53.0
> 
> 
