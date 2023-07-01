Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5648EB64DD
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Jul 2023 05:05:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229773AbjGAFFX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Jul 2023 01:05:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59372 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231136AbjGAFFI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Jul 2023 01:05:08 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B5FD144B9;
        Fri, 30 Jun 2023 22:04:59 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 47B1D60F05;
        Sat,  1 Jul 2023 05:04:59 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id B0D41C433CA;
        Sat,  1 Jul 2023 05:04:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688187898;
        bh=gSb0hU1xbPgI+J/q4edKZETVkPJjz7G4+ZenLrfqjko=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=E3Q9j0QmAW9Amdc9PCovbidNTm/kh4bm3LKXO4UGf9w3Pvw6M4u10kP9yctrQZzdb
         psx4I+5l7oHYhzYNMHFsyJQ3CtQaD13udcGmS+R75ymaLrxkYuUxBq4LQCU90WlPkt
         v+QIfu0xao5uvfMjQZ3dWjDGZJgxdzlkXjAs38Ign5VjhQqWdpY9HI/Z+u9fy8wxCk
         KMmJKBz2pgM60HxdY8/BmQpfNFedG9GawmB5d4zMhNU3wwSKOP/UvnerC0x4sFnQ6e
         26EKasD3D13BulnLzTTy+yvrJtsyBJD2/03josthel6BI2leXn3Egp4gbafrVQEOa/
         tE5PJ1BGC+LGg==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id A05B0E5381B;
        Sat,  1 Jul 2023 05:04:58 +0000 (UTC)
Subject: Re: [GIT PULL] nfsd fixes for v6.5
From:   pr-tracker-bot@kernel.org
In-Reply-To: <FFAD650F-18C4-4C2A-9BEB-2C18A8FE94C6@oracle.com>
References: <FFAD650F-18C4-4C2A-9BEB-2C18A8FE94C6@oracle.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <FFAD650F-18C4-4C2A-9BEB-2C18A8FE94C6@oracle.com>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.5-1
X-PR-Tracked-Commit-Id: d7dbed457c2ef83709a2a2723a2d58de43623449
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ee152be17ade10e8667ffa02de828bb955c40813
Message-Id: <168818789865.30776.11196149907975886735.pr-tracker-bot@kernel.org>
Date:   Sat, 01 Jul 2023 05:04:58 +0000
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 30 Jun 2023 17:46:51 +0000:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.5-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ee152be17ade10e8667ffa02de828bb955c40813

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
