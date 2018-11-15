Return-Path: <SRS0=D8Fn=N2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53CE9C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 17:30:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 20EA7223DD
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 17:30:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20EA7223DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388293AbeKPDip (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Nov 2018 22:38:45 -0500
Received: from mail.kernel.org ([198.145.29.99]:41396 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726337AbeKPDip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Nov 2018 22:38:45 -0500
Subject: Re: [GIT PULL] Please pull NFS fixes for 4.20
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 954A521582
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=fail smtp.mailfrom=pr-tracker-bot@kernel.org
From:   pr-tracker-bot@kernel.org
In-Reply-To: <15f600c2e93b3c764a236168e47891c1f46fc2e5.camel@hammerspace.com>
References: <15f600c2e93b3c764a236168e47891c1f46fc2e5.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <15f600c2e93b3c764a236168e47891c1f46fc2e5.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-4.20-3
X-PR-Tracked-Commit-Id: e39d8a186ed002854196668cb7562ffdfbc6d379
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 94ca5c18e1e3742102ba3d054d36f4ee7c71fb7a
Message-Id: <20181115173001.30611.25704.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Thu, 15 Nov 2018 17:30:01 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 15 Nov 2018 00:12:01 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.20-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/94ca5c18e1e3742102ba3d054d36f4ee7c71fb7a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
