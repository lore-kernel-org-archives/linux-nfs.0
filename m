Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF513C433E6
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Mar 2021 18:11:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5FC126523A
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Mar 2021 18:11:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229904AbhCISKe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Mar 2021 13:10:34 -0500
Received: from outbound-smtp44.blacknight.com ([46.22.136.52]:36041 "EHLO
        outbound-smtp44.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S231904AbhCISKJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2021 13:10:09 -0500
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
        by outbound-smtp44.blacknight.com (Postfix) with ESMTPS id 1BF02F8824
        for <linux-nfs@vger.kernel.org>; Tue,  9 Mar 2021 18:10:08 +0000 (GMT)
Received: (qmail 21638 invoked from network); 9 Mar 2021 18:10:07 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.22.4])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 Mar 2021 18:10:07 -0000
Date:   Tue, 9 Mar 2021 18:10:06 +0000
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Christoph Hellwig <hch@infradead.org>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] mm/page_alloc: Add a bulk page allocator
Message-ID: <20210309181006.GP3697@techsingularity.net>
References: <20210301161200.18852-1-mgorman@techsingularity.net>
 <20210301161200.18852-3-mgorman@techsingularity.net>
 <20210309171230.GA198878@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20210309171230.GA198878@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 09, 2021 at 05:12:30PM +0000, Christoph Hellwig wrote:
> Would vmalloc be another good user of this API? 
> 
> > +	/* May set ALLOC_NOFRAGMENT, fragmentation will return 1 page. */
> > +	if (!prepare_alloc_pages(gfp_mask, 0, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
> 
> This crazy long line is really hard to follow.
> 

It's not crazier than what is already in alloc_pages_nodemask to share
code.

> > +		return 0;
> > +	gfp_mask = alloc_mask;
> > +
> > +	/* Find an allowed local zone that meets the high watermark. */
> > +	for_each_zone_zonelist_nodemask(zone, z, ac.zonelist, ac.highest_zoneidx, ac.nodemask) {
> 
> Same here.
> 

Similar to what happens in get_page_from_freelist with the
for_next_zone_zonelist_nodemask iterator.

> > +		unsigned long mark;
> > +
> > +		if (cpusets_enabled() && (alloc_flags & ALLOC_CPUSET) &&
> > +		    !__cpuset_zone_allowed(zone, gfp_mask)) {
> > +			continue;
> > +		}
> 
> No need for the curly braces.
> 

Yes, but it's for coding style. MM has no hard coding style guidelines
around this but for sched, it's generally preferred that if the "if"
statement spans multiple lines then it should use {} even if the block
is one line long for clarity.

> >  	}
> >  
> > -	gfp_mask &= gfp_allowed_mask;
> > -	alloc_mask = gfp_mask;
> 
> Is this change intentional?

Yes so that prepare_alloc_pages works for both the single page and bulk
allocator. Slightly less code duplication.

-- 
Mel Gorman
SUSE Labs
