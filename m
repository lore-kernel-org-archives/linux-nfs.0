Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03EF4C433E0
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Jan 2021 18:01:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id ADC7F23117
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Jan 2021 18:01:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389931AbhALSBY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Jan 2021 13:01:24 -0500
Received: from mail.kernel.org ([198.145.29.99]:54990 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726262AbhALSBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Jan 2021 13:01:24 -0500
Received: by mail.kernel.org (Postfix) with ESMTPS id EB4E723117;
        Tue, 12 Jan 2021 18:00:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1610474444;
        bh=yRd0RRPZfvWebcKuaEFpX+iRUPpxqtOGmA2oK/ysksU=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=JHS2uiVAKTtq8dmEhgRje/vVqAkFcqXP4jPe3ZNZjuZfu/hDNS0/suF+U5VOJSG2g
         T/G/bemdCnGwcs1Rpe924yd+e5nGZVPLktZH7nweHOH5l8VfQ1wgCZzjbP2RApf+s9
         2IFzi+AgZHLzkf3zpO7RUmvaV15nWkQXWH5bhH60s7IOsIU2Q2EnGC1fsDJwFvZaDH
         Eff2f0fLKfoxedTDQsKld4OzUGPcZenb0j3dnNV6Pt+W2KPknqGibXEkF2Ml9IB2Bh
         A9d4oyHYtNHKDwSH9Ol55U69PpOolZeIC4tN3IqosteiYIUkmaNtUfzLjjBcwhgqfF
         Tt/FHbjmRoHgw==
Subject: Re: [GIT PULL] Please pull NFS client bugfixes
From:   pr-tracker-bot@kernel.org
In-Reply-To: <6c2dd95f73b0fcb9715e985bdde7dfb640ce8795.camel@hammerspace.com>
References: <6c2dd95f73b0fcb9715e985bdde7dfb640ce8795.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <6c2dd95f73b0fcb9715e985bdde7dfb640ce8795.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.11-2
X-PR-Tracked-Commit-Id: 896567ee7f17a8a736cda8a28cc987228410a2ac
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: e609571b5ffa3528bf85292de1ceaddac342bc1c
Message-Id: <161047444378.5916.14511439599344012428.pr-tracker-bot@kernel.org>
Date:   Tue, 12 Jan 2021 18:00:43 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 12 Jan 2021 14:31:12 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.11-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/e609571b5ffa3528bf85292de1ceaddac342bc1c

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
