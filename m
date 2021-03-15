Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83083C433DB
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Mar 2021 10:42:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 57A6064E12
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Mar 2021 10:42:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229931AbhCOKmS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Mar 2021 06:42:18 -0400
Received: from outbound-smtp09.blacknight.com ([46.22.139.14]:56701 "EHLO
        outbound-smtp09.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S229923AbhCOKmI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2021 06:42:08 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
        by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 7B1341C34BE
        for <linux-nfs@vger.kernel.org>; Mon, 15 Mar 2021 10:42:06 +0000 (GMT)
Received: (qmail 9896 invoked from network); 15 Mar 2021 10:42:06 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.22.4])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 15 Mar 2021 10:42:06 -0000
Date:   Mon, 15 Mar 2021 10:42:05 +0000
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Matthew Wilcox <willy@infradead.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] mm/page_alloc: Add a bulk page allocator
Message-ID: <20210315104204.GB3697@techsingularity.net>
References: <20210312124609.33d4d4ba@carbon>
 <20210312145814.GA2577561@casper.infradead.org>
 <20210312160350.GW3697@techsingularity.net>
 <20210312210823.GE2577561@casper.infradead.org>
 <20210313131648.GY3697@techsingularity.net>
 <20210313163949.GI2577561@casper.infradead.org>
 <7D8C62E1-77FD-4B41-90D7-253D13715A6F@oracle.com>
 <20210313193343.GJ2577561@casper.infradead.org>
 <20210314125231.GA3697@techsingularity.net>
 <325875A2-A98A-4ECF-AFDF-0B70BCCB79AD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <325875A2-A98A-4ECF-AFDF-0B70BCCB79AD@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Mar 14, 2021 at 03:22:02PM +0000, Chuck Lever III wrote:
> >> Anyway, I'm not arguing against a bulk allocator, nor even saying this
> >> is a bad interface.  It just maybe could be better.
> >> 
> > 
> > I think it puts more responsibility on the caller to use the API correctly
> > but I also see no value in arguing about it further because there is no
> > supporting data either way (I don't have routine access to a sufficiently
> > fast network to generate the data). I can add the following patch and let
> > callers figure out which interface is preferred. If one of the interfaces
> > is dead in a year, it can be removed.
> > 
> > As there are a couple of ways the arrays could be used, I'm leaving it
> > up to Jesper and Chuck which interface they want to use. In particular,
> > it would be preferred if the array has no valid struct pages in it but
> > it's up to them to judge how practical that is.
> 
> I'm interested to hear from Jesper.
> 
> My two cents (US):
> 
> If svc_alloc_arg() is the /only/ consumer that wants to fill
> a partially populated array of page pointers, then there's no
> code-duplication benefit to changing the synopsis of
> alloc_pages_bulk() at this point.
> 
> Also, if the consumers still have to pass in the number of
> pages the array needs, rather than having the bulk allocator
> figure it out, then there's not much additional benefit, IMO.
> 
> Ideally (for SUNRPC) alloc_pages_bulk() would take a pointer
> to a sparsely-populated array and the total number of elements
> in that array, and fill in the NULL elements. The return value
> would be "success -- all elements are populated" or "failure --
> some elements remain NULL".
> 

If the array API interface was expected to handle sparse arrays, it would
make sense to define nr_pages are the number of pages that need to be
in the array instead of the number of pages to allocate. The preamble
would skip the first N number of allocated pages and decrement nr_pages
accordingly before the watermark check. The return value would then be the
last populated array element and the caller decides if that is enough to
proceed or if the API needs to be called again. There is a slight risk
that with a spare array that only needed 1 page in reality would fail
the watermark check but on low memory, allocations take more work anyway.
That definition of nr_pages would avoid the potential buffer overrun but
both you and Jesper would need to agree that it's an appropriate API.

-- 
Mel Gorman
SUSE Labs
