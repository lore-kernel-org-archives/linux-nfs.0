Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC5F8C4338F
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Aug 2021 02:35:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8B683610E6
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Aug 2021 02:35:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235877AbhHYCgF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Aug 2021 22:36:05 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46302 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235700AbhHYCgF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2021 22:36:05 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 48091C061757
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2021 19:35:20 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 4C51463F; Tue, 24 Aug 2021 22:35:19 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 4C51463F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1629858919;
        bh=zhAikeg7iXGrlRxa3lm1u7Oo+E2J8/K1lIucfZkhLVw=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=PA851fMft02L6asFWwdifJnh69bN7fIdJNVLGER2S8VKlDJ8l48TH+jTPrGEemwyW
         c+57yYF1DdyBpi/8acL6IE8HExnCsp7juxNHgB7/pcC6m2sGX2fidDtJetY624zxuf
         f9bDD3jLnFEKDXnFAOh5Ugao5XuTW4jK70mOF1pI=
Date:   Tue, 24 Aug 2021 22:35:19 -0400
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>, daire@dneg.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] reexport lock fixes v3
Message-ID: <20210825023519.GA13681@fieldses.org>
References: <1629493326-28336-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1629493326-28336-1-git-send-email-bfields@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Aug 20, 2021 at 05:01:58PM -0400, J. Bruce Fields wrote:
> With those changes I'm passing connecthon tests for NFSv3-4.2 reexports
> of an NFSv4.0 filesystem.

But I hadn't tested reexports of an NFSv3 filesystem.  With the
following server-side patch I also pass connectathon on NFSv3-4.2
reexports of an NFSv3 filesystem.--b.
