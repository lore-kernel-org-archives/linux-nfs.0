Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BB4FC4320A
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 07:44:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EAC8461056
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 07:44:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242640AbhIAHp1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Sep 2021 03:45:27 -0400
Received: from verein.lst.de ([213.95.11.211]:46577 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242654AbhIAHpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Sep 2021 03:45:25 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 8E30F68AFE; Wed,  1 Sep 2021 09:44:27 +0200 (CEST)
Date:   Wed, 1 Sep 2021 09:44:27 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     NeilBrown <neilb@suse.de>
Cc:     "J.  Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: simplify struct nfsfh
Message-ID: <20210901074427.GC18673@lst.de>
References: <163038488360.7591.7865010833762169362@noble.neil.brown.name> <163038495873.7591.9260775605693695494@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <163038495873.7591.9260775605693695494@noble.neil.brown.name>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
