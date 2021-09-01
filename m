Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BFEAC432BE
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 07:44:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EB05560249
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 07:44:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242649AbhIAHpI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Sep 2021 03:45:08 -0400
Received: from verein.lst.de ([213.95.11.211]:46575 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242765AbhIAHpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Sep 2021 03:45:05 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 9FC1F68AFE; Wed,  1 Sep 2021 09:44:07 +0200 (CEST)
Date:   Wed, 1 Sep 2021 09:44:07 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     NeilBrown <neilb@suse.de>
Cc:     "J.  Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2 v2] NFSD: drop support for ancient filehandles
Message-ID: <20210901074407.GB18673@lst.de>
References: <20210827151505.GA19199@lst.de> <163038488360.7591.7865010833762169362@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <163038488360.7591.7865010833762169362@noble.neil.brown.name>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The content looks fine, but I still think moving the definition out of
the uapi and removing the ancient file handles are different things
that should be separate patches with separate commit logs explaining
the story.
