Return-Path: <SRS0=eDyf=BZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=BAYES_00,DATE_IN_PAST_06_12,
	DKIMWL_WL_HIGH,DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A4A5C433E1
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Aug 2020 21:50:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 348982053B
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Aug 2020 21:50:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1597528239;
	bh=LgBcMaRyW+AVbLf2prUcxTuvuv5Ha8CMganX6JOCQmM=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=X4s0JB1FxIzd9pRsTq6BmXqVqdhSKUTiVfVot6p6b7I5SI8PMkMYv1E8eofULa8s6
	 Gka39SZ8nytVYX/eUl15HGAAaUlqVYEHlIROgyz6LW21QGPvUDrNs2XobRHMkH9j3J
	 AiYRHXctzaTj5yhwwqneSnrH9LULT65hVYfw9wr0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727973AbgHOVu0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 15 Aug 2020 17:50:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:57686 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726135AbgHOVu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 15 Aug 2020 17:50:26 -0400
Subject: Re: [GIT PULL] Please  pull NFS client updates for Linux 5.9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1597505992;
        bh=LgBcMaRyW+AVbLf2prUcxTuvuv5Ha8CMganX6JOCQmM=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=jSg9VIaEH2OFpJhgRu54QWc8aPc5FjjxvjveySCF81dNmI3Yd4kKS3HAUE1lzadGX
         BBANiC+pHrtPMa9/Q7gfHQRJW7tAXsXywGaaeRI23wwklz9GGpJgp9akuns1wnXcA6
         zryfJkkadKzbk0qFMrySEYJjTdfxZj182NitIaJE=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <480e5d764e343f576a3ecb1a2ff4165e3f66d7ed.camel@hammerspace.com>
References: <480e5d764e343f576a3ecb1a2ff4165e3f66d7ed.camel@hammerspace.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <480e5d764e343f576a3ecb1a2ff4165e3f66d7ed.camel@hammerspace.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.9-1
X-PR-Tracked-Commit-Id: 563c53e73b8b6ec842828736f77e633f7b0911e9
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 37711e5e2325535bf094bdc0a66790d659b52d5b
Message-Id: <159750599254.19697.4139931966515071544.pr-tracker-bot@kernel.org>
Date:   Sat, 15 Aug 2020 15:39:52 +0000
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 14 Aug 2020 22:04:02 +0000:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-5.9-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/37711e5e2325535bf094bdc0a66790d659b52d5b

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
