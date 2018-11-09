Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E13A2C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 11:19:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ABA8520818
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 11:19:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABA8520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727700AbeKIU7o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 15:59:44 -0500
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:57562 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727653AbeKIU7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Nov 2018 15:59:43 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 85C95A78;
        Fri,  9 Nov 2018 03:19:33 -0800 (PST)
Received: from localhost (unknown [10.1.35.69])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 42C263F718;
        Fri,  9 Nov 2018 03:19:33 -0800 (PST)
Received: from cmarinas by localhost with local (Exim 4.89)
        (envelope-from <catalin.marinas@arm.com>)
        id 1gL4p0-0005Br-FR; Fri, 09 Nov 2018 11:19:30 +0000
Date:   Fri, 9 Nov 2018 11:19:30 +0000
From:   Catalin Marinas <catalin.marinas@arm.com>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Message-ID: <20181109111930.idve77thgcnsg5u3@localhost>
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180917130335.112832-41-trond.myklebust@hammerspace.com>
User-Agent: NeoMutt/20170113 (1.7.2)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On Mon, Sep 17, 2018 at 09:03:31AM -0400, Trond Myklebust wrote:
> Most of this code should also be reusable with other socket types.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  include/linux/sunrpc/xprtsock.h |  19 +-
>  include/trace/events/sunrpc.h   |  15 +-
>  net/sunrpc/xprtsock.c           | 694 +++++++++++++++-----------------
>  3 files changed, 335 insertions(+), 393 deletions(-)

With latest mainline (24ccea7e102d, it includes Al Viro's iov_iter
fixup) I started hitting some severe slowdown and systemd timeouts with
nfsroot on arm64 machines (physical or guests under KVM). Interestingly,
it only happens when the client kernel is configured with 64K pages, the
4K pages configuration runs fine. It also runs fine if I add rsize=65536
to the nfsroot= argument.

Bisecting led me to commit 277e4ab7d530 ("SUNRPC: Simplify TCP receive
code by switching to using iterators"). Prior to this commit, it works
fine.

Some more info:

- defconfig with CONFIG_ARM64_64K_PAGES enabled

- kernel cmdline arg: nfsroot=<some-server>:/srv/nfs/debian-arm64,tcp,v4

- if it matters, the server is also an arm64 machine running 4.19 with
  4K pages configuration

I haven't figured out what's wrong or even how to debug this as I'm not
familiar with the sunrpc code. Any suggestion?

Thanks.

-- 
Catalin
