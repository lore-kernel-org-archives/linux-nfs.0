Received: from mail-qv1-f48.google.com (mail-qv1-f48.google.com [209.85.219.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CEBB39E185
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 17:40:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569247; cv=none; b=RXI1x5KBy4MHBENFBejaBqbsuUIxhxqBR4UekUrb1nE7rHFRDLIPnqyBTeLEf0bn0nuSuo19dyh3DsXUkQSO23BwXis0ncjJZouT3QXVDlcGbR0LFXlWIuY1VcWeyzWRpy4AN5HEik1VTeu11xFHfzcat9AuosG2o3+JdFlGLTY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569247; c=relaxed/simple;
	bh=VvNwpImo0jiiWGhT5ruq5O3iE3zAj0qXWWnRC1CSvCY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=BsNgpo2DFASoS2AZNatPOYABgdPHddLRcos0hGo56FG4b87tYV7qn15+zDY1WORjhgnboYAtrag3vogNe3fjl361o3w0JIOAX9epVwDwEYpyVOWTTtpW8lrj1GWng8a3twccUTeudpo3vxhA5EapxnEWd8o279X0EMqyHLaCsNM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net; spf=pass smtp.mailfrom=gourry.net; dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b=PM5N7JDh; arc=none smtp.client-ip=209.85.219.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gourry.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b="PM5N7JDh"
Received: by mail-qv1-f48.google.com with SMTP id 6a1803df08f44-8f1e274ccb9so55108376d6.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 10:40:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gourry.net; s=google; t=1784569243; x=1785174043; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=STnxksxeYU5ANSzKJlg5+nS1izTc7aC2ZhhV2DsN+ME=;
        b=PM5N7JDhXqTcR7vcOOmFNkbxdCUainG/WBD2n5EidtR/C5ThrJ5wy4yHys2XMbIF/t
         bTq4Go06sbgDv+XlOodjyZBuQFRpS7TpkijHM76RquteIsVp+Vk+nbdoIoh8eeDKZxwW
         NYD2/7n8GylKKd9Kbh0OEoQcKizTQ8Pg7FNnyV89xDcNfTJ+paEGkJKQ80R1dqjZpLqA
         pl3RYHWyckSTIzKpYFfZmapI1G6FFoye9xcCwPzP4CM5gZ+D+mCONxF/cN/MKOJGfuvv
         jq+gPTQl1vYsj//W1yV6aAOmZYoAwg5gywZ+Z5OkPlOPpuGVtBANPJGAq39r9hsENRI+
         DLwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784569243; x=1785174043;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=STnxksxeYU5ANSzKJlg5+nS1izTc7aC2ZhhV2DsN+ME=;
        b=OL3S6emYlG6RWx52PzXKMpW+WpvHdPCqi38UKi5LQ7be5MYuSn1rd9zH3hbKCbWIex
         m9JT94E2VmKaQfmoA55WEGzZoKDsyjo2IKi3U/fcGI9+RckJWVQIGG+26tL6z0OYX8D+
         W+dxuJASZjHFYBi0y9gflS4c+s0JkMpInhQ9DFgw8J18FjAF6Wtr2NANrgezmscFhtBe
         N4iZdXD9IR8+nTWPYT9B8ikb2JheBDf538jNtTZ+LeMjHMtwGDWWgGGs1699HNApG6GZ
         y6SDE2PmN6tylxMm3enDypqXKf8Ph3EXSftwVQkEccnfatptNgpD2BpgbF8FJIQm2xYE
         gT5g==
X-Forwarded-Encrypted: i=1; AHgh+RpdMATDOtGEtPd6WKHE+y+qqfAKxsTJtFz/FQAOWA6W+kZ1CaSPaat1Wx2SAC0w/kVqoGCsU40/Km0=@vger.kernel.org
X-Gm-Message-State: AOJu0YzoM8zRic6n18zlFty9HMSLav/PjTveCMsbx7JkcO0IO22lAlSE
	msJ25/SioFVmV7856qN8t+7KXV/D3lmSpw/x60WtsxJgAjnbxf9fV+q5djZKyGkfcIg=
X-Gm-Gg: AR+sD13g8IOcwnVb3i1D1glpa6o/yZg8S7hCEVV6Go40/Vb2CdWkp6cE8KWPKhCTlMO
	VtmwSDAjs0525Vq9DxCph8GSpdzq3hUlAs24hEj8skWwYEmLzLSetgXZ7SyWDri4jKuaeUEY3+L
	/Ya1KYB4Gh/7x+UJviJpd/aUshoLc+bLO/Xysf6y5Z0yIOf+taHwbhwNIMOc+zcpbhlol+W/ne5
	b020uRBmJmj308ZxYOfe4JO03cdlrg9PB2k5I63pTSobL7toT2qhXCiygzu/zd2n5bybOVBizuw
	UERkSITi0pnufxAj2a8DOGjM4Ikk3lEoQYNPesk8yZt5lmuK0vzJmnvuF7I6Jz6hSVZ29yqcDpB
	/hkC0Gja+wrDLzUQveF+yrVm9sMlKlIfyjWeQaQlyJbuqlwjiAIsZuyLV1aEzf+Ja5Fsgwms5Q4
	nQnJ9zW3slH8+fm5Be1caAFbrIyax7p3banuhg3e6pJv8cEyui1kUzRI1KfA==
X-Received: by 2002:a05:6214:54c8:b0:8e9:f62b:8f93 with SMTP id 6a1803df08f44-9077853b82amr163551916d6.57.1784569243441;
        Mon, 20 Jul 2026 10:40:43 -0700 (PDT)
Received: from gourry-fedora-PF4VCD3F (pool-173-79-60-52.washdc.fios.verizon.net. [173.79.60.52])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907786ed2e2sm95014956d6.33.2026.07.20.10.40.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 10:40:42 -0700 (PDT)
Date: Mon, 20 Jul 2026 13:40:37 -0400
From: Gregory Price <gourry@gourry.net>
To: Brendan Jackman <brendan.jackman@linux.dev>
Cc: Matthew Wilcox <willy@infradead.org>, 
	Brendan Jackman <jackmanb@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <ljs@kernel.org>, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>, 
	Jan Kara <jack@suse.cz>, Joshua Hahn <joshua.hahnjy@gmail.com>, 
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
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
Message-ID: <al5cqn34Xq19f5HG@gourry-fedora-PF4VCD3F>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <alkLSzQvzT9zJbY1@casper.infradead.org>
 <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>

On Thu, Jul 16, 2026 at 04:57:37PM +0000, Brendan Jackman wrote:
> On Thu Jul 16, 2026 at 4:48 PM UTC, Matthew Wilcox wrote:
> > On Thu, Jul 16, 2026 at 02:30:10PM +0000, Brendan Jackman wrote:
> >> There are no external users for this surface, reduce the scope.
> >> -struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> >> -		struct mempolicy *mpol, pgoff_t ilx, int nid);
> >
> > Hm.  So what we're saying is that allocations which respect mempolicy are
> > only for core mm and not for, eg, device drivers to do.  Is that really
> > what we want to say?  I don't think so, because that's inconsistent
> > with having just widened __filemap_get_folio_mpol to allow guest_memfd
> > to specify a mempolicy.
> 
> Yeah I agree, mempolicy definitely seems like a "public concept".  All
> I'm saying here is this specific function doesn't have any external
> users so it doesn't need to be an external header. 
> 
> ... With the ulterior motive that I want to add a new parameter to it
> that actually _is_ mm-internal. Namely, alloc_flags, so I can add
> ALLOC_UNMAPPED to implement AS_NO_DIRECT_MAP, i.e. the next iteration of
> [0]. So basically this is
> about trying to extend the allocator without creating a GFP flag.
> 
> So I'm envisaging if an external user arises for it later, we'd slap two
> underscores on the beginning of the internal one, (with the alloc_flags
> arg), and then bring back the public one as a wrapper.
> 
> Does that make sense?
> 
> [0]: https://lore.kernel.org/all/20260410151746.61150-1-kalyazin@amazon.com/
> 

fwiw i've been fiddling with a module side mempolicy interface for a bit
to allow a clean guest_memfd() + mempolicy() interaction [0][1].

I saw this and thought "maybe, maybe not entirely".

there is definitely some oddities in the mempolicy uapi (internal-only
flags that are exposed to the uapi is odd) that some of the interface is
worth internalizing.

(fyi i've converted my private node work on top of the alloc_flags
 addition + new zonelists, new rfc is being posted today, your recent
 merges were timely).

~Gregory

[0] https://github.com/gourryinverse/linux/commit/b25bb27602fe512733450a97ac31ef4387b7e727
[1] https://github.com/gourryinverse/linux/commit/670f7dd81ef33a9385985a54b8ad6bc070b2d581
