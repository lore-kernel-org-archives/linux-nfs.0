Return-Path: <SRS0=Opkj=SP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D5F7C10F11
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Apr 2019 22:00:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3D35220870
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Apr 2019 22:00:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555192804;
	bh=mHOXzjgBtHLDN/xX+nYdjr+aPX0yQ3aLEdUFa8WejAA=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=1FmG6R4tBAzjCxWheIKXU6ZGUIU0VklC9ZFovBtNX5lIZLPpb+DuJt51E7kHJIk6D
	 Eo+okATbgfm9jwxCiHbZRIM5hWoWc0o024NlXSNpvcRKe5WNfqMu9RmUxmM7kwQ6sT
	 nYglu2+HaJtX8pcEY1mvl0eNF/jdbz1H4m9eoAks=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727042AbfDMWAD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 13 Apr 2019 18:00:03 -0400
Received: from mail.kernel.org ([198.145.29.99]:39110 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726964AbfDMWAD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 Apr 2019 18:00:03 -0400
Subject: Re: [GIT PULL] Please pull NFS client bugfixes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555192802;
        bh=mHOXzjgBtHLDN/xX+nYdjr+aPX0yQ3aLEdUFa8WejAA=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=E1NrHcyDOEEVqVgpw+1+JNwpjtqz1xDar3dc9z6Eb4HmHUCLyZ7owJqoTHhc5aUkw
         3eVZi9fE1Tza89Wkk2SHX7RbyXV1YGQfo/O8IERLLOUF1bzw/HWo2Gle57NlnJA79W
         vUxr4oTfhSn6uh298RuwGmSFvjoTL3eTn1k/mVss=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <6398aab500bfe326030981f919a0a1f7d92fcf28.camel@hammerspace.com>
References: <6398aab500bfe326030981f919a0a1f7d92fcf28.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <6398aab500bfe326030981f919a0a1f7d92fcf28.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-5.1-4
X-PR-Tracked-Commit-Id: af6b61d7ef58099c82d854395a0e002be6bd036c
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: b60bc0665e6af8c55b946b67ea8cb235823bb74e
Message-Id: <155519280236.8399.9297880621320142581.pr-tracker-bot@kernel.org>
Date:   Sat, 13 Apr 2019 22:00:02 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Sat, 13 Apr 2019 14:56:35 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.1-4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/b60bc0665e6af8c55b946b67ea8cb235823bb74e

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
