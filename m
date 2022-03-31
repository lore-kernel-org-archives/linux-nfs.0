Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4993C433EF
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Mar 2022 23:22:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242963AbiCaXYl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Mar 2022 19:24:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51594 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S242937AbiCaXYh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2022 19:24:37 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A9E5D5C353;
        Thu, 31 Mar 2022 16:22:49 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 5C2C2B82297;
        Thu, 31 Mar 2022 23:22:48 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id EDC5BC340ED;
        Thu, 31 Mar 2022 23:22:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1648768967;
        bh=cFAMfnRYRwexlQ80k5xK4/bktdJv0fyhc/nvasOcLSo=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=pTcM+bxBZsVhEHBrY6ebu5Cmk1+aCXLsOgWp/mU2iRlmn57LuxoT7dzpXi9j5fAvD
         CIaUqPpOMCUXBffm2HoFE6HC46X9o2R40nzA4yU6Af5l56QBJUKWRl1RciX8DFAg2Z
         xlTV0sOIhiHR05VPVfdbgYMf6ugOdwJZOkdk3qiA2P6NG2wcTRpYK+PhBa8XupZ7am
         MNlnvupN2x8gNOeAF5RuVUoRIoETnY4RuO28YZMkfpQEPP9CGF1hXZRkWOUoRP1Wd1
         lJr8tCu8ivfq6ga8dP5t2DEJkMILo0M4DDaAFHvhFcwtNHIYtZrHNi9Z23HKk0oHnn
         bXEQbw+m+CCkg==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id D7C76E7BB0B;
        Thu, 31 Mar 2022 23:22:46 +0000 (UTC)
Subject: Re: [GIT PULL] netfs: Prep for write helpers
From:   pr-tracker-bot@kernel.org
In-Reply-To: <2639515.1648483225@warthog.procyon.org.uk>
References: <2639515.1648483225@warthog.procyon.org.uk>
X-PR-Tracked-List-Id: <linux-cifs.vger.kernel.org>
X-PR-Tracked-Message-Id: <2639515.1648483225@warthog.procyon.org.uk>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/netfs-prep-20220318
X-PR-Tracked-Commit-Id: ab487a4cdfca3d1ef12795a49eafe1144967e617
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f008b1d6e1e06bb61e9402aa8a1cfa681510e375
Message-Id: <164876896687.28012.3947884678367341659.pr-tracker-bot@kernel.org>
Date:   Thu, 31 Mar 2022 23:22:46 +0000
To:     David Howells <dhowells@redhat.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        David Wysochanski <dwysocha@redhat.com>,
        Dominique Martinet <asmadeus@codewreck.org>,
        Ilya Dryomov <idryomov@gmail.com>,
        Jeff Layton <jlayton@kernel.org>,
        Jeffle Xu <jefflexu@linux.alibaba.com>,
        Steve French <sfrench@samba.org>, ceph-devel@vger.kernel.org,
        dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-cachefs@redhat.com, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Mon, 28 Mar 2022 17:00:25 +0100:

> git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/netfs-prep-20220318

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f008b1d6e1e06bb61e9402aa8a1cfa681510e375

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
