Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2AC3C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 18:33:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B466521852
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 18:33:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729035AbfBZSdo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 13:33:44 -0500
Received: from muru.com ([72.249.23.125]:40836 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728736AbfBZSdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 13:33:43 -0500
Received: from atomide.com (localhost [127.0.0.1])
        by muru.com (Postfix) with ESMTPS id 49C4980CD;
        Tue, 26 Feb 2019 18:33:54 +0000 (UTC)
Date:   Tue, 26 Feb 2019 10:33:40 -0800
From:   Tony Lindgren <tony@atomide.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "jonathanh@nvidia.com" <jonathanh@nvidia.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Message-ID: <20190226183340.GD39872@atomide.com>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
 <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
 <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
 <9b9a6c5e34edea13b3ace42d39d97c27fd21c0db.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9b9a6c5e34edea13b3ace42d39d97c27fd21c0db.camel@hammerspace.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

* Trond Myklebust <trondmy@hammerspace.com> [700101 00:00]:
> On Mon, 2019-02-25 at 22:27 +0000, Jon Hunter wrote:
> > On 25/02/2019 21:03, Trond Myklebust wrote:
> > This is nfsroot. I don't specify any particular NFS version from 
> > the kernel cmdline, but this is seen with ARM kernel configs
> > tegra_defconfig and multi_v7_defconfig. 
> > 
> > Looking at the logs I am seeing the following crash which appears
> > to point to UDP ...
> > 
> > [    8.032956] Unable to handle kernel NULL pointer dereference at
> > virtual address 00000024
> > [    8.041137] pgd = (ptrval)
> > [    8.043858] [00000024] *pgd=00000000
> > [    8.047437] Internal error: Oops: 5 [#1] SMP ARM
> > [    8.052049] Modules linked in:
> > [    8.055104] CPU: 1 PID: 100 Comm: kworker/u9:2 Not tainted 5.0.0-
> > rc7-next-20190222-g94a4752 #1
> > [    8.063699] Hardware name: NVIDIA Tegra SoC (Flattened Device
> > Tree)
> > [    8.069960] Workqueue: xprtiod xs_udp_data_receive_workfn
> > [    8.075353] PC is at udp_poll+0x30/0x64
> > [    8.079178] LR is at udp_poll+0x10/0x64
> 
> Thanks! I see what the issue is now and I'll be fixing it ASAP.

I'm seeing this also with NFSroot. I can test the fix when available,
that is if you can please Cc me on the fix.

Thanks,

Tony
