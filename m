Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92146C432BE
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Sep 2021 07:21:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6EFB56108B
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Sep 2021 07:21:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242860AbhIBHW2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 2 Sep 2021 03:22:28 -0400
Received: from verein.lst.de ([213.95.11.211]:50217 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242506AbhIBHW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Sep 2021 03:22:28 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id E30D06736F; Thu,  2 Sep 2021 09:21:26 +0200 (CEST)
Date:   Thu, 2 Sep 2021 09:21:26 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     NeilBrown <neilb@suse.de>
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3 v3] NFSD: move filehandle format declarations out
 of "uapi".
Message-ID: <20210902072126.GA13773@lst.de>
References: <F517668C-DD79-4358-96AE-1566B956025A@oracle.com> <163054528774.24419.6639477440713170169@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <163054528774.24419.6639477440713170169@noble.neil.brown.name>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
