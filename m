Return-Path: <SRS0=0ybF=OQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4978AC64EB1
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 18:35:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0C61E20868
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 18:35:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1544207703;
	bh=tu4YAEX4IERyIg+PTF8ZajZ0J1XI/D0LIumr/49tOzc=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=Sl1yLlzBOTux+s4l6BoBlGXe21syx6c/8s05jt4e3P9smSJWKCnmVLfkw5fO9ERi8
	 bs2XqRrV3zmVkrMiOw8ZzNnH8V43Kn+B04bs9DI2DKdtB66MokVPcWyK7gBqJ92kUy
	 qCOd7DgFj6V+WzJwTiR1jgyNTLkoAubXSQxex02U=
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C61E20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726304AbeLGSfC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Dec 2018 13:35:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:54928 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726061AbeLGSfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Dec 2018 13:35:02 -0500
Subject: Re: [GIT PULL] Please pull NFS client changes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1544207701;
        bh=tu4YAEX4IERyIg+PTF8ZajZ0J1XI/D0LIumr/49tOzc=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=QLrf1GsEAdMDoC+nNX9vD+VHaXRgY4YwmiJ57oXdR1MC8mAlqd9MbTRELuEwqNeEv
         Valq9W9gs+lWj11zn3JAiBdBBbH8TTC5EvPU52XusVyrLVZ1Sr/iAPz7p9cFMS0Src
         /JJCbfb6xZ2OXLHi7J1eh7n5azWZbjgNWVYFkjek=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <af690bb605f8366f8b437ca0171edef42fc63e83.camel@hammerspace.com>
References: <af690bb605f8366f8b437ca0171edef42fc63e83.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <af690bb605f8366f8b437ca0171edef42fc63e83.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-4.20-5
X-PR-Tracked-Commit-Id: 79462857eb547e5d17fc8445b9768615e02dc1cf
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 7f80c7325be49db3fb8b5f343f47691b7999fda7
Message-Id: <20181207183501.15805.51648.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Fri, 07 Dec 2018 18:35:01 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 6 Dec 2018 21:55:54 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.20-5

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/7f80c7325be49db3fb8b5f343f47691b7999fda7

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
