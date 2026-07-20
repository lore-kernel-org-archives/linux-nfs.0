Received: from mail-qt1-f173.google.com (mail-qt1-f173.google.com [209.85.160.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93ED944CADF
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 17:44:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569493; cv=none; b=JTr80IFVMbxhx6E5xyekBQFCasVGKGj/Q74YAGdy2p26tcItJu1anMJPzzfsk9QpbLciJb5VA8VZmMwJpKwE71i/eHo6FV6UBDgCZkNHBp7TMVC3xQqOVVc/h270jENOpsyUvlA5X/NdqRkovR0MqNl9vMsQLD1Zl9oJUyAUgws=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569493; c=relaxed/simple;
	bh=eQwLG50FQTlGIaxFUWOZqCCOrmund6wJNcAiP3xOaXA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tUexSrQnhNlFYN6Oius6qR3gZj3F2C6xSsjIJOL8bilvkMKm1FuJs2FsDAv2g7fFSGCNIFiz3hxw0wYSQG/iA2YRRhCNtq54FGgfMLejVQ+IPEzUIHk44MMYQPCC9kuS9Fk4IfmEDqRzUyi8Zp2Wqv5aFVtW/NmA9921X5UKZDM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net; spf=pass smtp.mailfrom=gourry.net; dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b=X8U6zM0w; arc=none smtp.client-ip=209.85.160.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gourry.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b="X8U6zM0w"
Received: by mail-qt1-f173.google.com with SMTP id d75a77b69052e-51bfbe05683so94789031cf.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 10:44:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gourry.net; s=google; t=1784569485; x=1785174285; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Fh0Ky+WC8JAb92VghcxhTRFBn6Go7CAcxa18f3039ho=;
        b=X8U6zM0wVzqBdPhme0rKH4934jbpYW7yQmUifhqTtQKugUMzjxrbWR2V0nbPkyGBQh
         9oEanJic11w4rFy7w4bJsWVLEdr5NvOH86f28My6ZAYChA3qDKSCIEKL9wDJXpQdy6MA
         H70tVAM4f0rgUzOwqE/Go3xFdHmvfIoFSdCaNE9AkeSJmHlr/FzvKsEoOo/ZSMe3xXi9
         A87GeIdVUoGCBJOZzbmTRjuSVMq8uoC9GucP2CSIV8hxiP9i0t4b3LQ0tUi9aik56pEM
         TPyyrvqsTIyBTT46XV/wt8ZLbanNjaaKY0I4Y79+bo8Uwas/HcYEKSSZM3SWmQXQgoIx
         R51A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784569485; x=1785174285;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Fh0Ky+WC8JAb92VghcxhTRFBn6Go7CAcxa18f3039ho=;
        b=U1IJSQPuPD0Fysmn32CRd+8lpyIQBNLR7JJkWWQq5uIMNo7NS47LPq3MIO2rYL2TVC
         D/nSOuzKQodUvu7nIMoyYzfY7sanB4qrQL+Ju2hvS560+IUF/jiyS4TJ7SoOPeM4UZ0q
         /OZUlB0gtYFsK+gNNYn8KZityx9z5Qr3TPuVpxPQeb/d5E4lSih4CS+5AZMNRneyRJ+d
         SkAnkNmlW66v1ELpRYKdHw5g41iztcfE7x107zhAO5XoxSY+n0NoN+dMEMpGlAGahVk0
         BAmfs2io9Ni9Ho/RQ60QSeqroW4EC3ujg25TxWJ1MButWwM+EQwnPnZJ4yZZmPAgM8Rz
         oC4w==
X-Forwarded-Encrypted: i=1; AHgh+RpzlHPLHVIr+YKWCYPAFgaLKO1biFsrLPdLyxnP4HAgg0suyugYpgdI/Ilp3speYIroG73kSvzGlIk=@vger.kernel.org
X-Gm-Message-State: AOJu0YyHvExKOSEffxSZ0ZYuemFpvyrRGU1K/pkRcLYX6UHIrX/TtZA9
	a+akP1nHBc1sXik3FF/VlSqYtPX9GASuKn7wcchqjoZoQvzhTnRQ/NnZPZaGaRGuySI=
X-Gm-Gg: AfdE7cmskWVIs1Ea+ofrIbXkYMMwGSjg/xPKOc1mq/YVOWlOFEnO3AZ8LkPbGSwyQZl
	NJOzCrnBVB808tCDzfcdrFCy/X3AG0+TS5mWsVkUBpdm4R3Lkb0FCLf/Yj573mLbsLNoyHVxDma
	42vJZA9p8bHhcdneqjT0n01HYcGaugdI+SUqegmokL/Uf6Nz1Xs/mDb1qXHoTcwWRsvagnqHkKa
	Fy15zBF5Bq/q/cS56xSjJ1onrbc03ZLjQAWkvqpIIH4ObZGwkdO2MRI0jEoMv4yu9go0vdO2hes
	Gygg4n0kJsgF5hgcRT5Q2D47mfCAW7pNvx3bgNQipZw7w0ir6ZAumjADBVUM67Rz6e4cw1nNm3m
	J8g3Stl9u4USv1YhkApWbLDs/k4ZZJ7HYNO764Gh0ZbWrNpBUefao03dazkxLRSbrmSb/2so8m6
	2otSXQt5PT/JTKn4LWYTyyrLcGj+/54yvWQpthLuqjTqZ0aQtdiZCYp3DgNw==
X-Received: by 2002:a05:622a:1107:b0:51b:fddc:1de8 with SMTP id d75a77b69052e-5213e67e2c1mr141645811cf.65.1784569485065;
        Mon, 20 Jul 2026 10:44:45 -0700 (PDT)
Received: from gourry-fedora-PF4VCD3F (pool-173-79-60-52.washdc.fios.verizon.net. [173.79.60.52])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-5214cda7dbfsm77462971cf.9.2026.07.20.10.44.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 10:44:44 -0700 (PDT)
Date: Mon, 20 Jul 2026 13:44:39 -0400
From: Gregory Price <gourry@gourry.net>
To: Brendan Jackman <jackmanb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <ljs@kernel.org>, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, Joshua Hahn <joshua.hahnjy@gmail.com>, 
	Byungchul Park <byungchul@sk.com>, Ying Huang <ying.huang@linux.alibaba.com>, 
	Alistair Popple <apopple@nvidia.com>, Hugh Dickins <hughd@google.com>, 
	Baolin Wang <baolin.wang@linux.alibaba.com>, Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>, 
	Kemeng Shi <shikemeng@huaweicloud.com>, Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>, 
	Barry Song <baohua@kernel.org>, Youngjun Park <youngjun.park@lge.com>, 
	"Joerg Roedel (AMD)" <joro@8bytes.org>, Will Deacon <will@kernel.org>, 
	Robin Murphy <robin.murphy@arm.com>, Huacai Chen <chenhuacai@kernel.org>, 
	WANG Xuerui <kernel@xen0n.name>, Thomas Gleixner <tglx@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
	iommu@lists.linux.dev, loongarch@lists.linux.dev, linux-nfs@vger.kernel.org, 
	netdev@vger.kernel.org
Subject: Re: [PATCH 3/3] mm: move __folio_alloc() to page_alloc.h
Message-ID: <al5eCOfvXR3OZjVi@gourry-fedora-PF4VCD3F>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-3-5363b8e92d33@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260716-folio-alloc-cleanups-v1-3-5363b8e92d33@google.com>

On Thu, Jul 16, 2026 at 02:30:12PM +0000, Brendan Jackman wrote:
> This is no longer used outside of mm so reduce the scope.
> 
> Ulterior motive for the move to mm/: A later patch will add an
> alloc_flags arg here.
> 

I have a similar commit that is coming in on my next private node rfc,
i'll reference this, but i wanted to make sure i hit a solid mm-new base
so sashiko picks it up and people can actually apply it.

> Signed-off-by: Brendan Jackman <jackmanb@google.com>

Reviewed-by:Gregory Price <gourry@gourry.net>

