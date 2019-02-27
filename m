Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55335C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 00:31:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1A0AC218D3
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 00:31:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728942AbfB0AbI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 19:31:08 -0500
Received: from muru.com ([72.249.23.125]:40888 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728896AbfB0AbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 19:31:08 -0500
Received: from atomide.com (localhost [127.0.0.1])
        by muru.com (Postfix) with ESMTPS id BA8A580CD;
        Wed, 27 Feb 2019 00:31:16 +0000 (UTC)
Date:   Tue, 26 Feb 2019 16:31:02 -0800
From:   Tony Lindgren <tony@atomide.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "jonathanh@nvidia.com" <jonathanh@nvidia.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Message-ID: <20190227003102.GF39872@atomide.com>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
 <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
 <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
 <9b9a6c5e34edea13b3ace42d39d97c27fd21c0db.camel@hammerspace.com>
 <20190226183340.GD39872@atomide.com>
 <eeb255aca46e9b1d9d030c5b917c663b83468bcb.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eeb255aca46e9b1d9d030c5b917c663b83468bcb.camel@hammerspace.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

* Trond Myklebust <trondmy@hammerspace.com> [190226 20:40]:
> I've applied the following patch to my 'testing' branch: 
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=patch;h=a73881c96d73ee72b7dbbd38a6eeef66182a8ef7
> 
> It has so far stood up to testing on my side, so I'm expecting to push
> it to linux-next this evening.

OK, works for me too based on a quick test of few NFSroot boots.

Thanks,

Tony
