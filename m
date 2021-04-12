Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 200FEC433ED
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 11:19:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D7DBE60FF1
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 11:19:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240228AbhDLLUM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Apr 2021 07:20:12 -0400
Received: from outbound-smtp18.blacknight.com ([46.22.139.245]:36099 "EHLO
        outbound-smtp18.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S240210AbhDLLUL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2021 07:20:11 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
        by outbound-smtp18.blacknight.com (Postfix) with ESMTPS id 264181C52A4
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2021 12:19:53 +0100 (IST)
Received: (qmail 30339 invoked from network); 12 Apr 2021 11:19:52 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.22.4])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 12 Apr 2021 11:19:52 -0000
Date:   Mon, 12 Apr 2021 12:19:51 +0100
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Vlastimil Babka <vbabka@suse.cz>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Matthew Wilcox <willy@infradead.org>,
        Ilias Apalodimas <ilias.apalodimas@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/9] mm/page_alloc: Add a bulk page allocator
Message-ID: <20210412111951.GW3697@techsingularity.net>
References: <20210325114228.27719-1-mgorman@techsingularity.net>
 <20210325114228.27719-3-mgorman@techsingularity.net>
 <28729c76-4e09-f860-0db1-9c79c8220683@suse.cz>
 <20210412105938.GU3697@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20210412105938.GU3697@techsingularity.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 12, 2021 at 11:59:38AM +0100, Mel Gorman wrote:
> > I don't understand this comment. Only alloc_flags_nofragment() sets this flag
> > and we don't use it here?
> > 
> 
> It's there as a reminder that there are non-obvious consequences
> to ALLOC_NOFRAGMENT that may affect the bulk allocation success
> rate. __rmqueue_fallback will only select pageblock_order pages and if that
> fails, we fall into the slow path that allocates a single page. I didn't
> deal with it because it was not obvious that it's even relevant but I bet
> in 6 months time, I'll forget that ALLOC_NOFRAGMENT may affect success
> rates without the comment. I'm waiting for a bug that can trivially trigger
> a case with a meaningful workload where the success rate is poor enough to
> affect latency before adding complexity. Ideally by then, the allocation
> paths would be unified a bit better.
> 

So this needs better clarification. ALLOC_NOFRAGMENT is not a
problem at the moment but at one point during development, it was a
non-obvious potential problem. If the paths are unified, ALLOC_NOFRAGMENT
*potentially* becomes a problem depending on how it's done and it needs
careful consideration. For example, it could be part unified by moving
the alloc_flags_nofragment() call into prepare_alloc_pages because in
__alloc_pages, it always happens and it looks like an obvious partial
unification. Hence the comment "May set ALLOC_NOFRAGMENT" because I wanted
a reminder in case I "fixed" this in 6 months time and forgot the downside.

-- 
Mel Gorman
SUSE Labs
