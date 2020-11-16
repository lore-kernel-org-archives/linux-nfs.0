Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 524E5C6379F
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Nov 2020 15:53:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E027120A8B
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Nov 2020 15:53:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="sYvoy3ft"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731618AbgKPPxb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Nov 2020 10:53:31 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57756 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730396AbgKPPxa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Nov 2020 10:53:30 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6DC9DC0613CF
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2020 07:53:30 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7A8201C15; Mon, 16 Nov 2020 10:53:29 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7A8201C15
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1605542009;
        bh=Ny07iHxjWLoj2q2R1rtuW/nJcivEp1XpS+prISCHZfw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=sYvoy3ft+Hzey6TdgRfVwLQwKwo7GnaqgDYfbN0h2jF14GRcUwsJe7CTqS5wZpwE5
         jS+F54oovFHzYCeMLfTC7+IFJqI7Cj8fvNWdD5F2Jh5J6d2bqbbbbS64+1zb4OGZLO
         ywtlf7IjGAsi0/v/IWVVKIEmX++It6mlPAX9HugY=
Date:   Mon, 16 Nov 2020 10:53:29 -0500
From:   bfields <bfields@fieldses.org>
To:     Daire Byrne <daire@dneg.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        linux-cachefs <linux-cachefs@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Adventures in NFS re-exporting
Message-ID: <20201116155329.GE898@fieldses.org>
References: <943482310.31162206.1599499860595.JavaMail.zimbra@dneg.com>
 <1744768451.86186596.1605186084252.JavaMail.zimbra@dneg.com>
 <20201112135733.GA9243@fieldses.org>
 <444227972.86442677.1605206025305.JavaMail.zimbra@dneg.com>
 <20201112205524.GI9243@fieldses.org>
 <883314904.86570901.1605222357023.JavaMail.zimbra@dneg.com>
 <20201113145050.GB1299@fieldses.org>
 <20201113222600.GC1299@fieldses.org>
 <217712894.87456370.1605358643862.JavaMail.zimbra@dneg.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <217712894.87456370.1605358643862.JavaMail.zimbra@dneg.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Nov 14, 2020 at 12:57:24PM +0000, Daire Byrne wrote:
> Now if anyone has any ideas why all the read calls to the originating
> server are limited to a maximum of 128k (with rsize=1M) when coming
> via the re-export server's nfsd threads, I see that as the next
> biggest performance issue. Reading directly on the re-export server
> with a userspace process issues 1MB reads as expected. It doesn't
> happen for writes (wsize=1MB all the way through) but I'm not sure if
> that has more to do with async and write back caching helping to build
> up the size before commit?

I'm not sure where to start with this one....

Is this behavior independent of protocol version and backend server?

> I figure the other remaining items on my (wish) list are probably more
> in the "won't fix" or "can't fix" category (except maybe the NFSv4.0
> input/output errors?).

Well, sounds like you've found a case where this feature's actually
useful.  We should make sure that's documented.

And I think it's also worth some effort to document and triage the list
of remaining issues.

--b.
