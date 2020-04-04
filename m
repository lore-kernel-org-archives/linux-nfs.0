Return-Path: <SRS0=LGQD=5U=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 599DCC2BA18
	for <linux-nfs@archiver.kernel.org>; Sat,  4 Apr 2020 18:30:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2FE2F206F8
	for <linux-nfs@archiver.kernel.org>; Sat,  4 Apr 2020 18:30:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586025007;
	bh=uPe5fXDEDxZJHbTQSWW9Ir/NCaduyI5osdiHbBQzmYs=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=fnfiTmGNMzxATdVP/5jD+t8OXxOke9XcpgpV63Aiz9dDQN6IN3SdAGVikVxneL8nI
	 pCqtcmgYULwMqGuG5yj5gwNgCdaDRKpJC3oM2VEsv+qlusMfWY905cf/oU2sA9ahuS
	 T+fZhvsLz/LjsYk3PR8U6rijQ1R0APVX7RATIm2U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726225AbgDDSaE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 4 Apr 2020 14:30:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:53482 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726222AbgDDSaE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 4 Apr 2020 14:30:04 -0400
Subject: Re: [GIT PULL] Please pull NFS server updates for 5.7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586025003;
        bh=uPe5fXDEDxZJHbTQSWW9Ir/NCaduyI5osdiHbBQzmYs=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=O306tva+Achc9IHvDYURcgr8zC5r0KcHnSbViHgQS30dR0SXFGm0jhECrNlyEQnlE
         jXeKFbPZzk9Cb5jmSCpJ7grkJcoOVMNw1Eh9nD85cDb0vA/kcKFySfDjLqJb+l0mPo
         ZD0BA3LvPE1luTJf3IA89KHLpESUJmGCg6RO4H3U=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <E69B987A-7E11-4321-8812-EBC2EE4F07E0@oracle.com>
References: <E69B987A-7E11-4321-8812-EBC2EE4F07E0@oracle.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <E69B987A-7E11-4321-8812-EBC2EE4F07E0@oracle.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/cel/cel-2.6.git
 tags/nfsd-5.7
X-PR-Tracked-Commit-Id: 1a33d8a284b1e85e03b8c7b1ea8fb985fccd1d71
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: b3d8e4228268f9cfacc2e88aa61b6d0ce776e207
Message-Id: <158602500331.10407.10387518390265819881.pr-tracker-bot@kernel.org>
Date:   Sat, 04 Apr 2020 18:30:03 +0000
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 3 Apr 2020 10:09:21 -0400:

> git://git.linux-nfs.org/projects/cel/cel-2.6.git tags/nfsd-5.7

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/b3d8e4228268f9cfacc2e88aa61b6d0ce776e207

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
