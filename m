Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7736CC433E6
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Feb 2021 12:02:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5158964E26
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Feb 2021 12:02:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229968AbhBOMB5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Feb 2021 07:01:57 -0500
Received: from outbound-smtp24.blacknight.com ([81.17.249.192]:60140 "EHLO
        outbound-smtp24.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S230190AbhBOMBw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2021 07:01:52 -0500
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
        by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id CAFAFC0B2A
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2021 12:00:57 +0000 (GMT)
Received: (qmail 27872 invoked from network); 15 Feb 2021 12:00:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.22.4])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 15 Feb 2021 12:00:57 -0000
Date:   Mon, 15 Feb 2021 12:00:56 +0000
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Jesper Dangaard Brouer <brouer@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, Mel Gorman <mgorman@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Jakub Kicinski <kuba@kernel.org>
Subject: Re: alloc_pages_bulk()
Message-ID: <20210215120056.GD3697@techsingularity.net>
References: <2A0C36E7-8CB0-486F-A8DB-463CA28C5C5D@oracle.com>
 <EEB0B974-6E63-41A0-9C01-F0DEA39FC4BF@oracle.com>
 <20210209113108.1ca16cfa@carbon>
 <20210210084155.GA3697@techsingularity.net>
 <20210210124103.56ed1e95@carbon>
 <20210210130705.GC3629@suse.de>
 <B123FB11-661F-45A6-8235-2982BF3C4B83@oracle.com>
 <20210211091235.GC3697@techsingularity.net>
 <20210211132628.1fe4f10b@carbon>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20210211132628.1fe4f10b@carbon>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 11, 2021 at 01:26:28PM +0100, Jesper Dangaard Brouer wrote:
> > Parameters to __rmqueue_pcplist are garbage as the parameter order changed.
> > I'm surprised it didn't blow up in a spectacular fashion. Again, this
> > hasn't been near any testing and passing a list with high orders to
> > free_pages_bulk() will corrupt lists too. Mostly it's a curiousity to see
> > if there is justification for reworking the allocator to fundamentally
> > deal in batches and then feed batches to pcp lists and the bulk allocator
> > while leaving the normal GFP API as single page "batches". While that
> > would be ideal, it's relatively high risk for regressions. There is still
> > some scope for adding a basic bulk allocator before considering a major
> > refactoring effort.
> 
> The alloc_flags reminds me that I have some asks around the semantics
> of the API.  I'm concerned about the latency impact on preemption.  I
> want us to avoid creating something that runs for too long with
> IRQs/preempt disabled.
> 
> (With SLUB kmem_cache_free_bulk() we manage to run most of the time with
> preempt and IRQs enabled.  So, I'm not worried about large slab bulk
> free. For SLUB kmem_cache_alloc_bulk() we run with local_irq_disable(),
> so I always recommend users not to do excessive bulk-alloc.)
> 

The length of time IRQs/preempt disabled are partially related to the
bulk API but the deeper concern is how long the IRQs are disabled within
the page allocator in general. Sometimes they are disabled for list
manipulations but the duration is longer than it has to be for per-cpu
stat updates and that may be unnecessary for all arches and
configurations. Some may need IRQs disabled but others may only need
preempt disabled for the counters. That's a more serious overall than
just the bulk allocator.

> For this page bulk alloc API, I'm fine with limiting it to only support
> order-0 pages. (This will also fit nicely with the PCP system it think).
> 

Ok.

> I also suggest the API can return less pages than requested. Because I
> want to to "exit"/return if it need to go into an expensive code path
> (like buddy allocator or compaction).  I'm assuming we have a flags to
> give us this behavior (via gfp_flags or alloc_flags)?
> 

The API returns the number of pages returned on a list so policies
around how aggressive it should be allocating the requested number of
pages could be adjusted without changing the API. Passing in policy
requests via gfp_flags may be problematic as most (all?) bits are
already used.

-- 
Mel Gorman
SUSE Labs
