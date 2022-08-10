Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D77E7C25B07
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Aug 2022 21:24:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233429AbiHJVYf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Aug 2022 17:24:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33274 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233413AbiHJVYf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2022 17:24:35 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1DB54120B8;
        Wed, 10 Aug 2022 14:24:34 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id ACB036152F;
        Wed, 10 Aug 2022 21:24:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 154CAC433C1;
        Wed, 10 Aug 2022 21:24:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1660166673;
        bh=aIs7WmSm5CuDbO+IBMT22cWnClHc2dkzMjxPpE/zLtE=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=lEJsADQP92iOvtfiqaD2rCNvxC/Cz1PnEf0vXQvpUg8i/Y3lElnCTfQmPcn8R3qpv
         URvZ7KH4ml0DlMtA0/TRIYJxu+KnWGWwC6iIxRz4bfxtPjTiBvsO43VSGqr4F+wuGb
         LbMyjxlGqDKhsSWXLkNuivlfIg4EOkMscs9yWYydodnRCCuwUH/hCZ04hI982nRNBm
         5M4mqwQHBEIxXs3jXtJs2cCqizxKCy5vMKBxsnDraEm/+N8CbnJWp2hqtbc5q2e9Cz
         iWrFBEe2Qi8W/5UJv0Bz22oWf3/7+g3Bj1bAMCMDOO7Vbm71AxbMPrYCeTYN5ifSUW
         /ln6tm9T00Z3w==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 0397AC43141;
        Wed, 10 Aug 2022 21:24:33 +0000 (UTC)
Subject: Re: [GIT PULL] Please pull NFS client updates for Linux 5.20
From:   pr-tracker-bot@kernel.org
In-Reply-To: <57be8df581f3ec5face513ad7053d3a5121e1017.camel@hammerspace.com>
References: <57be8df581f3ec5face513ad7053d3a5121e1017.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <57be8df581f3ec5face513ad7053d3a5121e1017.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.20-1
X-PR-Tracked-Commit-Id: 3fa5cbdc44de190f2c5605ba7db015ae0d26f668
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: aeb6e6ac18c73ec287b3b1e2c913520699358c13
Message-Id: <166016667300.19160.1284039738338277703.pr-tracker-bot@kernel.org>
Date:   Wed, 10 Aug 2022 21:24:33 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 10 Aug 2022 15:22:40 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.20-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/aeb6e6ac18c73ec287b3b1e2c913520699358c13

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
