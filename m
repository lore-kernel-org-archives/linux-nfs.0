Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52DB8C11F67
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 15:41:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2D68461DBF
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 15:41:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232288AbhF2Pnp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jun 2021 11:43:45 -0400
Received: from outbound-smtp29.blacknight.com ([81.17.249.32]:60549 "EHLO
        outbound-smtp29.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S232469AbhF2Pnp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2021 11:43:45 -0400
X-Greylist: delayed 445 seconds by postgrey-1.27 at vger.kernel.org; Tue, 29 Jun 2021 11:43:44 EDT
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
        by outbound-smtp29.blacknight.com (Postfix) with ESMTPS id 58D8C18E06A
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jun 2021 16:33:51 +0100 (IST)
Received: (qmail 9884 invoked from network); 29 Jun 2021 15:33:51 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.17.255])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 29 Jun 2021 15:33:51 -0000
Date:   Tue, 29 Jun 2021 16:33:49 +0100
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com
Subject: Re: [PATCH v3] mm/page_alloc: Further fix __alloc_pages_bulk()
 return value
Message-ID: <20210629153349.GG3840@techsingularity.net>
References: <162497449506.16614.7781489905877008435.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <162497449506.16614.7781489905877008435.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jun 29, 2021 at 09:48:15AM -0400, Chuck Lever wrote:
> The author of commit b3b64ebd3822 ("mm/page_alloc: do bulk array
> bounds check after checking populated elements") was possibly
> confused by the mixture of return values throughout the function.
> 
> The API contract is clear that the function "Returns the number of
> pages on the list or array." It does not list zero as a unique
> return value with a special meaning. Therefore zero is a plausible
> return value only if @nr_pages is zero or less.
> 
> Clean up the return logic to make it clear that the returned value
> is always the total number of pages in the array/list, not the
> number of pages that were allocated during this call.
> 
> The only change in behavior with this patch is the value returned
> if prepare_alloc_pages() fails. To match the API contract, the
> number of pages currently in the array/list is returned in this
> case.
> 
> The call site in __page_pool_alloc_pages_slow() also seems to be
> confused on this matter. It should be attended to by someone who
> is familiar with that code.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
