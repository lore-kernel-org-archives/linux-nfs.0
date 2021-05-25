Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C898C47084
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 17:36:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 52E6B61423
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 17:36:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233595AbhEYRiE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 May 2021 13:38:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:59956 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234125AbhEYRhx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 May 2021 13:37:53 -0400
Received: by mail.kernel.org (Postfix) with ESMTPS id D808E61157;
        Tue, 25 May 2021 17:36:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1621964182;
        bh=LskCapKtyB8RvSvFDfob6jRHdNLRDzxTgT9OF4bwRiI=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=Ny9MBHfnFRBWDZ5MaAeHH23HUW1HtoA9ZG0uLesxIxrOzDxzq5Gadxv2HQz/Yhqh0
         pusvJG8wsNSJq0TglpUrg1uQbQmSGfZ4dnLomTqhchJRsIYOQF7LMUGyvDx71bWGa5
         PETGfYUjgVBZiAog9xmPRfGhn/0IDwEYA4LEisITlNPo9vN/0Mp/RI/nqE/Ejxzkcm
         oCK0BqSAQr6i5ety5eL3kWRNgq7DGhnSgtra3Sch8HOHDbBeAc31ruhd1S+rOyx9/N
         cX/pi3MeCA4BSGwcfwDcjuUA+DiO9bvQkVYAqCGHHYtkzymrl8QwzqKS7x/rDi+whW
         vGZhk8ikkDIww==
Subject: Re: [GIT PULL] netfs: Fixes
From:   pr-tracker-bot@kernel.org
In-Reply-To: <4007708.1621947662@warthog.procyon.org.uk>
References: <4007708.1621947662@warthog.procyon.org.uk>
X-PR-Tracked-List-Id: <ceph-devel.vger.kernel.org>
X-PR-Tracked-Message-Id: <4007708.1621947662@warthog.procyon.org.uk>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/netfs-lib-fixes-20200525
X-PR-Tracked-Commit-Id: b71c791254ff5e78a124c8949585dccd9e225e06
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ad9f25d338605d26acedcaf3ba5fab5ca26f1c10
Message-Id: <162196418275.15660.9511112826045891745.pr-tracker-bot@kernel.org>
Date:   Tue, 25 May 2021 17:36:22 +0000
To:     David Howells <dhowells@redhat.com>
Cc:     torvalds@linux-foundation.org, dhowells@redhat.com,
        geert@linux-m68k.org, willy@infradead.org,
        ceph-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cachefs@redhat.com, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 25 May 2021 14:01:02 +0100:

> git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/netfs-lib-fixes-20200525

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ad9f25d338605d26acedcaf3ba5fab5ca26f1c10

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
