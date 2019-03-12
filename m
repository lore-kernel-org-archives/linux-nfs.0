Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61B93C10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 22:20:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 314982177E
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 22:20:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552429254;
	bh=MIAc3zjFSFh1c9h72kgD+ZC6df+NZ4mk+0KPZORaagw=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=q2uywcxDSUU8SZ5O3p8VSMilsgfRAMWb0FiYY0fgPkoCT/feT6/D+hRUhzoclIt58
	 soYAhSHA89kIAIoCy5ci3Couw8LEYgKSAYrWCWUUz7soEc4l7n86Bcs0e157CkJ5rT
	 lVlJpmedQ6QuR96qR5OqxYDhbpa9qaPjG69m3SPs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727222AbfCLWUE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 18:20:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:42918 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727204AbfCLWUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 18:20:04 -0400
Subject: Re: [GIT PULL] nfsd changes for 5.1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552429203;
        bh=MIAc3zjFSFh1c9h72kgD+ZC6df+NZ4mk+0KPZORaagw=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=QEJgWuHCEXfYEo6TfN7XDBde13FYTbgFPs1qFN4X0N/YbEMdxnGwZj56QiBQ9RbfA
         u+k/7xAoIGe05r4hd4kwitTNPqgK/Oeoxq4lwfE2U9Y3j3ZM9k3SK7418chwRmptn0
         uTVVz07PuOxTWOO9YT9/9tx85IkWUas4QDYX3L2g=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20190312182359.GC29990@fieldses.org>
References: <20190312182359.GC29990@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190312182359.GC29990@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1
X-PR-Tracked-Commit-Id: f875a792abe933d0b4553ab6e29c624b58932e41
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ebc551f2b8f905eca0e25c476c1e5c098cd92103
Message-Id: <155242920353.11942.2084394519671859939.pr-tracker-bot@kernel.org>
Date:   Tue, 12 Mar 2019 22:20:03 +0000
To:     bfields@fieldses.org (J. Bruce Fields)
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 12 Mar 2019 14:23:59 -0400:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ebc551f2b8f905eca0e25c476c1e5c098cd92103

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
