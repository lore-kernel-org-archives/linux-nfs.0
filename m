Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB17C433B4
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Apr 2021 20:57:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6C2C361158
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Apr 2021 20:57:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234781AbhDZU6V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 26 Apr 2021 16:58:21 -0400
Received: from mail.kernel.org ([198.145.29.99]:36206 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234752AbhDZU6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Apr 2021 16:58:20 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id 8663761153;
        Mon, 26 Apr 2021 20:57:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1619470658;
        bh=eiAPSiOgUnAj0z8UWhuLhYUD+9A8R85CPz+m0NJNzNc=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=VX04BqA5R6MTFWDe3PsH08VkdKBhBaJ3MuAQvGHvqmy+SvkvA3sP4w+zC8o1fHpiE
         o1HObZ9xlxEEmukSfTHK96ArN+VWl8CGUAPJo+9S5lUVLZVueCUnzdQR2GvgH6kkOy
         zf8VDKKT3Of3puAoaJsG9z3uiW92wiV9Vq4FyltPmhCojE/tbWLjB9wHlQq59akONL
         wnFCfoBKt5OfLcDO6TNZGRyLI4WLBcGJAoutm705jj3mEgfh0JVDsa0x4xUOlZ33L+
         11FqxT4UaEkrfO8derOa5D6Vy7L6D5jaEbO4dOej2Whf8UAPWZDnGIEcYw26zUJPvp
         uDNP5CGokmUCg==
Subject: Re: [GIT PULL] nfsd changes for 5.13
From:   pr-tracker-bot@kernel.org
In-Reply-To: <2CAF9044-0E80-411A-BCDA-D90A465A4C27@oracle.com>
References: <2CAF9044-0E80-411A-BCDA-D90A465A4C27@oracle.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <2CAF9044-0E80-411A-BCDA-D90A465A4C27@oracle.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.13
X-PR-Tracked-Commit-Id: b73ac6808b0f7994a05ebc38571e2e9eaf98a0f4
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: c065c42966dd3e9415164afcb9bfd4300227ffe9
Message-Id: <161947065852.16410.8917435600471922693.pr-tracker-bot@kernel.org>
Date:   Mon, 26 Apr 2021 20:57:38 +0000
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Mon, 26 Apr 2021 15:14:05 +0000:

> git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.13

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/c065c42966dd3e9415164afcb9bfd4300227ffe9

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
