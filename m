Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30A90C433F5
	for <linux-nfs@archiver.kernel.org>; Wed,  8 Sep 2021 23:31:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0C7DF60F01
	for <linux-nfs@archiver.kernel.org>; Wed,  8 Sep 2021 23:31:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235905AbhIHXcy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 8 Sep 2021 19:32:54 -0400
Received: from mail.kernel.org ([198.145.29.99]:51002 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S235669AbhIHXcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Sep 2021 19:32:53 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id 4D95660F01;
        Wed,  8 Sep 2021 23:31:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1631143905;
        bh=WtDQjcQN8asSXHXwzo1/oNs2PkXSeLTZU7UqAwvOo/M=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=uTrsFe+ODiCTdyKnHGw+4wXO9w9t0Uq5ekZgdoFoNp3g15KrnULPcu4hFAcguC1oQ
         F9ftFlu0T1GkVVoJvSN+0J93DRYXIpRrWybCG0dmVpQrZtpU/HPRT+iG1Zz3iW1SBk
         43XDyDhJcI/qZEdwA1GbjkYU93kdUZ9apBb6/7M/8jiC+XMTZHsKUQm/qeJlnxTtNQ
         ZXQFIKDaLIrztxdNa+Jr3chAHQkAzJAokDbrLcw3oSZMrZgBkwc6LIzUzqSbPyfCGA
         gvxx8Al6Q1ts1ChxeIKnwVsHbAYDzAMktnbSTFIoFSJQoaTHFsifRNAO0ZR0Z+cAb0
         iQ2KpQj0Gv7jg==
Subject: Re: [GIT PULL] more nfsd changes for 5.15
From:   pr-tracker-bot@kernel.org
In-Reply-To: <01D391FF-7022-487D-9659-D36AA4947CC0@oracle.com>
References: <01D391FF-7022-487D-9659-D36AA4947CC0@oracle.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <01D391FF-7022-487D-9659-D36AA4947CC0@oracle.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.15-1
X-PR-Tracked-Commit-Id: 0c217d5066c84f67cd672cf03ec8f682e5d013c2
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 14e2bc4e8c40a876c1ab5597320d523c12a97f39
Message-Id: <163114390528.13056.6755936169488437107.pr-tracker-bot@kernel.org>
Date:   Wed, 08 Sep 2021 23:31:45 +0000
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 8 Sep 2021 17:47:14 +0000:

> git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-5.15-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/14e2bc4e8c40a876c1ab5597320d523c12a97f39

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
