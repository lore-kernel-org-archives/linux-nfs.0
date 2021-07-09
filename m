Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10523C07E9C
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Jul 2021 17:41:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EDB05613C8
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Jul 2021 17:41:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229990AbhGIRoY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Jul 2021 13:44:24 -0400
Received: from mail.kernel.org ([198.145.29.99]:41384 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230162AbhGIRoX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jul 2021 13:44:23 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id B09A0613C8;
        Fri,  9 Jul 2021 17:41:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1625852499;
        bh=AjYyRtvwaQnYpOXBJtY7jYQPb1cwmEb0edqd9upI4UA=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=FFuZJa9jbf/JCFxnbp+OhraX1Ii6zDwuv9UuUQy6dMYctBMTE8jNJNZZ/UVBiP/WF
         /voBzOphEHm3LzdyXZa6rBsgp6wEmrbm/0/c+1qvaSoeXEL3F/UaKvPMgTLazDHo3A
         iiYQRKxLELmZe5MHm6uJBUxSwbrFzpsbiXa1huzx2t9VUVafsw691gCSXMD0y/IxkY
         abcpeCAdBZ4Pz0vWFEi95c6uPfzIYc96Ia92TxUNkG3ZNXPrte/cKWRtrgvwVPf6P8
         bSxoZFCSoK289fS5up2ziU+vFtKRRkRaCyYULqOCbz7EUGAdJ0ncQgUgl6Gxi9bCco
         JddPz1A4iMSYA==
Subject: Re: [GIT PULL] Please pull NFS client changes for 5.14
From:   pr-tracker-bot@kernel.org
In-Reply-To: <6809750d3e746fb0732995bb9a0c1fa846bbd486.camel@hammerspace.com>
References: <6809750d3e746fb0732995bb9a0c1fa846bbd486.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <6809750d3e746fb0732995bb9a0c1fa846bbd486.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.14-1
X-PR-Tracked-Commit-Id: 878b3dfc42c4ddbf9e38cd9061e3ddd99a69747a
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 96890bc2eaa1f6bfc1b194e0f0815a10824352a4
Message-Id: <162585249969.25269.5916072440450691466.pr-tracker-bot@kernel.org>
Date:   Fri, 09 Jul 2021 17:41:39 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 8 Jul 2021 18:16:06 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.14-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/96890bc2eaa1f6bfc1b194e0f0815a10824352a4

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
