Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89680C11F66
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 08:24:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 60D4161DD6
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 08:24:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232364AbhF2I0o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jun 2021 04:26:44 -0400
Received: from outbound-smtp61.blacknight.com ([46.22.136.249]:33429 "EHLO
        outbound-smtp61.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S232308AbhF2I0o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2021 04:26:44 -0400
X-Greylist: delayed 583 seconds by postgrey-1.27 at vger.kernel.org; Tue, 29 Jun 2021 04:26:44 EDT
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
        by outbound-smtp61.blacknight.com (Postfix) with ESMTPS id E9198FACA9
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jun 2021 09:14:33 +0100 (IST)
Received: (qmail 27951 invoked from network); 29 Jun 2021 08:14:33 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.17.255])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 29 Jun 2021 08:14:33 -0000
Date:   Tue, 29 Jun 2021 09:14:32 +0100
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm/page_alloc: Return nr_populated when the array is
 full
Message-ID: <20210629081432.GE3840@techsingularity.net>
References: <162490397938.1485.7782934829743772831.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <162490397938.1485.7782934829743772831.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jun 28, 2021 at 02:12:59PM -0400, Chuck Lever wrote:
> The SUNRPC consumer of __alloc_bulk_pages() legitimately calls it
> with a full array sometimes. In that case, the correct return code,
> according to the API contract, is to return the number of pages
> already in the array/list.
> 
> Let's clean up the return logic to make it clear that the returned
> value is always the total number of pages in the array/list, not the
> number of pages that were allocated during this call.
> 
> Fixes: b3b64ebd3822 ("mm/page_alloc: do bulk array bounds check after checking populated elements")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Commit 66d9282523b3 ("mm/page_alloc: Correct return value of populated
elements if bulk array is populated") has since been merged as it was
the minimal obvious for the problem introduced but I have no objection
to your patch being rebased on top and sent as a cleanup.

Thanks.

-- 
Mel Gorman
SUSE Labs
