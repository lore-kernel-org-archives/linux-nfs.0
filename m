Return-Path: <SRS0=KacW=XX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F93EC4360C
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Sep 2019 01:15:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DB0221655
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Sep 2019 01:15:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569633305;
	bh=7aOUjdezsTd6RNB3MK+Zy5lRVFHt/aG2SjoaqKn51VA=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=fzaJCjZ72DWjcJSSeVKz9IiRbCMWb4tjhOav0QZomIH5sUs4z28MpvuEZ7Yhx4Lv+
	 6fd7PId1Z8OmL78w+dAg5WM3fwmR1o2ZduhrvEETOaezDFGjBIpBxhL9XOaazw0MNs
	 TGoRtIe1YtAcwUylpCe6URcHzik87W88ySEV1PBg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725815AbfI1BPE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 Sep 2019 21:15:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:47676 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725306AbfI1BPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Sep 2019 21:15:04 -0400
Subject: Re: [GIT PULL] nfsd changes for 5.4
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569633303;
        bh=7aOUjdezsTd6RNB3MK+Zy5lRVFHt/aG2SjoaqKn51VA=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=YPKFrrgBtRmJ372EB1gPSU53IvAqSasvBaOOiLhiCiLHte3uUpc1XVsuBzJH2CtjS
         o9EfK1wKWZq44+VQfdUke3FLhtAO0YCeTKuKOkoBefUmAB2m7iuq874ISEdV8Unlkx
         Sq9uLL9DMTHKdJslsmG52MfBJTjmoUz1MZdD79j4=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190927200838.GA2618@fieldses.org>
References: <20190927200838.GA2618@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190927200838.GA2618@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.4
X-PR-Tracked-Commit-Id: 64a38e840ce5940253208eaba40265c73decc4ee
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 4f375483559c94ec7c58fa3499e28e327d1ef911
Message-Id: <156963330384.27765.9291757462869185181.pr-tracker-bot@kernel.org>
Date:   Sat, 28 Sep 2019 01:15:03 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 27 Sep 2019 16:08:38 -0400:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/4f375483559c94ec7c58fa3499e28e327d1ef911

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
