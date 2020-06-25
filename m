Return-Path: <SRS0=LoRF=AG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0773BC433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Jun 2020 17:10:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C7A9E20773
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Jun 2020 17:10:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="oE067CRv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2406683AbgFYRKW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Jun 2020 13:10:22 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43682 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2406608AbgFYRKV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2020 13:10:21 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A757DC08C5C1
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2020 10:10:21 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 0BB4C799E; Thu, 25 Jun 2020 13:10:21 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 0BB4C799E
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1593105021;
        bh=WU+TO/n9GgoEaHfvenTyUXLR8n3YXnb2ZmpgBnJ/RFo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=oE067CRvJ/Ax8XHzp4KLEPilPoGjc7p3scoSL45ch7vQRR86A1UyOFh3a5deiXHD/
         ZY1YCErsRv6qw7YEt2UsUlVuh6yy9ZdHqhfcyj9t7uoYghy40pL5UxWAA3gR8+aiLV
         rxUbjbTNSnW+D6FQDKQ85g7JU3ieozAYcdekxEYo=
Date:   Thu, 25 Jun 2020 13:10:21 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Frank van der Linden <fllinden@amazon.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: nfsd filecache issues with v4
Message-ID: <20200625171021.GC30655@fieldses.org>
References: <20200608192122.GA19171@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200608192122.GA19171@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jun 08, 2020 at 07:21:22PM +0000, Frank van der Linden wrote:
> We recently noticed that, with 5.4+ kernels, the generic/531 test takes
> a very long time to finish for v4, especially when run on larger systems.
> 
> Case in point: a 72 VCPU, 144G EC2 instance as a client will make the test
> last about 20 hours.
> 
> So, I had a look to see what was going on. First of all, the test generates
> a lot of files - what it does is generate 50000 files per process, where
> it starts 2 * NCPU processes. So that's 144 processes in this case, 50000
> files each. Also, it does it by setting the file ulimit to 50000, and then
> just opening files, keeping them open, until it hits the limit.
> 
> So that's 7 million new/open files - that's a lot, but the problem can
> be triggered with far fewer than that as well.
> 
> Looking at what the server was doing, I noticed a lot of lock contention
> for nfsd_file_lru. Then I noticed that that nfsd_filecache_count kept
> going up, reflecting the number of open files by the client processes,
> eventually reaching, for example, that 7 million number.
> 
> So here's what happens: for NFSv4, files that are associated with an
> open stateid can stick around for a long time, as long as there's no
> CLOSE done on them. That's what's happening here. Also, since those files
> have a refcount of >= 2 (one for the hash table, one for being pointed to
> by the state), they are never eligible for removal from the file cache.
> Worse, since the code call nfs_file_gc inline if the upper bound is crossed
> (8192), every single operation that calls nfsd_file_acquire will end up
> walking the entire LRU, trying to free files, and failing every time.
> Walking a list with millions of files every single time isn't great.

Thanks for tracking this down.

> 
> There are some ways to fix this behavior like:
> 
> * Always allow v4 cached file structured to be purged from the cache.
>   They will stick around, since they still have a reference, but
>   at least they won't slow down cache handling to a crawl.

If they have to stick around anyway it seems too bad not to be able to
use them.

I mean, just because a file's opened first by a v4 user doesn't mean it
might not also have other users, right?

Would it be that hard to make nfsd_file_gc() a little smarter?

I don't know, maybe it's not worth it.

--b.

> * Don't add v4 files to the cache to begin with.
> 
> * Since the only advantage of the file cache for v4 is the caching
>   of files linked to special stateids (as far as I can tell), only
>   cache files associated with special state ids.
> 
> * Don't bother with v4 files at all, and revert the changes that
>   made v4 use the file cache.
> 
> In general, the resource control for files OPENed by the client is
> probably an issue. Even if you fix the cache, what if there are
> N clients that open millions of files and keep them open? Maybe
> there should be a fallback to start using temporary open files
> if a client goes beyond a reasonable limit and threatens to eat
> all resources.
> 
> Thoughts?
> 
> - Frank
