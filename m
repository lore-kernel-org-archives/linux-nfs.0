Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A83AC07E95
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Jul 2021 20:40:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 43D1F61CC3
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Jul 2021 20:40:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232238AbhGGUms (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Jul 2021 16:42:48 -0400
Received: from mail.kernel.org ([198.145.29.99]:44332 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230497AbhGGUms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jul 2021 16:42:48 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id AA09D61C53;
        Wed,  7 Jul 2021 20:40:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1625690407;
        bh=EvPfewQ3bogl0nmQe5DXceBHzrsx18RNDyqSrI77E3E=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=eGwNO4SNAE5IEP9mOEXYuiFcWmTvgCvQ0FHsZHwQ1kCVDcwTlg9Ah80SsooOfmn9q
         TRBybF+PJPlF97ZhdAAiZK7Fu4Ld7JUhnMoCqoQP88Vqnz0cnN0haoGDqZKG2HRxrl
         0utynQHeCTcv+4Nxe1kQ9bedL95RBNwkL4hb/Lw420PFqHVzT2iCdWl6ROBInwrwWv
         gmSAfZHfCcneQyCX5eWSRie//hVC70u4MPbWsy7TOO9LdiU6xC0QhL6WsKetqkghaj
         68lUVw8scx+KXIEMLFOe8J7Shw+qXeBC33MyZWC4e6CjPh6OtNAnykDvoMP5meaNh1
         F+dUWAkVUDxnw==
Subject: Re: [GIT PULL] nfsd changes for 5.14
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20210707150445.GA9911@fieldses.org>
References: <20210707150445.GA9911@fieldses.org>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20210707150445.GA9911@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.14
X-PR-Tracked-Commit-Id: ab1016d39cc052064e32f25ad18ef8767a0ee3b8
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 0cc2ea8cebe909203f994e9113dc1f1b3907d03c
Message-Id: <162569040755.28460.3385871028017375381.pr-tracker-bot@kernel.org>
Date:   Wed, 07 Jul 2021 20:40:07 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 7 Jul 2021 11:04:45 -0400:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.14

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/0cc2ea8cebe909203f994e9113dc1f1b3907d03c

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
