Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EB32C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 02:50:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E52720866
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 02:50:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545274225;
	bh=xMSVyithziHqTk7iIB5rYbku9ysdU1DcydlkvzLgsg8=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=ZSfVrGqb6AbcUBUK4Ozf/49knRwpKqBMZVQSAREfvDGZugH78mbqV1FdDGcyZvm9E
	 QXugonN1hR/shobJu77ityAiA4eOAXXkkn/JnRuyF5L4/jGaXc3fAdVc5knk6DPgD0
	 5cGY2t0mgZPqodNbQxXp3D3qNNt438xl/a/DTTVU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726725AbeLTCuY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 21:50:24 -0500
Received: from mail.kernel.org ([198.145.29.99]:36374 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727873AbeLTCuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 21:50:02 -0500
Subject: Re: [GIT PULL] Please pull NFS client  bugfixes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545274202;
        bh=xMSVyithziHqTk7iIB5rYbku9ysdU1DcydlkvzLgsg8=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=2WeGfaV4qzxxqbWb7j91Q/DXwhmUzbjrjN7TTzHmC9yxxY7QCNVrSG5tOI/bTfxb/
         EJIBhq0de9q2kXqRzlbxhaNDj38yEXa5wvO+5sHO9oan772aZJsMn7fIBItu9rBlp9
         8x0fVbxecexva5JdAkF2qgf5Q0Lx2AN+TtC01+zM=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
References: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-4.20-6
X-PR-Tracked-Commit-Id: abc13275771fac77e2d7b129c289522dacb644b6
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 8c9dff1ebd721a3b19a002d1a901d4dc31b18ebb
Message-Id: <20181220025002.15095.38961.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Thu, 20 Dec 2018 02:50:02 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 19 Dec 2018 16:49:11 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.20-6

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/8c9dff1ebd721a3b19a002d1a901d4dc31b18ebb

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
