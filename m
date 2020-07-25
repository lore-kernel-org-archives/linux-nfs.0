Return-Path: <SRS0=lN1T=BE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0E5EC433E0
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jul 2020 01:45:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9BC1F2070E
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jul 2020 01:45:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1595641503;
	bh=nDbzQo4FlsDr4K65K1frCbw1Qd15cnpLVdjpGufbwQ8=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=MTJZlLRJEcDOPzigQgWhnEtY8JfkXP7VwXOfD9MA8fIL/GPzowbYMuyASW8BZC2ys
	 jzerP1lc4gt2cuBdpP9PeRr9fbB134yX+cHPC98QZiq+Y3KliBW92u8crb/nkjNlu1
	 c2m6xtUGHHmB4/PhKwx9hcqMZ31IRqNvkm8rFirI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726916AbgGYBpC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 24 Jul 2020 21:45:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:33472 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726777AbgGYBpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Jul 2020 21:45:02 -0400
Subject: Re: [GIT PULL] nfsd bugfix for 5.8
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1595641502;
        bh=nDbzQo4FlsDr4K65K1frCbw1Qd15cnpLVdjpGufbwQ8=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=CEDc17dghSZNvODiPp1qjilQKtbLLLxdYPNGyLDkL9NEz43y3SYGd7cZTfQZ7o/XR
         VOgqbSudzaLBnVSENg19c63TKrmhpn5PstjAnwsXx+W6eRfN/r8EExXVgQLs6u5kG4
         ZF8u17U2F0dS5M2Qlyg+0aqsI0Gbrw3QEA1KuKSc=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20200724220225.GE9244@fieldses.org>
References: <20200724220225.GE9244@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20200724220225.GE9244@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.8-2
X-PR-Tracked-Commit-Id: 9affa435817711861d774f5626c393c80f16d044
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 5876aa073f52541f4787b6111c8494ea9cfcde15
Message-Id: <159564150212.24850.3724812187204727939.pr-tracker-bot@kernel.org>
Date:   Sat, 25 Jul 2020 01:45:02 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 24 Jul 2020 18:02:25 -0400:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.8-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/5876aa073f52541f4787b6111c8494ea9cfcde15

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
