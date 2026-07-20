Received: from mail-qt1-f171.google.com (mail-qt1-f171.google.com [209.85.160.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55F5E3AB26B
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 18:29:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784572184; cv=none; b=AJk/4x4vCqR4bpdUXJyqfrQmDZND2X44ndFy7YBEiNpAi1Jkaa6MaxrX2Fp6z8vQ7iQm+Rvb2oA7jwzrqdmAwY/qlxfMaAy57JT2ulzFKDbdHt0SYpKGyO61ArL2HDP2FtTToolwtt6oS40rPz/S3f/D7oY7x/soELpNYVYkqpg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784572184; c=relaxed/simple;
	bh=bZ1i/ob8RAwD2ONrC55boLi9X2aDJHrAWwM59fdDkbs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=UJz4ju/Ur+CTAaL89JSk93YDK6xfnFricsARDfUuXZv5rqYezhHMkD1a1pZo93r2z+GoHyWFuWryPQtjuQdEAp+WLYxmtvfIKIwt8WjfJROVNpQ4e8QQtrdcP9Zigqr01iRsZ8q3KivSMHJ2PuHeGc541eCLy7vRMgRHr79E/WY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net; spf=pass smtp.mailfrom=gourry.net; dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b=dMfLvPZK; arc=none smtp.client-ip=209.85.160.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gourry.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b="dMfLvPZK"
Received: by mail-qt1-f171.google.com with SMTP id d75a77b69052e-51c2a449c57so105430651cf.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 11:29:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gourry.net; s=google; t=1784572182; x=1785176982; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=EvlY+ZnuMunvG4k74l6eGWIXWbaZN9lfqhpu+ESLMPs=;
        b=dMfLvPZKMUsOniq2cwcyq/opEu+HSDAxwBQChpAKcQlUPVw/4NuHbjyh0QgJJd8vjE
         D3ccl07Su2mUn/7MmcTQhb6XJ8IxK1kWJYMjfyJh4INulwhDARvrL7JcMHBWSxnm/aNf
         Wl3H9tmskoohpbm4LWpQz6wf+8ICHhhDn+tyRBMh3CPMIXrTJxK3BPd7B+Kxdpja5vKr
         Wh4HdP88t7lUyXDTCqNThZwan0vxhOGY6wAXGFFDOnp6wiLMxQYG2DW4aovfS0KQQuHh
         uPUm52nItYOey6fMTFl0To2jYmX9QoRjlK5bYUAE2X2iIiHvidWh2faNs62ckHKUTthx
         LofQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784572182; x=1785176982;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EvlY+ZnuMunvG4k74l6eGWIXWbaZN9lfqhpu+ESLMPs=;
        b=BsumxPLDvCkVq2BIj6o/x8sAgY2fk0DpFABgk3Mwp1riWVSEZLOtWtW9rS3aAKrV01
         ZSQIMrKqyEE8dRNV0Q/qcfSbMT7QFyH74fM8t392mh6k+vEb+/IAvvqnU4T/rYybol0M
         RB30TzlDMJtozB/c58sxWP1KYqIBZRvSia3qK4DPftonOtHhZB/92A0znQxWodDPdvUs
         JxKpLfHuJQ1Yj8kaopFHr1v4utE0HsxvPZSEvjZ2dMECLTxJeyl3NnUUioNXsMQI/RPN
         iinTmNTN+k3JCRnf5CndDRE2zARL6zSfrQRpFpBpYRP4tySDwijb3jE5C4WzkwfwkJqt
         72DQ==
X-Forwarded-Encrypted: i=1; AHgh+RoPUJC2oOSCJ/Zyy942TLQ+Q6r6IpgPBDkrTxFhNEVEHSWjQA6eVPDkyevV/UTc3ObAntyhcR0yu40=@vger.kernel.org
X-Gm-Message-State: AOJu0Yyy6WOgM4m8gsEG61ljIHScmp1QjA95mdBcQVA6PHAVQMCaH5lo
	MrUd+4CkPkK7fDdOzVOyU3tjqNZ0FWYjETdpC05DsU6kGDBqF3K8hRvs/khNAzw/gNU=
X-Gm-Gg: AfdE7ckbSjfh18Z1FByDrspkbDt6vTrlcREgU2pr7BD0OZsuB605nNpgsXrC6Wn1o4N
	FZ/DVcGzY57mlA2FjMCAr/Df89IqPoVcG3Fc1yzRBg/6BeWK3N5scn563lmCt6s5rmWdGKDzR2y
	QLDOh4OgWK/OXm8gOSAg92kn1SSASLr3EuZGVzDX3/C753bqIDKxDp3gWPUBcLOIZPcm72PDBgp
	o5oHnaFaGM39vfsurXAEOFE0xhuZoOKm9U04K0MVDw+AErn7meqp5L8iux1VMuCz/neTZF43LIV
	KbZwlScV3MIGuaoeqRcj4Lae+10eZti3LFhvLkyIofonxayJLUWazZJv2P8HcDhEc6mO1IY8NIr
	3HT9hhCIef7TQZn/tv7mBrozZjFZvRsPsxrf8VtyMVe4hYtL3YP9gEGIVaV1cef9+84p/JyPuZ5
	J2xgabYA0TPFSLWzij36+bbqOvqjWechDWfgPUTYoJr5xz/bUWQ57OBv2E7L0f2/Vm5Y5g
X-Received: by 2002:ac8:5714:0:b0:51c:1857:b622 with SMTP id d75a77b69052e-5213e082210mr141591671cf.54.1784572182072;
        Mon, 20 Jul 2026 11:29:42 -0700 (PDT)
Received: from gourry-fedora-PF4VCD3F (pool-173-79-60-52.washdc.fios.verizon.net. [173.79.60.52])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-5214c5cc8d5sm80304611cf.6.2026.07.20.11.29.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 11:29:41 -0700 (PDT)
Date: Mon, 20 Jul 2026 14:29:36 -0400
From: Gregory Price <gourry@gourry.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Brendan Jackman <brendan.jackman@linux.dev>, 
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
Message-ID: <al5ldslYontDDKPJ@gourry-fedora-PF4VCD3F>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <alkLSzQvzT9zJbY1@casper.infradead.org>
 <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>
 <al5gQgnBCjNCSD_4@casper.infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <al5gQgnBCjNCSD_4@casper.infradead.org>

On Mon, Jul 20, 2026 at 06:52:02PM +0100, Matthew Wilcox wrote:
> 
> > ... With the ulterior motive that I want to add a new parameter to it
> > that actually _is_ mm-internal. Namely, alloc_flags, so I can add
> > ALLOC_UNMAPPED to implement AS_NO_DIRECT_MAP, i.e. the next iteration of
> > [0]. So basically this is
> > about trying to extend the allocator without creating a GFP flag.
> 
> Yeah.  I'm not sold on the whole alloc_flags thing, but I'm too busy to
> sit down and think it through properly to get involved in a proper
> argument about how it should work.
> 
> My entirely unresearched and ill-considered opinion is that the __GFP
> flags should _be_ the ALLOC flags.  We shoudn't be translating GFP flags
> into ALLOC flags that are what the allocator actually uses, the
> translation should be done at compile time.  So if GFP_KERNEL and
> GFP_ATOMIC need to be composed of different flags with different
> semantics, then we should do that, not invent a different set of flags
> that special people can use for special purposes.
> 

alloc_flags is putting me between a rock and a hard place.

I figured out a clean isolation mechanism with zonelists (new rfc is
posting today, i'm doing one last proofread), but it required me to
extend some of the mm/ internal interfaces with a zonelist selector.

Since Brendan's base work made it in mm-new, i decided to replace
the zonelist selector with ALLOC_ZONELIST_PRIVATE as the selector
to avoid *yet more* arguments.

I'll be posting with ALLOC_ZONELIST_PRIVATE on top of mm-new, but
the churn is getting painful.

It really seems like we just want an mm/ internal interface that
exposes struct alloc_context for specific *mm/* callers
(see: compaction_context, migration_context, etc), and interfaces
that keep this nonsense transparent for everyone else.

Then if you want access to alloc_context interface, you need to get
export approval for that component (similar to EXPORT_FOR_MODULES).

Just spitballing here, but the churn is killing me.

~Gregory

