Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A39E8C4361B
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 00:12:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6E3A523D56
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 00:12:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728519AbgLKAMI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Dec 2020 19:12:08 -0500
Received: from mail.kernel.org ([198.145.29.99]:41844 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731044AbgLKALn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Dec 2020 19:11:43 -0500
Subject: Re: [GIT PULL] Please pull a few more NFS Client bugfixes for 5.10
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1607645463;
        bh=NWdDQcavlZHR3VnrSnJOcEFjoJmRR7JWvv9l4PPTKK0=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=qHLFG+TDN0PGRPECiK0O+kvrbwzG8fiBhOOrt4pSuLnoCVJPCxIZix72yB4t24LK/
         ySryV09dpgO8iXb++CdKcFQrUTzhACBfgzrf6nsjn0LnXAayLnsuruiBXAdBb/ZTeI
         9/XaQPWJdCp4NcWyjCPeWpMEHoSoKNhq2f2AJ0rEXDcGMLIpXArWQbpNi/2lNB0G/i
         Q3CecHgRwjMEyfdwtaMcoSZlq3GjMGnSy3eLHT4xxA9Wa+F0UjoTtTwvyfHBPMbzUZ
         X578ywq12o/zGQ9NPtbOPml6FQmdErLg/ChjYPDAwiUWtYVAzCBCz1O0vcvqodxHf0
         blAXzxr55lk6w==
From:   pr-tracker-bot@kernel.org
In-Reply-To: <CAFX2JfmhOBA6n9P_hJK1AbEUD3-k5wP8a9oeWUEZ56E2trQw5g@mail.gmail.com>
References: <CAFX2JfmhOBA6n9P_hJK1AbEUD3-k5wP8a9oeWUEZ56E2trQw5g@mail.gmail.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <CAFX2JfmhOBA6n9P_hJK1AbEUD3-k5wP8a9oeWUEZ56E2trQw5g@mail.gmail.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.10-3
X-PR-Tracked-Commit-Id: 21e31401fc4595aeefa224cd36ab8175ec867b87
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 6840a3dcc2447188e7bb8464b31a7620bc4423ee
Message-Id: <160764546335.19993.5568351213696257743.pr-tracker-bot@kernel.org>
Date:   Fri, 11 Dec 2020 00:11:03 +0000
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 10 Dec 2020 16:57:17 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.10-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/6840a3dcc2447188e7bb8464b31a7620bc4423ee

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
