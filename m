Received: from mail-qk1-f176.google.com (mail-qk1-f176.google.com [209.85.222.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 402303B3BE9
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 18:09:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785434945; cv=none; b=k4r9P6GkDhYc/4r92I3J4wt/TK3KiNzjefjSDAadFDTCJNjUmH/AB8NQEjP+P9GqDj8pir5Jyw4AgdcuofafymsRZjKrw7QweOK1ozCR1ZJ3Udwq2FO46Es5hPkioVUXw4NALmael1gkxHk4MYDcuCGEFsqp3+h756UDIzGhJlE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785434945; c=relaxed/simple;
	bh=e5djwQ5M46poH9vcs1lwIEd6WdMkFZI64agxZMyi4TU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rG8R+i+h0MEOgr6c2wv7TEQDvegb0gp/cr5av0a8stzKLSyebKUsHvIa7uxOSJImDCRgi+x1Dq+4rLwK/iLXElq1ssvG+HM4d5f4HW2QnO+euNjrvAI6NJqYCtsa7oQ2SxZmRQPWzVRLtXg/PCyI1WfEumdwTZ8kbwEDZTZjJFU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cmpxchg.org; spf=pass smtp.mailfrom=cmpxchg.org; dkim=pass (2048-bit key) header.d=cmpxchg.org header.i=@cmpxchg.org header.b=NF2Miw8j; arc=none smtp.client-ip=209.85.222.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cmpxchg.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg.org header.i=@cmpxchg.org header.b="NF2Miw8j"
Received: by mail-qk1-f176.google.com with SMTP id af79cd13be357-92edb12cdf2so10584885a.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 11:09:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg.org; s=google; t=1785434941; x=1786039741; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=0g23j5vj8+Bp2V9fp4RzYHbi9Ap6ZcD0KhlvvGNkHEE=;
        b=NF2Miw8jFt+c5I3urIG/d54i9D3WBotb1TscEJGz5Nwfs7f2vQ/ehi1oFaus+ra+DD
         rFLPYNTeig3R+E9cnCa9qtQlVgyCxhAYiNRcxV0u+PJ/OaVfHFo6OD3RbeeJ1sNuXqFT
         iIZI+2jOjl5Jd+kDpN5K59pKM2XOl3B7d83v5Rx0LvELad1K/PtUfmhO4JvcEV2DTMIv
         gZmEAr9KALOU7A8aneqgASjgFCeQmQf2b7Jgw2X5ak33btSNdDbUyglwtzkDKKHlXU9c
         yIuRwVcb8gLqN8Ce3XFrBMXBMhcmQ19xlKyuB50V1I01Y3aaoQRNkuNVz0ZimHFZ35BU
         itBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785434941; x=1786039741;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=0g23j5vj8+Bp2V9fp4RzYHbi9Ap6ZcD0KhlvvGNkHEE=;
        b=dBwVesnnoPTJUm3F99aDMissQThHS1Vn1JBk0XFoCq9Gj2aupcUahs6qeqd3twLvA/
         6FeXSA82m8lUCOhYcNL4ZzyAbsSgXtUj12P+qoCaYwkUKlrw1Qlw23agp3nnEBWhrZZd
         9MFyeE1oU39PP/CRNj5AkMYw8qYFVzQ2+CTlJ7ubKmx9fvTVzhYk71siEhWZgHPStxwD
         HWQ186DzAsQGjJAm89TLXVESJwSvCmIbKFCNKgxdES/CpN9KYGxoy50487cgZvQleEYv
         PuzXnFQQOhIi8PRBkgjJnOmointv0AZbBMZb0CKfcEdn7dG0xEGTnRiAPR02Q0yPf5k9
         nfHg==
X-Forwarded-Encrypted: i=1; AHgh+Rpp8kIOmDv0NcjbrvfpS8XXAiDK7amApbUEIMRmbuwSo1xlqIfHGDjsGz7rpoCgStBLRBNJarK81dU=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy+UiEoiDVimWkKW8c9KAgUB2R6wS4r3+mcqmD3EcAsjwUvfQHL
	eia12xWKweW2Hz3z9D/p5OmcjLW/duUTDg/GP/CJ3BoNHDhSQ2d+sefICx4mXf0y078=
X-Gm-Gg: AR+sD11ypfJLeYvsDRiOvIAfVV8g3yV1eNIWM/6x2CstaBh9PvzLAtURDVYeLzSrWUU
	Gem5kZH8Ln/C/ZAZtM7N6ynJctiGu6l9Uq9VkCHOCl9K4yN5BLadlJUIFdoAjfDFuqwwPWfX8CQ
	/9NCKEEnDXEKVO4iWSghBTUl1T2o4O4meJzx8rdN2ypmiWcrsbTzy8AGwD3k71IJgQUrXsxQPR3
	YRNZSail+VWtaEJj5s8FvgPR2AmhLF8VRJ1/0Kt76P3/+xVScfdlPJ6E4AcdG58kuWwpDROQp6L
	qfdxUSF4ZVfXih7X3hjeq+254kniFHjqKCEOxF+6+naS/w1uI+Nhvy6VxtY4Qwd+PBlRIQAYub/
	hteWtvYIhyHt6dHZmdMTBafE1oIymgoUoc9MPZkbpaNeAm5iNyrdz6TfTHCCrA5tkAXJXzlBhmq
	bP2DVgImUyV+mE2CQH1wR7OPYWTleFqMCa+PLk+3SWX1qj/4JEzB7Jko/6Egk=
X-Received: by 2002:a05:620a:260f:b0:92a:1b20:fe0c with SMTP id af79cd13be357-93485fa518dmr413028985a.17.1785434940796;
        Thu, 30 Jul 2026 11:09:00 -0700 (PDT)
Received: from localhost ([2603:7001:f100:500:365a:60ff:fe62:ff29])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-933d3264577sm464848585a.17.2026.07.30.11.08.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 30 Jul 2026 11:09:00 -0700 (PDT)
Date: Thu, 30 Jul 2026 14:08:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Frank van der Linden <fvdl@google.com>
Cc: Gregory Price <gourry@gourry.net>,
	Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>,
	Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@kernel.org>,
	Lorenzo Stoakes <lorenzo.stoakes@oracle.com>,
	"Liam R. Howlett" <Liam.Howlett@oracle.com>,
	Vlastimil Babka <vbabka@kernel.org>,
	Mike Rapoport <rppt@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Zi Yan <ziy@nvidia.com>,
	Matthew Brost <matthew.brost@intel.com>,
	Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>,
	Byungchul Park <byungchul@sk.com>,
	Ying Huang <ying.huang@linux.alibaba.com>,
	Alistair Popple <apopple@nvidia.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Brendan Jackman <jackmanb@google.com>,
	David Rientjes <rientjes@google.com>,
	Davidlohr Bueso <dave@stgolabs.net>, Fan Ni <nifan.cxl@gmail.com>,
	Jonathan Cameron <jic23@kernel.org>,
	Raghavendra K T <rkodsara@amd.com>,
	"Rao, Bharata Bhasker" <bharata@amd.com>,
	SeongJae Park <sj@kernel.org>, Wei Xu <weixugc@google.com>,
	Xuezheng Chu <xuezhengchu@huawei.com>,
	Yiannis Nikolakopoulos <yiannis@zptcorp.com>, dimitrios@palyvos.net,
	Ryan Roberts <ryan.roberts@arm.com>,
	Huan Nguyen <nhuhuan@google.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-trace-kernel@vger.kernel.org,
	Alirad Malek <alirad.malek@zptcorp.com>
Subject: Re: [PATCH RFC v2 0/3] Demote to lower tier using non-temporal stores
Message-ID: <amuTOC7qxWHVyZcO@cmpxchg.org>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
 <amuJbBrTW9W6_sx8@gourry-fedora-PF4VCD3F>
 <CAPTztWatWbsF4KQwD-_nib-vrZ6uvrhMYcOc1mkWu-7DzN95AQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPTztWatWbsF4KQwD-_nib-vrZ6uvrhMYcOc1mkWu-7DzN95AQ@mail.gmail.com>

On Thu, Jul 30, 2026 at 10:40:32AM -0700, Frank van der Linden wrote:
> On Thu, Jul 30, 2026 at 10:30 AM Gregory Price <gourry@gourry.net> wrote:
> >
> > On Thu, Jul 30, 2026 at 05:02:56PM +0200, Yiannis Nikolakopoulos wrote:
> > > In most memory tiering scenarios, the memory to be demoted is expected
> > > to be cold and most likely out of the node's last-level cache (as well
> > > as target pages in the target node). Using non-temporal stores instead
> > > of a standard memcpy path can reduce the cache pollution in the local
> > > node and the bandwidth overhead to the target node. Furthermore, for
> > > certain types of CXL devices that support in-line memory compression,
> > > the last-level cache eviction patterns can negatively affect the
> > > bandwidth of the device. Non-temporal stores can mitigate this.
> > >
> > > This patch-set introduces a new migrate_mode flag for using non-temporal
> > > stores that is used only in the demotion path. Patch 1 adds some helpers in
> > > x86 and mm to bring non-temporal stores support to a respective folio_copy
> > > function. Patch 2 adds the new flag and necessary changes for compatibility
> > > with the existing behavior. Patch 3 uses the new flag for demotions.
> > >
> > > Experimental data: in a CXL system with 1 memory expander, a microbenchmark
> > > that allocates N=64 GB memory in the local node and then triggers demotion
> > > using memory.reclaim, shows a practically complete elimination of read
> > > traffic on the device, i.e. write traffic is N GB with and without the
> > > patch, while read traffic drops from N to almost 0 with the patch.
> > >
> > > Opens:
> > > 1. There is some "duplication" in the x86 tree and a bit in mm. Can we do
> > >    something better there? As it is now in copy_mc_to_kernel_nt we
> > > duplicate the machine check functionality, which if available will override
> > > the non-temporal. We were not sure how to prioritize these two and what's
> > > the best approach here. Can we completely skip the machine checked for this
> > > path? Huan Nguyen has some ideas here that we will align for the next
> > > version.
> > > 2. I am not sure how this should be structured so that it is easily
> > > adopted in other architecture trees (e.g. aarch64). We rely on
> > > memcpy_flushcache for x86_64 but this does not use non temporal stores
> > > in ARM. ARM support is currently out of our scope but any input is
> > > appreciated.
> > >
> >
> > I'm still a bit confused why using NT Stores needs to be an explicit
> > option - rather than the default behavior if NT Store is available.
> >
> > Lets assume we did this for all ASYNC requests, is there a negative
> > effect? A positive effect? Why the new ASYNC type? Is there a
> > correctness issue?
> >
> > ~Gregory
> 
> Yes, this is a good discussion to have. I believe that the initial
> reason for using a separate mode here was to be non-invasive, e.g.
> "don't break anything else".
> 
> But why not use non-temporal stores for everything? I don't know. I
> suppose one argument might be that if you know that the destination
> will be used immediately, NT stores might be a slight performance hit.

do_numa_page() -> migrate_misplaced_folio() is such a case. It happens
literally in the access path to that data. MIGRATE_ASYNC just means
don't block, fail fast, because waiting for an IO-bound lock to avoid
a remote NUMA access would be a bad idea.

Compaction on the other hand does use MIGRATE_SYNC* and it's touching
data in PFN order, completely out of execution sequence. That could be
a good candidate for NT stores.

> arm64 already seems to use stores with NT hints by default.
> 
> In general, though, I agree that for ASYNC requests, just always using
> NT seems fine.
> 
> Maybe the mode and reason should be folded in to one variable, so
> that, further down the stack, a decision can be made as to what type
> of copy to use? E.g. if the mode is !MIGRATE_ASYNC and the reason is
> MR_DEMOTION, then non-temporal is still a good choice. If the mode is
> MIGRATE_ASYNC, NT is still a good idea. If you wanted to get fancy,
> any mode with folio_test_waiters(folio) == true should not use NT,
> since a task is waiting to use the data, so caching it is better.
> Maybe that's overthinking it.

Agree. `reason' seems like a much stronger signal.
