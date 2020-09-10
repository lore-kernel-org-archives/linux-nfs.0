Return-Path: <SRS0=2DhQ=CT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC0ECC433E2
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Sep 2020 02:46:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7FE5121D40
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Sep 2020 02:46:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599705983;
	bh=+pELd07/280JmbhhDuSKygrcDaXRXO5RrfpzlIHVRSc=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=2MnlsbIn0O+sLQENnRuGG+cho57ZIxYZPYdum0PIwR8DaIBl2eYXO9na+jipzDLyJ
	 DmQ9f4ZZyV0cAtAVz+MeqBABitXenHftNUpRaeKGxuxEu//DySfTv+vtqOFu2yIfZY
	 qsCfuXu/paKROqs06yz+5XUbE0rK0D/V1mlCawfI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729691AbgIJCAq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Sep 2020 22:00:46 -0400
Received: from mail.kernel.org ([198.145.29.99]:53992 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729913AbgIJBpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Sep 2020 21:45:30 -0400
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 5.9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599697641;
        bh=+pELd07/280JmbhhDuSKygrcDaXRXO5RrfpzlIHVRSc=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=pABgYAD69O9vkBvzgD23PaNjc2UPntZTekQ5XBqrMvZasKIxx2atDqocugjRX4uPk
         JYLlZv6bmwkjGkCt4Gfv4r+PICUjn3BOZDnNOlel+MruyTwVqyqKP7WjKfpfSOlGuF
         1cZkASHeFzmpn34z/ScQbM6xViI2Tn+aC1DyYbZw=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <f96776cef2b96ae904dd7f0c58a96c964cb9a950.camel@hammerspace.com>
References: <f96776cef2b96ae904dd7f0c58a96c964cb9a950.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <f96776cef2b96ae904dd7f0c58a96c964cb9a950.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.9-2
X-PR-Tracked-Commit-Id: 8c6b6c793ed32b8f9770ebcdf1ba99af423c303b
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: ab29a807a7ddaa7c84d2f4cb8d29e74e33759072
Message-Id: <159969764095.607.16894359992610448637.pr-tracker-bot@kernel.org>
Date:   Thu, 10 Sep 2020 00:27:20 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 9 Sep 2020 17:52:01 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.9-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/ab29a807a7ddaa7c84d2f4cb8d29e74e33759072

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
