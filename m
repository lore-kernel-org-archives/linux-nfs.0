Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1671C43381
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 01:50:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFF90222E6
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 01:50:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550368203;
	bh=aYLTw3M/b7vK452KurMRJGtigUUJ9LJ72I58w224LA4=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=kPpdJdC1EXPY0nBnVYLfJ1asr7kavbZdGF1tIQmjU5egkpJ8pRZwPhJCTShf+PeJw
	 UZrINKxgViLC1Jgw4tO1CeFJKhaVhscKWo9rETbfjL7IDr1tAw8PL/JZ0MF0eS7TUM
	 iHjy478l7oM51f8Pw+/9KQghiFhjfT3ha0327HUk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728031AbfBQBuC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Feb 2019 20:50:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:56714 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727188AbfBQBuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Feb 2019 20:50:02 -0500
Subject: Re: [GIT PULL] Please pull additional NFS client fixes for 5.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550368202;
        bh=aYLTw3M/b7vK452KurMRJGtigUUJ9LJ72I58w224LA4=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=vTYiKBtt2MGCOvZbCGyb3nfpjSlxgYv5W6cpxp3EWmaMItxGzQZ+IFGZXwPGt5kp5
         itwfMhLLYGlYkUOzSCwkJTnrUMRFtLvva5NcXbq2MY/RDnJ8vCfQW/ZmQCvxB/L/h9
         JUL5ucM7z8GLfq4g2qCCLHpSV16CpudTcaWFEFgg=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <39718a97aca3b96d016069ea46371b193f8ac41a.camel@gmail.com>
References: <39718a97aca3b96d016069ea46371b193f8ac41a.camel@gmail.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <39718a97aca3b96d016069ea46371b193f8ac41a.camel@gmail.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git
 tags/nfs-for-5.0-4
X-PR-Tracked-Commit-Id: d2ceb7e57086750ea6198a31fd942d98099a0786
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 55638c520bb7b92999b6f0867ba135b6aeafc8d7
Message-Id: <155036820201.25738.17626274520337163226.pr-tracker-bot@kernel.org>
Date:   Sun, 17 Feb 2019 01:50:02 +0000
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 15 Feb 2019 16:47:50 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.0-4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/55638c520bb7b92999b6f0867ba135b6aeafc8d7

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
