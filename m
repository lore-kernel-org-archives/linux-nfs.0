Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15EC9C433DB
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 12:16:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C1C4161A10
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 12:16:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230242AbhCYMQL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Mar 2021 08:16:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50104 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229533AbhCYMPx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Mar 2021 08:15:53 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7F2D5C06174A;
        Thu, 25 Mar 2021 05:15:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=WHCc14VHAl0E1rtR7XCz+SysoOI7DyQ6FX+b+kCG0A4=; b=WX3isQ84S9El/isa7ddU7bux/K
        0g1qr4leAT3T3g+/U2/EIojJLVifkLuv8ZJUKt7zAYkAK7mlzuuFTk/lprNEvmef4B9OSfJ//NaiR
        IKlbOkCZDm5yeeYuShQW9BJnJmYYwmXQ5pS3xtJNxEezEhEyHt2+mXYFVCvCOdzIyYG+kZjbWG0mX
        YrCxxafw2sWKP2dqRhTE1wc9FJMcSvDt95L2gArFbIavef2PHRIodcCFNhEXuujcxb420RnyJrAFp
        Cv1DTpQ6Niz4eDLMj4TGJJo1tKKIgDFMkapxdycn9vgDdUlsKeF2PUVsCvkwWWgS0VWiNtgOfncf5
        y8ML6fOg==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lPOqX-00CsAu-Ma; Thu, 25 Mar 2021 12:12:50 +0000
Date:   Thu, 25 Mar 2021 12:12:17 +0000
From:   Matthew Wilcox <willy@infradead.org>
To:     Mel Gorman <mgorman@techsingularity.net>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Vlastimil Babka <vbabka@suse.cz>,
        Ilias Apalodimas <ilias.apalodimas@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/9] mm/page_alloc: optimize code layout for
 __alloc_pages_bulk
Message-ID: <20210325121217.GV1719932@casper.infradead.org>
References: <20210325114228.27719-1-mgorman@techsingularity.net>
 <20210325114228.27719-5-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210325114228.27719-5-mgorman@techsingularity.net>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 25, 2021 at 11:42:23AM +0000, Mel Gorman wrote:
>  
> -	if (WARN_ON_ONCE(nr_pages <= 0))
> +	if (unlikely(nr_pages <= 0))
>  		return 0;

If we made nr_pages unsigned, we wouldn't need this check at all (ok,
we'd still need to figure out what to do with 0).  But then, if a user
inadvertently passes in -ENOMEM, we'll try to allocate 4 billion pages.
So maybe we should check it.  Gah, API design is hard.

