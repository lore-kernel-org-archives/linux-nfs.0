Return-Path: <SRS0=mSH2=NZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60396C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Nov 2018 22:55:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 31A412175B
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Nov 2018 22:55:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31A412175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726427AbeKOJAR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Nov 2018 04:00:17 -0500
Received: from mail.kernel.org ([198.145.29.99]:51600 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727321AbeKOJAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Nov 2018 04:00:16 -0500
Subject: Re: [GIT PULL] nfsd bugfixes
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C84072243E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=fail smtp.mailfrom=pr-tracker-bot@kernel.org
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20181113210635.GA23676@fieldses.org>
References: <20181113210635.GA23676@fieldses.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20181113210635.GA23676@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.20-1
X-PR-Tracked-Commit-Id: 025911a5f4e36955498ed50806ad1b02f0f76288
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 4e4490d438a1c84411e3ebd0b850b46dd2e752cf
Message-Id: <20181114225502.6609.82210.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Wed, 14 Nov 2018 22:55:02 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 13 Nov 2018 16:06:35 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.20-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/4e4490d438a1c84411e3ebd0b850b46dd2e752cf

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
