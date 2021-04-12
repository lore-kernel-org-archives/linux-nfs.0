Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8775DC43460
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 10:36:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 549FF601FC
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 10:36:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238364AbhDLKhL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Apr 2021 06:37:11 -0400
Received: from mx2.suse.de ([195.135.220.15]:60044 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S237219AbhDLKhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Apr 2021 06:37:09 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id D664AAF17;
        Mon, 12 Apr 2021 10:36:50 +0000 (UTC)
Subject: Re: [PATCH 3/9] mm/page_alloc: Add an array-based interface to the
 bulk page allocator
To:     Mel Gorman <mgorman@techsingularity.net>,
        Andrew Morton <akpm@linux-foundation.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Matthew Wilcox <willy@infradead.org>,
        Ilias Apalodimas <ilias.apalodimas@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>
References: <20210325114228.27719-1-mgorman@techsingularity.net>
 <20210325114228.27719-4-mgorman@techsingularity.net>
From:   Vlastimil Babka <vbabka@suse.cz>
Message-ID: <be02a041-22ff-4ed9-d249-e31e8983bb8d@suse.cz>
Date:   Mon, 12 Apr 2021 12:36:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.8.1
MIME-Version: 1.0
In-Reply-To: <20210325114228.27719-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 3/25/21 12:42 PM, Mel Gorman wrote:
> The proposed callers for the bulk allocator store pages from the bulk
> allocator in an array. This patch adds an array-based interface to the API
> to avoid multiple list iterations. The page list interface is preserved
> to avoid requiring all users of the bulk API to allocate and manage enough
> storage to store the pages.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
