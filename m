Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCF4C433B4
	for <linux-nfs@archiver.kernel.org>; Wed,  5 May 2021 20:49:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F26FD6141B
	for <linux-nfs@archiver.kernel.org>; Wed,  5 May 2021 20:49:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230161AbhEEUuj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 May 2021 16:50:39 -0400
Received: from mail.kernel.org ([198.145.29.99]:60022 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230094AbhEEUu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 May 2021 16:50:29 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id BD7E2613EC;
        Wed,  5 May 2021 20:49:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1620247772;
        bh=AP3irDjXHLvvnt6/4olMg5U7kVl0ZwI+NF3LxPr2kMM=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=RvYuF6UjC8IJwJTn3ItnngATVD0GjL5lqz9AjDImlYeFjIIUOdnQZXhiOfhkh2Xwu
         sAUF3cG43o8S9ul/uQzkGWFA5f/6EtCgWULiTUDoDtf6WXy8AlWtyeeQufrMlCMCao
         fo1uV9jYIL+13h/CHiYe7VsvudsH4tlO/HHl8QnpcOlODt+u7hkcFfHQwEM4/CVFB/
         fuU+mSC7eBxY/gbbZq8ULuS549lNGqhFLXFf2YcxtB4c7w/ogfiTLu1QyXemmPofxV
         QCBfFuuedDsYiFVPdzzRZdrkCd1IZk4tEyQ28WTTWHqWrqOkpN9/4CoiyDy/YXvItq
         /9oo5kvQ0b7yw==
Subject: Re: [GIT PULL] more nfsd changes for 5.13
From:   pr-tracker-bot@kernel.org
In-Reply-To: <4FD9AA6A-3880-4C39-9A32-F22A42ADB508@oracle.com>
References: <4FD9AA6A-3880-4C39-9A32-F22A42ADB508@oracle.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <4FD9AA6A-3880-4C39-9A32-F22A42ADB508@oracle.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.13-1
X-PR-Tracked-Commit-Id: b9f83ffaa0c096b4c832a43964fe6bff3acffe10
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: a79cdfba68a13b731004f0aafe1155a83830d472
Message-Id: <162024777274.12235.16163291295420630973.pr-tracker-bot@kernel.org>
Date:   Wed, 05 May 2021 20:49:32 +0000
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 5 May 2021 16:20:52 +0000:

> git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.13-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/a79cdfba68a13b731004f0aafe1155a83830d472

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
