Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34F65C6379D
	for <linux-nfs@archiver.kernel.org>; Wed, 18 Nov 2020 20:13:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CF9082076C
	for <linux-nfs@archiver.kernel.org>; Wed, 18 Nov 2020 20:13:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l+hL6FWg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726915AbgKRUNz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 18 Nov 2020 15:13:55 -0500
Received: from mail.kernel.org ([198.145.29.99]:46708 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725782AbgKRUNy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Nov 2020 15:13:54 -0500
Subject: Re: [GIT PULL] nfsd bugfix for 5.10
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605730434;
        bh=tLbWWVsVbNP13mpIn0rfCT4xsjB4FKjy0g0G47H+PUU=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=l+hL6FWgzcoSoluidZBeMaq48fF4Wv/6QTLNzfXqH1epPWXPMPuxQJtfFS2lEavRg
         ne8xpLKebuYUgFUjV8mkYoHtn4qTE/HPZRIfrcMd9ecice27bGVZXsKcc91X3PZD9u
         kbaVsrEBeCqJBl6ZiS/rU/8MCxvMd31KoLsw9SU4=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20201118151513.GC7320@fieldses.org>
References: <20201118151513.GC7320@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20201118151513.GC7320@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.10-2
X-PR-Tracked-Commit-Id: c3213d260a23e263ef85ba21ac68c9e7578020b5
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ce228d45942492580968d698b0216d3356d75226
Message-Id: <160573043437.16719.8380223673835473520.pr-tracker-bot@kernel.org>
Date:   Wed, 18 Nov 2020 20:13:54 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 18 Nov 2020 10:15:13 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.10-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ce228d45942492580968d698b0216d3356d75226

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
