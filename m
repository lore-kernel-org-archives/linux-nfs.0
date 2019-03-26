Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD8F2C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:25:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 77EAE208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:25:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553639103;
	bh=aUULyc+DiuHrD+5Kdvg4BctRjE9mcqkfZX20gIdKojE=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=rutv0NOGZUlRxK9ljErB2Fp+MXQEZf0+KNwJGN7GgBw3k/R9uyiXmxHLgyhGKuTNu
	 PwFszkKDvjhDAXxaqOqK9s1z1J3KuzrSPZGTJb3lNZY7g+J/APjP6e4MFWZDhjzZUq
	 J4xYjGSlaBHeVo7hegAGyY0SeVdAwHM/2xUek6yk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731824AbfCZWZC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:25:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:39720 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726782AbfCZWZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:25:02 -0400
Subject: Re: [GIT PULL] Please pull NFS client fixes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1553639102;
        bh=aUULyc+DiuHrD+5Kdvg4BctRjE9mcqkfZX20gIdKojE=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=FOy2P7QC9vyly/7Q1XLKtGa/P6IgIa0Z+ThyWs6O1WwHVcrTFHiUWd+yqu4bPOdd9
         3U/WLAzEgJfOWU7gwxwLFxeCHsNF/0cUU1kAKqJcxBz8EoVF60gi2lYZLqMPvHrRsx
         tUjBhWfTM53PZcGyxZ9fR998AuLwLjwbMy1t7Zys=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <938c564de7930769feacf1403fae0c9511f10993.camel@hammerspace.com>
References: <938c564de7930769feacf1403fae0c9511f10993.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <938c564de7930769feacf1403fae0c9511f10993.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-5.1-3
X-PR-Tracked-Commit-Id: 01f2f5b82a2b523ae76af53f2ff43c48dde10a00
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 14c741de93861749dfb60b4964028541f5c506ca
Message-Id: <155363910207.25306.7118243450185118149.pr-tracker-bot@kernel.org>
Date:   Tue, 26 Mar 2019 22:25:02 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 26 Mar 2019 20:12:07 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.1-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/14c741de93861749dfb60b4964028541f5c506ca

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
