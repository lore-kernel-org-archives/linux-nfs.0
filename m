Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C099C433F5
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Feb 2022 22:45:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1387355AbiBHWo5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Feb 2022 17:44:57 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50928 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1387753AbiBHWon (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Feb 2022 17:44:43 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 79FCDC036E78;
        Tue,  8 Feb 2022 14:30:09 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 0F46E61670;
        Tue,  8 Feb 2022 22:30:09 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 6D995C004E1;
        Tue,  8 Feb 2022 22:30:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1644359408;
        bh=5mK1sIwo3HiAlMNdYt8rRyTSsZTzR8VZH5shT7+53tM=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=DuxQFoFqfVPNokJpF7GfLm/axnIASF+Fl90hDxomGXXy5Q8mhNNx5e9AcQUnpYFCB
         Qw0FBlxqsCfH4+UeU1/FCUytRKDn6Ozf+9y/6Svn9W4MC1zaZLHi81GtL+F4TXp8tV
         bZ/8Ko4qh2+877lkHIAza3Phe73nxX8JjXF6aYXCc8nUd4tZKYlbGGt9Hw3V5f1l1B
         ovelE1ojc7K9uC8cPfcF4K4DASKIv2dshb+Nff0fsA5U493t2Sc0nWZgOxiPg8oUFW
         9kntkvYA3Y+Cqtg12QKxcTATkqU5vR5toOoAG/XREcHeF3IoUBn60P1/EFiDqKmiPS
         clP7PmLMDYWcQ==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 4E45DE6BB76;
        Tue,  8 Feb 2022 22:30:08 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Bugfixes for Linux v5.17-rc
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20220208194800.482704-1-anna@kernel.org>
References: <20220208194800.482704-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20220208194800.482704-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.17-2
X-PR-Tracked-Commit-Id: b49ea673e119f59c71645e2f65b3ccad857c90ee
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: e6251ab4551f51fa4cee03523e08051898c3ce82
Message-Id: <164435940826.4939.4641399298325219796.pr-tracker-bot@kernel.org>
Date:   Tue, 08 Feb 2022 22:30:08 +0000
To:     anna@kernel.org
Cc:     torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue,  8 Feb 2022 14:48:00 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.17-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/e6251ab4551f51fa4cee03523e08051898c3ce82

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
