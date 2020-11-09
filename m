Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB8DAC2D0A3
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Nov 2020 20:45:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6928220789
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Nov 2020 20:45:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aC0UOXiF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729451AbgKIUpm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Nov 2020 15:45:42 -0500
Received: from mail.kernel.org ([198.145.29.99]:58208 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725946AbgKIUpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Nov 2020 15:45:42 -0500
Subject: Re: [GIT PULL] nfsd 5.10 fixes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604954742;
        bh=wau2bKsbr3znN4eEUD3LQEJJ/8LzLWiKWUZn66J2GJg=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=aC0UOXiFeiJfi0xzfrAiK3ji7gyGOhzG2Vm+vZpIDM+50wh8mC4Y2ah4jIvU9zwcT
         v/MzrZ3Y8E9ITR+5CFKdWk9ERDtOiBcbbNTsy6jOwuHJM07BZvTnpcl5R7nnHzPTm/
         UxKD3iC97MQhr9A2lM5FS4MMN7p3EZcuV3x4i6JQ=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20201109191112.GE11144@fieldses.org>
References: <20201109191112.GE11144@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20201109191112.GE11144@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.10-1
X-PR-Tracked-Commit-Id: ae2975046dbc65855c217fe6fbd5b33140c5ff18
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 3552c3709c0e78144c11748718180441ac647ece
Message-Id: <160495474213.25406.14082203375029717249.pr-tracker-bot@kernel.org>
Date:   Mon, 09 Nov 2020 20:45:42 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Mon, 9 Nov 2020 14:11:12 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.10-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/3552c3709c0e78144c11748718180441ac647ece

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
