Return-Path: <SRS0=uC47=5X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A524C2BB1D
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Apr 2020 21:05:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F19C2075E
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Apr 2020 21:05:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586293504;
	bh=GwR0wzr3+rrzrybeBI5vRkSp3OQWnBjYSVELK66dLUM=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=wDGozQx80lkblmRFtl3FQiWwcsDxuqzRZhPEJtNmASvZPB0b8h+OtdNx6lDu5BmcV
	 6ttSlAsDaik62YzsAf0tTzsufoKxB4/UmYiFtb+agp6IZ3YlbLjJyaZ2a19PhKHOrU
	 9XG8FNI1F5iB4Smd+p7fqvSq84zd7D7YU9l7PuXk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726464AbgDGVFD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 7 Apr 2020 17:05:03 -0400
Received: from mail.kernel.org ([198.145.29.99]:54892 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726403AbgDGVFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Apr 2020 17:05:03 -0400
Subject: Re: [GIT PULL] Please pull NFS client changes for 5.7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586293503;
        bh=GwR0wzr3+rrzrybeBI5vRkSp3OQWnBjYSVELK66dLUM=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=VVVKs5BCfQ7aQ0WC/ff6ywUswXdqzpFlR0pYeTb1nHvOSUL0hWdv31fvD9IwPquiZ
         yfx9vY86iE15x8ncb0R6h9SkfRw/XfiU5Nn5KeBewWrF2QHh8hmAaQRCLqSxs5k7Ur
         5dQ1NzIqbxS/2miIhVpiWtBBhYEoleKmrLjYVI+Q=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <1b03a9c180bb1b7a0bef4de40c82e84cb6cb1740.camel@hammerspace.com>
References: <1b03a9c180bb1b7a0bef4de40c82e84cb6cb1740.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <1b03a9c180bb1b7a0bef4de40c82e84cb6cb1740.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-5.7-1
X-PR-Tracked-Commit-Id: 93ce4af774bc3d8a72ce2271d03241c96383629d
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 04de788e61a576820baf03ff8accc246ca146cb3
Message-Id: <158629350313.19531.14350795038377205444.pr-tracker-bot@kernel.org>
Date:   Tue, 07 Apr 2020 21:05:03 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 7 Apr 2020 12:23:06 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.7-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/04de788e61a576820baf03ff8accc246ca146cb3

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
