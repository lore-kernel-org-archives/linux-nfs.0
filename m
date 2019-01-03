Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B8F5C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:40:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 265922073F
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:40:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546483204;
	bh=V3lmIwnYMYmXb2MQ/oVB4bNar0I7SDO+/W8cs3vwJZE=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=L5NNhdhrssr2lhAWryGcSjdFCVbrXQHE0cDNUBlK4UvEEztWWrlTFhnITf2ZHKReF
	 T9uqmlyZq3HNslrznB4LEodohq09F5og3tuR7xf6r/8YlYRjROQLfbwLsHkPJcPCZc
	 BG441scXRVdiTAOjnA/7/abG+BHuwSqs2EizxmbM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726382AbfACCkD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 21:40:03 -0500
Received: from mail.kernel.org ([198.145.29.99]:43724 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726356AbfACCkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 21:40:03 -0500
Subject: Re: [GIT PULL] nfsd
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1546483202;
        bh=V3lmIwnYMYmXb2MQ/oVB4bNar0I7SDO+/W8cs3vwJZE=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=aYZh186TAtfifD7UwK9qM4mQuW83vS5K0h1UMcWh8rl/jaJrJsg8bnHRKC+u2CRK+
         Hn53rtNxKRK3OIoJarjOd92QzDiDy4MX8EFYUNO92kAoKNrctiWyBh8q5UgNEIa3Zg
         4CIdxpGWHFnJVmDg5Xr/+QlIWAPRpzKg6vgAnG94=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190102204307.GA28209@fieldses.org>
References: <20190102204307.GA28209@fieldses.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190102204307.GA28209@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.21
X-PR-Tracked-Commit-Id: 0ad30ff67bd3e82da8c1dc4d74b88aca846dbbd9
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: e45428a436765fcd154d461a2739b5640916dc00
Message-Id: <20190103024002.21791.85009.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Thu, 03 Jan 2019 02:40:02 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 2 Jan 2019 15:43:07 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.21

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/e45428a436765fcd154d461a2739b5640916dc00

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
