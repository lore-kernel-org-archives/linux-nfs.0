Received: from mail-qk1-f173.google.com (mail-qk1-f173.google.com [209.85.222.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6624839C013
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 17:30:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785432635; cv=none; b=Y6FsnfGae+431cOPlAP3THHcDDb+eMLDqcAtNJThloLnAMRAO38qEYZSHv5QGDkcGEe//HgxyPXWUZLfI3xwN+SAD+0pVy1AYakoM8PyDq61rCvmAsmKrqWXP2mT+fihbEL3/7HNNzpA0Nppg6mbeN1gjXC2LwnqY67+UMHk1kI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785432635; c=relaxed/simple;
	bh=ZarrVrdKj2n3aaebkA5FovkqHBfFNmuG5d9kWTyUTbc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=dGG5Mp7PERdIqbLcrjdb/KutHTESxMiT1WJnbi9Qwwtezrl9S9+MbLzhLdN+aIbrhr6yfsiDpMvlnbUvLXcJe33BOoi7CMl/Qvm5caBqaROvc6wiCQxzW60Vs8JaXn4OGTP/rISldI25lxJ0LskldaSIoluLZLIq7yBQV0yWvCU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net; spf=pass smtp.mailfrom=gourry.net; dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b=du4CQIwW; arc=none smtp.client-ip=209.85.222.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gourry.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b="du4CQIwW"
Received: by mail-qk1-f173.google.com with SMTP id af79cd13be357-92e5cb052edso7927685a.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 10:30:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gourry.net; s=google; t=1785432632; x=1786037432; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=O1gNcDYuy2kFPtuMWDBBdwYzU3pwqwyp43h1K8eiHJI=;
        b=du4CQIwWEG7O6ckuHbU2xpM5rHc3KCc9Y6gGN06uDGZBul7DsSItwEtQUpmGwTL0uw
         MPdSC3xxvcne7biwuRXC6W0+0Q6dOL3s2t7LkHrTW2WqOcZp5zkxwZ4rKw0OjQ/P4lv8
         OiRNtl7pf/xdZvUUav5gmKC3O4Kfuy5FG7ce7DijnCp8/EY8VjnfaVmaMu1OfNctBAAr
         XWAdQTyQAgTcRPEWL0jBj/08dGNup1ctehZpCjS/655Po/ZtyZYM77TGBLAPJUL14pLB
         0d/6Ukpm1n8il1xPY3GJIkPZaTXYkNUkhIRM4pgsbu7e9Pq5Aq3VjsJCkkIXdh03UwMc
         lHaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785432632; x=1786037432;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=O1gNcDYuy2kFPtuMWDBBdwYzU3pwqwyp43h1K8eiHJI=;
        b=LaWEEOMuLF846EvHKK+vY0k0l7oxTGTsT9/w+1N1ByrHglYZ+85rZhJFd43S0Vm2Ng
         puVOsOJuBVcsT76EJH5ce81e+j1OCIv9VhGP2OJv7m397zzgGW6x6kO2nF0O3fYwcrlZ
         IKXR0eqOJEMKMEUSw5xkP1oILxgDJam/6cxd8DdnIsJfU1RWR0StkUEPu/VUS1NtaFpI
         43GG5Xzyfa6B+ak2nu8TZyyyn02cAzkEMuE0AqM2/NpAX22A99i05w6x/F7T7q+rx/AQ
         zyj5bd3wlpZ2OODDPR6wikvbgib0LbrqtWJVPPE1Na8C3X72FGGOU95ny6zDhpjNLaUK
         bBNw==
X-Forwarded-Encrypted: i=1; AHgh+RoKJcbUB+1k7bnd+cXhEGC+EqNca47TvGoouUtBzltFue5mEsU+7h3+BkXaQkGrN33JxSoH4RwjrDE=@vger.kernel.org
X-Gm-Message-State: AOJu0YyWJRQsqEGfkKscLA8ex+j+nc2Sy4B2CIQ/4aOx1RQS8wd7PUau
	uLRuNC7eaWNeVKePqM+vZawoH1P3ud79W0Ou43M4y53XIjgptUAJbfhs2elJQMfIuus=
X-Gm-Gg: AR+sD122QplJPJp9UgU9hZNQ/dOD0Y6uXK471SwbLJIPgiP3K0Q8pukbmsfRxOh3qTQ
	/GsCCnQG0XbbUee2axjB11jRO7t0274ziTPoebbsfIdPyNt17EqtWd+G30/8i9Yc2P2AcPkiD4j
	QNKGdKTLpfMWH3uqjYL2P3BykvBRRjVWxWXhpkc5DKEDHQSegGkuWJRN5erUvL6FeAwLyW2HgzQ
	3rFTk5Wp2o4Pr4bHDmxfAXeF8bdlhImG+zhZLSbsGtz9IWwnvB1ePwYG3EXqZL4HxOGA5XEXwBM
	CHuRdBWsoyBYMbl7aPNvlq/GlcgYoKYm/kPVUO6oEmgHCFjnnZuGRraxighJWIaDFavkw+whofz
	s662cFvuknQ2XPJaBdWKsgVdgQTvvVXi7ZA1tS5CWx73vTLkudSGzi7SlCfTafZJ9ESO7WZNBPy
	7msCmXO/zeK86U0YxLeW9+jCn5I75M99uq0V+LYQ3361YnFMSlHIIcOBJmlhm15Lwpz75ni0WNq
	4VpEAiJHQVZexBbPQIFaA6ZQ9/BKhuhypdR3hHOV+iX
X-Received: by 2002:a05:620a:27c5:b0:92e:56f7:c5fb with SMTP id af79cd13be357-93485f9c0a0mr372532985a.12.1785432632074;
        Thu, 30 Jul 2026 10:30:32 -0700 (PDT)
Received: from gourry-fedora-PF4VCD3F (pool-173-79-60-52.washdc.fios.verizon.net. [173.79.60.52])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-933d325a17fsm457745885a.13.2026.07.30.10.30.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 30 Jul 2026 10:30:31 -0700 (PDT)
Date: Thu, 30 Jul 2026 13:30:29 -0400
From: Gregory Price <gourry@gourry.net>
To: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Cc: Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <lorenzo.stoakes@oracle.com>, 
	"Liam R. Howlett" <Liam.Howlett@oracle.com>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Zi Yan <ziy@nvidia.com>, Matthew Brost <matthew.brost@intel.com>, 
	Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, Byungchul Park <byungchul@sk.com>, 
	Ying Huang <ying.huang@linux.alibaba.com>, Alistair Popple <apopple@nvidia.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <mhiramat@kernel.org>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Brendan Jackman <jackmanb@google.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Davidlohr Bueso <dave@stgolabs.net>, Fan Ni <nifan.cxl@gmail.com>, 
	Frank van der Linden <fvdl@google.com>, Jonathan Cameron <jic23@kernel.org>, 
	Raghavendra K T <rkodsara@amd.com>, "Rao, Bharata Bhasker" <bharata@amd.com>, 
	SeongJae Park <sj@kernel.org>, Wei Xu <weixugc@google.com>, 
	Xuezheng Chu <xuezhengchu@huawei.com>, Yiannis Nikolakopoulos <yiannis@zptcorp.com>, 
	dimitrios@palyvos.net, Ryan Roberts <ryan.roberts@arm.com>, 
	Huan Nguyen <nhuhuan@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
	Alirad Malek <alirad.malek@zptcorp.com>
Subject: Re: [PATCH RFC v2 0/3] Demote to lower tier using non-temporal stores
Message-ID: <amuJbBrTW9W6_sx8@gourry-fedora-PF4VCD3F>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>

On Thu, Jul 30, 2026 at 05:02:56PM +0200, Yiannis Nikolakopoulos wrote:
> In most memory tiering scenarios, the memory to be demoted is expected
> to be cold and most likely out of the node's last-level cache (as well
> as target pages in the target node). Using non-temporal stores instead
> of a standard memcpy path can reduce the cache pollution in the local
> node and the bandwidth overhead to the target node. Furthermore, for
> certain types of CXL devices that support in-line memory compression,
> the last-level cache eviction patterns can negatively affect the
> bandwidth of the device. Non-temporal stores can mitigate this.
> 
> This patch-set introduces a new migrate_mode flag for using non-temporal
> stores that is used only in the demotion path. Patch 1 adds some helpers in
> x86 and mm to bring non-temporal stores support to a respective folio_copy
> function. Patch 2 adds the new flag and necessary changes for compatibility
> with the existing behavior. Patch 3 uses the new flag for demotions.
> 
> Experimental data: in a CXL system with 1 memory expander, a microbenchmark
> that allocates N=64 GB memory in the local node and then triggers demotion
> using memory.reclaim, shows a practically complete elimination of read
> traffic on the device, i.e. write traffic is N GB with and without the
> patch, while read traffic drops from N to almost 0 with the patch.
> 
> Opens:
> 1. There is some "duplication" in the x86 tree and a bit in mm. Can we do
>    something better there? As it is now in copy_mc_to_kernel_nt we
> duplicate the machine check functionality, which if available will override
> the non-temporal. We were not sure how to prioritize these two and what's
> the best approach here. Can we completely skip the machine checked for this
> path? Huan Nguyen has some ideas here that we will align for the next
> version.
> 2. I am not sure how this should be structured so that it is easily
> adopted in other architecture trees (e.g. aarch64). We rely on
> memcpy_flushcache for x86_64 but this does not use non temporal stores
> in ARM. ARM support is currently out of our scope but any input is
> appreciated.
> 

I'm still a bit confused why using NT Stores needs to be an explicit
option - rather than the default behavior if NT Store is available.

Lets assume we did this for all ASYNC requests, is there a negative
effect? A positive effect? Why the new ASYNC type? Is there a
correctness issue?

~Gregory
