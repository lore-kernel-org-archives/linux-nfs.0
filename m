Return-Path: <SRS0=BC+Y=QO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03172C282C2
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 23:05:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C658E2175B
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 23:05:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549580703;
	bh=XTkoozWHsFHEvAHOStYGCp1iv8CU2yDJogo3n5EE4LE=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=BJvbWWYjgLYRTkft1WIvJ3stKZmROlEcO6vOLHfIow0tlXb4NetK4uKfq5VK75ggN
	 VRn/pK0BNzpvKlTB1cO5fOk5ZmhD0F0jmffgq0pOjKUdiyqsThDSqnzOJQsDEX6nbE
	 UX3jxDOWF+NqkQkCPUOUk7CnplVNOegdoLMCJrpE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726728AbfBGXFC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 18:05:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:57470 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726622AbfBGXFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 18:05:02 -0500
Subject: Re: [GIT PULL] nfsd fixes for 5.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549580702;
        bh=XTkoozWHsFHEvAHOStYGCp1iv8CU2yDJogo3n5EE4LE=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=dJ3DC3yRkScS+FXnuyo1ilDbdtRM5wBscDB0Au4lfa5PI8lgf6Yb/Zwxnl1T7pnGy
         bEeQk6E9azOSaQMHrzaYzkYeCPtYIP9frq3qhWdv2cdXzYHCPQofWng6Q9/kg020Oi
         ABEfsc7IgI0ZYy347EEWLak2kn9k/Ytojtnh9tPc=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190207214442.GE27008@fieldses.org>
References: <20190207214442.GE27008@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190207214442.GE27008@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.0-1
X-PR-Tracked-Commit-Id: e248aa7be86e8179f20ac0931774ecd746f3f5bf
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ee6c0737a0253d6e79063f0a74c1101fdaad0812
Message-Id: <154958070218.8830.16571589209333296613.pr-tracker-bot@kernel.org>
Date:   Thu, 07 Feb 2019 23:05:02 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 7 Feb 2019 16:44:42 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.0-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ee6c0737a0253d6e79063f0a74c1101fdaad0812

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
