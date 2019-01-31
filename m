Return-Path: <SRS0=SG1H=QH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B01DFC169C4
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 19:30:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 83E0620B1F
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 19:30:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548963008;
	bh=aH/Ge/8zu6Aie/nhe/RC6/jzPGYYhU7ZQrf/xmXrJLQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=aRqDCZMSI3kgwex6KIAOxDyrqVGI3+DSS/aWuVssVFEa5txPApZkKaCk1KHUYrXi8
	 c4ZJ8TJjQ78J823bz/6JKcE1grzTzEAU7stEqoMP8URcNXysPoTEljoaqghTzCsGI7
	 TPv8fGyyBoTAsjkM/sAubs/85vl68xXuLGt97nKk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726410AbfAaTaD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Jan 2019 14:30:03 -0500
Received: from mail.kernel.org ([198.145.29.99]:53624 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725854AbfAaTaC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 Jan 2019 14:30:02 -0500
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for 5.0-rc5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548963002;
        bh=aH/Ge/8zu6Aie/nhe/RC6/jzPGYYhU7ZQrf/xmXrJLQ=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=PdLX3399i/A4LV6mhTNaSK8TzAFuFgveKcyXDbna5PP6qvg9q3r8CaV1u8sPncTYF
         wNBcdEquWKP283WwHnGObu2b5W7yOm3v1a3W0piilYyWZfg3z9tG/d28Zftp0DYjE7
         f2/z/Ll4KN+249Jn81IovPvy4wc3xFNNOAHZ/9zM=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <c00eb546108828e6f73a2aeca5efd041f66593a1.camel@netapp.com>
References: <c00eb546108828e6f73a2aeca5efd041f66593a1.camel@netapp.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <c00eb546108828e6f73a2aeca5efd041f66593a1.camel@netapp.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git
 tags/nfs-for-5.0-3
X-PR-Tracked-Commit-Id: 8fc75bed96bb94e23ca51bd9be4daf65c57697bf
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 937108b093f74ed8ae4fed21ee215bcb773e2781
Message-Id: <154896300209.28776.1784534521254971241.pr-tracker-bot@kernel.org>
Date:   Thu, 31 Jan 2019 19:30:02 +0000
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 31 Jan 2019 18:12:24 +0000:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.0-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/937108b093f74ed8ae4fed21ee215bcb773e2781

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
