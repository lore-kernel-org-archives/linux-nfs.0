Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 240CEC10F00
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 01:50:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E50AC222ED
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 01:50:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550368221;
	bh=iJ45b1HSYg1KAFHb+yGG6QXiID7GyR+5ZtxpihNyqjc=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=mrNbAAjqKieGq7By9Uea1EtyX5LgkbFh2HKluaAbj4z3kgC76eYUZ3sTDZ7YQ4IlV
	 lVqvfbEIEn68f9qCp8Vz8b/a3y5NeQ+lBcxxwdlxlE8SXKOlvsHiUNh5jiPAeMCmK0
	 nrk4iQxb/ffITSpggXol2KP4sr1RJ7rl+uqEfMmE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730763AbfBQBuT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Feb 2019 20:50:19 -0500
Received: from mail.kernel.org ([198.145.29.99]:56724 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727969AbfBQBuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Feb 2019 20:50:03 -0500
Subject: Re: [GIT PULL] more nfsd fixes for 5.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550368202;
        bh=iJ45b1HSYg1KAFHb+yGG6QXiID7GyR+5ZtxpihNyqjc=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=OpToG1vm1SSzYkxN5cAw9v2GIx6O+KmW84z3I77sOJX9fYjdvAujbGgUaTwvzhsJM
         k8X5gQheTo6mpf2IhGnml8SY+HhU9QjsrhP4s8IsrGJGyXN02RI2V9+zi9/qb+ZmLM
         B5kZeZ81vzmTFQwkTox05m4o6dcs6JwovE+zHv7Y=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190215220102.GD22354@fieldses.org>
References: <20190215220102.GD22354@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190215220102.GD22354@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.0-2
X-PR-Tracked-Commit-Id: e7afe6c1d486b516ed586dcc10b3e7e3e85a9c2b
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 88fe73cb804abc3d209a06f6221a7108d89ff04f
Message-Id: <155036820240.25738.16783624746161570411.pr-tracker-bot@kernel.org>
Date:   Sun, 17 Feb 2019 01:50:02 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 15 Feb 2019 17:01:02 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.0-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/88fe73cb804abc3d209a06f6221a7108d89ff04f

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
