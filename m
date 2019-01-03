Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F5BC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:40:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 518522073F
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:40:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546483210;
	bh=Sl6BCeXr/VA4tT6xtRGmdMzJMf4MmLeNKsEXXXy5q+s=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=l7bFsbHs+P3RW1lankZXrDBvV59pW/1CL0Q5MU3dI4KRQzWfYrRMCLVRgeku4ZGIF
	 pnPobnNQS/9Nm+BVD9xiDciWbLlSo6dBNns0HOGtIZzfWBCw13uGZtt3lb2m+BkTrZ
	 fP08ILE89BlNAf8g1P3s+1gIQIEftmNfXkRz5+iw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727193AbfACCkE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 21:40:04 -0500
Received: from mail.kernel.org ([198.145.29.99]:43750 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726511AbfACCkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 21:40:03 -0500
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1546483203;
        bh=Sl6BCeXr/VA4tT6xtRGmdMzJMf4MmLeNKsEXXXy5q+s=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=fG7oSIdBjX1cDtTDiN+O6nKC4/fBfAizM3YTpORKooo4cS5jw5LodzJl8KBPSedTz
         KEQgNihQ1ps9+8Komr9TiHE3XL3akYV5V0gih+WRUI8u+yww/AwyhUr6MUKbTMTHsL
         87Wk6qhLwcUo8ccGN68Cyb1xsHuv80AeAHGXm45s=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git
 tags/nfs-for-4.21-1
X-PR-Tracked-Commit-Id: 260f71eff493a844531629854c0935fa8de4fa2c
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: e6b92572808467f35fd159d47c45b650de29e722
Message-Id: <20190103024003.21791.56761.pr-tracker-bot@pdx-korg-gitolite-1.ci.codeaurora.org>
Date:   Thu, 03 Jan 2019 02:40:03 +0000
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 2 Jan 2019 22:42:32 +0000:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.21-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/e6b92572808467f35fd159d47c45b650de29e722

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
