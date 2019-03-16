Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C608CC43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 21:25:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E03D218D4
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 21:25:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552771504;
	bh=IjCOjBcExIMevnk7GRBORedatMK8SqlrB/kIoYaoOHU=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=NSQyZ/nCR1LPRvk9LYW5JRWtb0C5FsyJQsg371QSqrOR20UO6JaRXkmnYFZKozub/
	 yEzKdNNxOJ1ZRX8c1+BIbJ3D/lJbUG7ooywvkDKOTL9hkEGRyx+RpTu0nJf+lwqRlc
	 BG/ufGXM3tGP22zWwQFcwAnv+djTcyy+SMlwTXxw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726575AbfCPVZD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 17:25:03 -0400
Received: from mail.kernel.org ([198.145.29.99]:57544 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726418AbfCPVZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Mar 2019 17:25:03 -0400
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for 5.1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552771503;
        bh=IjCOjBcExIMevnk7GRBORedatMK8SqlrB/kIoYaoOHU=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=niEB+CrqlFOzMJuDfBKV3XYGZLMJnvYYQCbX1AfbqZZJwG/Fj+vxZwW9SyMKekSxW
         2MP9i+7QMFHfE8+wxshjpjmgqd4aHExmihGB7BFygv1KIBNX4ihnXgufaI83KR444o
         TVArUkuOu6ODPAHsrGzKIwuGh4m1hf5ZGxOD901k=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <3a30ab7dd854db06aca0a5f70b66e54cb9415c6e.camel@hammerspace.com>
References: <3a30ab7dd854db06aca0a5f70b66e54cb9415c6e.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <3a30ab7dd854db06aca0a5f70b66e54cb9415c6e.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-5.1-2
X-PR-Tracked-Commit-Id: 5e3863fd597eba8c6679de805681631b1aad9bdb
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 465c209db83e2cdaeb4a52f4e107a9fc636704db
Message-Id: <155277150299.28247.6280682067333480530.pr-tracker-bot@kernel.org>
Date:   Sat, 16 Mar 2019 21:25:02 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Sat, 16 Mar 2019 18:33:33 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.1-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/465c209db83e2cdaeb4a52f4e107a9fc636704db

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
