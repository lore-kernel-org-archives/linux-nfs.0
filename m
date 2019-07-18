Return-Path: <SRS0=m0dU=VP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 027BCC7618F
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jul 2019 22:05:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CD283208C0
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jul 2019 22:05:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563487504;
	bh=rUvVwMOGVvwHJEFb04d80CXK8AzKdzd6WN36agDK2TM=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=lMPxAj/BFmOb3SCSSER4/jvFT4njUFwRw/pWw55t7TX6ZL+p5T9JoO/Y4vNaaQ91v
	 /9fiUZ2xrCnsI1hKhQTGyEVteoV8vfe3U+xba+J//IssMddvvPtlJqSA9r57BFGJEM
	 2tX5XvkQAhlqzsNFhU/lZu56FQeqYc8BDCFAwaxo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727972AbfGRWFD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Jul 2019 18:05:03 -0400
Received: from mail.kernel.org ([198.145.29.99]:58972 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727781AbfGRWFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Jul 2019 18:05:03 -0400
Subject: Re: [GIT PULL] Please pull NFS changes for Linux 5.3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1563487502;
        bh=rUvVwMOGVvwHJEFb04d80CXK8AzKdzd6WN36agDK2TM=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=d/NNeceKCm7/vv8qgpFi4jIcSARN9avRk3RKjBsQgOmQZjPhcoUduVis+Rc6e12ob
         tcQMIzELQuCcABgTXZJEZ1yB06POyFp5U9IyJBj6M81DtWxDhNs50jiP7pwCCqK5Ym
         jagJDYAc14yOkS/0R+EK5CSZb9U831Isl3zit84I=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <333e896cf5bcadd8547fbe4a06388dd3104ff910.camel@hammerspace.com>
References: <333e896cf5bcadd8547fbe4a06388dd3104ff910.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <333e896cf5bcadd8547fbe4a06388dd3104ff910.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 tags/nfs-for-5.3-1
X-PR-Tracked-Commit-Id: d5b9216fd5114be4ed98ca9c1ecc5f164cd8cf5e
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 6860c981b9672324cb53b883cfda8d2ea1445ff1
Message-Id: <156348750270.19422.2209425718859448669.pr-tracker-bot@kernel.org>
Date:   Thu, 18 Jul 2019 22:05:02 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Thu, 18 Jul 2019 20:25:03 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.3-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/6860c981b9672324cb53b883cfda8d2ea1445ff1

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
