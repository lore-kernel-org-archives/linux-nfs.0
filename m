Received: from mail-pl1-f169.google.com (mail-pl1-f169.google.com [209.85.214.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E893B442134
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 20:38:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786394339; cv=none; b=cLNFhDvZPwbHZzzEBkXbTmx/R0AOV2a0xT57T1lDFxZZuix/vCxPx76f9sYuMftozlImpRDEs+karVkYqeqMgggRQIwwOpspsFMlhTcOIDW9pyYpxHeWQ6igUZJTO66+A7N+jYrWAO4KIAV86+JtfDXL8w/ZAy/zKv7NK68Aaqc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786394339; c=relaxed/simple;
	bh=uJSRGu+secrn6ELFiY8mCeDfdirixJZ+Vh+vWqrsCQs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ontMZ+miXM9yWezKzDlfGw7D7lYUAKRg50cs6Z6MMJ84t56ovnU/tbRv/COj21uI5sSR0Mwd1yoyLUVclV2zcS4rGUQi3wGHgEnIqEz7W7Gr50rNtGRtNWVa7d9H2cx5xH+YeX36A9OHt+bvhDsb1xEJDjPGR5aTjORj9Sy3Lp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=casQjVQX; arc=none smtp.client-ip=209.85.214.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="casQjVQX"
Received: by mail-pl1-f169.google.com with SMTP id d9443c01a7336-2cab97c86bdso9065ad.1
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 13:38:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786394337; x=1786999137; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=VYp2Tfa4a+eGAB6Piu2ik5k2VivENudTsuNWEkco40o=;
        b=casQjVQXgfPfT4a8Rp7+tK3rt+5o/mi5RbhcDsjjGAzOL2r6d06I10Q9enGM6r6yes
         3M2P/tLm/hEI23sLbSOyiCGW9dcSPqZhBwUfQ2S1/OSosPqq8tgqGWDjVm15q4WGN3n3
         gpqdbdGOJlPkLZ3Obkswmp9AhJ0OFFjV/Hj0/048RiNhIVby1lR9PezcTluSpmUy4UG2
         d/AU2zEuQZ1cqO+dRJv8+zwg8qaI72PQhNY4MFEIPkwcbKEf1VQ8wtBmNI6McGqMlLv5
         fiyQDNYSNsd+Pu9uIP4QLPeNWea076/z/0OJI9uadnXFeT9zMsrRYmo61AQ9wDQaHLCu
         l35w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786394337; x=1786999137;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=VYp2Tfa4a+eGAB6Piu2ik5k2VivENudTsuNWEkco40o=;
        b=f2rC6HJmTdOcGjBz8aIstc5x2E9tfCNAhYrwMZACII9Kw8TgjpTY0hXG8d1uTI5qUB
         cPzi2wyFsAmebEw3QSfulX/ahe+GC2LepwJ70GJ1Cewabt9MCkfb3vpdpxk637ZfmlAX
         2g4VaEwwH5Z1VAJ/+vZJz2sXd4JPvNboxUdzvI75j0NmtXGXD4Idw5rGaQQ8mP83sCxI
         mKZbmB8v99fNLqxmMGRrIGC4aONDkfcdh6go02VaHJXZT43m5VbvtbINseYdtDdcQPhf
         beJseiCbz2LJfIpGluB1UuOj0WIOoJoBWCVYCiGpPcPlIB6QwqwBTJpZs9P20YTXhcUl
         eQIA==
X-Gm-Message-State: AOJu0Yy4mA/xKDSGuLeEbWZi5tgr1tHF1yFzCl+WlD2ANh6VNQ/n+KdZ
	agcX1ul4a+5uqEuFSFzMvDpZS1wKUQH7ckbUpNs371LVuqSRdbjW4vk4pdsFUFwD3lHKQU0moJk
	LRWR1mg==
X-Gm-Gg: AR+sD12GY6SdMmOxC0bIp05w7WAIYC+AYZbM1VgFCSsAsORVJjkPqKYdSL8zeLsjqRO
	aI16gyggbEDiNJWQa8cbt0gJPrBMsiv12+4x5xBym9E0MJFX/zexPQZHN2eyATbZoPUCU129Wax
	j7EtpXntComWmlXFgQfrPTNLThaI0PJJ0C56vpAIrxKpv/ha9Zy3bu2YRpWCSYE6VyTs/lpwMK7
	E9fbOjwlAfCMXlx0zPcPc+RbZpzUyWNitq3Zkw/i8PFKD0NDQ5qfcItllwe9HAOv+0ObHVrtgXy
	re2NIIKPS84oSEHyZcunkBNAcx+WW1UZr1bd1YqcSmsmY47MYar9CE2Igwknp0LqPBfGMvGVGC8
	1+1ZX8A9KEJguuUByEExliP3CETcmJ26TmkLPC2vTnyw6BLyeV8xxm/DolTgIRDjeTnJXmr35OL
	ZZspRQTolji6osUb+jX8EQUYancafesldIZ7mVr7BcK6sXLO95qQjp4veiVTRHwJPN/bcf0gLH7
	tteIgmRuiDbE3VCNR5OUnQ=
X-Received: by 2002:a17:902:ea0a:b0:2ce:b436:272a with SMTP id d9443c01a7336-2d31201ad00mr133605ad.3.1786394336550;
        Mon, 10 Aug 2026 13:38:56 -0700 (PDT)
Received: from google.com (21.168.124.34.bc.googleusercontent.com. [34.124.168.21])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2d14ccd8f1bsm41025825ad.25.2026.08.10.13.38.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 Aug 2026 13:38:55 -0700 (PDT)
Date: Mon, 10 Aug 2026 20:38:49 +0000
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v4 0/5] nfs: modernize direct I/O path
Message-ID: <ano2R8fAeGmsNt9f@google.com>
References: <20260810195040.2877784-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260810195040.2877784-1-praan@google.com>

On Mon, Aug 10, 2026 at 07:50:34PM +0000, Pranjal Shrivastava wrote:
> Modernize the NFS Direct I/O path as a preparatory step to enable PCI
> Peer-to-Peer DMA (P2PDMA) support. Following feedback on the initial
> RFC [1], the modernization and architectural changes are split into
> different series. Additionally, based on the discussion in the v2 [2]
> of this series, the migration of NFS Direct I/O to folios would be
> handled in a separate follow-up series.
> 
> Currently, NFS O_DIRECT relies on the legacy iov_iter_get_pages_alloc2()
> API which does not support the pinning requirements for P2P memory.
> The implementation moves NFS to the modern iov_iter_extract_pages() API.
> 

[...]

I'm calling out a few typos / non-code mistakes:

1. On the cover letter I missed updating the subject to v5 for this series
  (the changelog is noted below).

2. I also accidentally dropped Christoph's Reviewed-by tags on patches 
   1, 2, and 3 during the rebase (given while reviewing v4 [1]).

Everything else in the series is correct as per the v5 changelog.
Please let me know what the right etiquette is? Shall I resend the series?

Apologies for the noise!

> 
> [v5]
>  - Fixed an iov_iter_revert oops in nfs_direct_extract_pages().
>  - Fixed a refcount underflow in nfs_direct_release_pages() during
>    swap-over-NFS by ensuring we do not call put_page() on unpinned memory.
>  - Rebased on fs-next
> 
> [v4]
>  - https://lore.kernel.org/all/20260720150601.2702700-1-praan@google.com/
>  - Dropped superfluous externs in include/linux/nfs_page.h
>  - Scoped `req` locally inside the loop in nfs_release_request_list()
>  - Wrapped >80 character lines in Patch 1 to adhere to coding style.
>  - Fixed typos and capitalization convention in the commit msgs
>  - Collected Reviewed-by tags from Christoph and Shivaji
>  - Rebased on fs-next
> 
> [v3]
>  - https://lore.kernel.org/all/20260715143540.3597616-1-praan@google.com/
>  - Dropped patches that added folio support for NFS Direct I/O
>  - Folded requested_bytes accounting in patch 5 due to dropped folio support
>  - Rebased on fs-next
> 
> [v2] 
>  - https://lore.kernel.org/all/20260616134000.2733403-1-praan@google.com/
>  - Fix data corruption in nfs_direct_extract_pages() by correctly
>    calculating intra-page offsets using offset_in_page().
>  - Fix requested_bytes accounting in direct read/write paths to only
>    increment after successful RPC scheduling.
>  - Add missing kernel-doc descriptions for the @pinned parameter in
>    nfs_page_create_from_page() and nfs_page_create_from_folio().
>  - Rebase on fs-next/
> 
> [v1] https://lore.kernel.org/all/20260603053033.3300318-1-praan@google.com/
> 
> Pranjal Shrivastava (5):
>   nfs: make nfs_page pin-aware
>   nfs: track number of pinned pages in nfs_page
>   nfs: introduce nfs_release_request_list helper
>   nfs: migrate direct I/O to iov_iter_extract_pages
>   nfs: introduce nfs_direct_extract_pages helper
> 
>  fs/nfs/direct.c          | 139 ++++++++++++++++++++-------------------
>  fs/nfs/pagelist.c        |  62 ++++++++++++++---
>  fs/nfs/read.c            |   2 +-
>  fs/nfs/write.c           |   2 +-
>  include/linux/nfs_page.h |   8 ++-
>  5 files changed, 130 insertions(+), 83 deletions(-)
> 
> 
> base-commit: 5b57716ed7ad2f4b1724461c8777015c4e4befb1
> -- 
> 2.55.0.679.g6767b8d81c-goog
> 

Thanks,
Praan

[1] https://lore.kernel.org/all/20260720150601.2702700-1-praan@google.com/

