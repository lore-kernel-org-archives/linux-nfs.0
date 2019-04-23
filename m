Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACCE7C10F03
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 20:55:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 736D6218D3
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 20:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556052903;
	bh=QOzFdnt1icuM3XptZjZeJC4OEbIA/3YEwDSraUjgy9w=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=NaJxv5UtYFHB5hGNroIzzlMR1pgho3AvWyvQbO5NJf5Yovfvbwr4bITWMC/S1u/MB
	 cvUuHamTskbH8weloz6q5CgyNdNzhOI8fcoCor0oFcZwRfm9ND+j5dWtmD/4xDBYAX
	 25GwTIOdIF+vSB2lfG7I4lX/jEZ6dZ4o7GeGtXZQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726342AbfDWUzD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Apr 2019 16:55:03 -0400
Received: from mail.kernel.org ([198.145.29.99]:53196 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726029AbfDWUzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Apr 2019 16:55:02 -0400
Subject: Re: [GIT PULL] nfsd bugfixes for 5.1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1556052902;
        bh=QOzFdnt1icuM3XptZjZeJC4OEbIA/3YEwDSraUjgy9w=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=KB6fxj4NgQJBII9kgV0WHTU9nQtmZuDAb/f1PpxdQdFcIDIiOlTkDgPOVIe0ZJ2+k
         B8QewFygRqisPXIlLiWmvpRKH/Y5maXiY/AeuaWNucGCqNEBREO8lY2xEjYJyJp/qg
         3IohNo5xwAzEIyMbmNUFdUU9FxK1/6O7n5IkU4zI=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190423201139.GB10017@fieldses.org>
References: <20190423201139.GB10017@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190423201139.GB10017@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1-1
X-PR-Tracked-Commit-Id: f456458e4d25a8962d0946891617c76cc3ff5fb9
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 12a54b150fb5b6c2f3da932dc0e665355f8a5a48
Message-Id: <155605290227.7507.2089986292748608832.pr-tracker-bot@kernel.org>
Date:   Tue, 23 Apr 2019 20:55:02 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 23 Apr 2019 16:11:39 -0400:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/12a54b150fb5b6c2f3da932dc0e665355f8a5a48

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
