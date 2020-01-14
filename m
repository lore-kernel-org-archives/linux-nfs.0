Return-Path: <SRS0=2DWu=3D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 488D9C33C9E
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Jan 2020 21:55:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 19D0C24658
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Jan 2020 21:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579038903;
	bh=zOSg2WCOVpe+aAEklnKX/2mo3OLawgvqqcKIABLB7d4=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=UxgVNhw9H57PAVLrBiQqKciWPK4Yayy7CFGYZkWte1SIhgZL/mR0WYNjxMQ3EOZgR
	 Qj29HPtIX7IyL2ukm0sHk253zZh0ni+EWKFG+mHe7YqYE1DJrnQJsX5l7yYbQOL6Kv
	 K45zXytUivr/5mec7C+iaOCBkuqLUBfu87xUf2EI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727072AbgANVzC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 14 Jan 2020 16:55:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:47820 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726491AbgANVzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Jan 2020 16:55:02 -0500
Subject: Re: [GIT PULL] Please pull NFS over RDMA fixes for 5.5-rc7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579038901;
        bh=zOSg2WCOVpe+aAEklnKX/2mo3OLawgvqqcKIABLB7d4=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=J8Z2jL4xVLdJNayAgt1ql7AzJZxYWl2RhZw42KxMkb49t+PTp9tQ+rQLs+cMLK4qR
         3E7Ly0+xqkGI/tJSRt7fOgcc+nly7Lq/u4OIaHeyuXR4Hu7O9PCqkmx7FLi7VzEkBb
         bqnEN+SKDoRPhWvgZn+/C0e4ELm0utqT0QFFgvqY=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <e85791e49b772b5641b65c09b75fad4cee62218b.camel@netapp.com>
References: <e85791e49b772b5641b65c09b75fad4cee62218b.camel@netapp.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <e85791e49b772b5641b65c09b75fad4cee62218b.camel@netapp.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git
 tags/nfs-for-5.5-2
X-PR-Tracked-Commit-Id: 671c450b6fe0680ea1cb1cf1526d764fdd5a3d3f
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 95e20af9fb9ce572129b930967dcb762a318c588
Message-Id: <157903890169.2883.16329569388665062116.pr-tracker-bot@kernel.org>
Date:   Tue, 14 Jan 2020 21:55:01 +0000
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 14 Jan 2020 21:12:56 +0000:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.5-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/95e20af9fb9ce572129b930967dcb762a318c588

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
