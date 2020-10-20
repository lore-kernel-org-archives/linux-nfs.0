Return-Path: <SRS0=zkC/=D3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB785C388F2
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 22:01:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 64BFB2224A
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 22:01:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603231269;
	bh=bfvW5CJ+Dvsog6QgaelPdcXCjo+UyYF3TNk8KIsmeOQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=Fjf/VybbPfgOLKDh4TpMTDpoYQYyMaXjbCRHZ08LfCJnDu6wHILRIGzch3vSEO9xE
	 CvWg+cvs6lMXrs/w87KTB8ilXhgVBMeniBhj2oBIgGvk8iNuID/3GLOPT+k2JyjbxZ
	 zwSoxlF9YSUisIeFR0be1NTE6FBEQSCC3h1BzdOk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2393074AbgJTWBF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Oct 2020 18:01:05 -0400
Received: from mail.kernel.org ([198.145.29.99]:57566 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2392670AbgJTWBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Oct 2020 18:01:04 -0400
Subject: Re: [GIT PULL] Please pull NFS Client Updates for v5.10
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603231264;
        bh=bfvW5CJ+Dvsog6QgaelPdcXCjo+UyYF3TNk8KIsmeOQ=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=FGNHBDJU1PvJZL/iv5zZt17eARgg33Ton0yzaTDa3PO3w7jCggoAo/jFUmh2xMjAa
         Poy5W2CjSQ4k7SFY+mfmoQtoQh6k/K1iyo3GlN6wxP+xoS1nBBS43DcQWbyyyi14M4
         NmrSWHKKds9K2fOpEO7VLCWmPY1aQIwfLLoPdEsg=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <CAFX2JfnGTLccrN4x2FB_m8v+_gJNXCYFfQf=O50mfouiCd+Vsg@mail.gmail.com>
References: <CAFX2JfnGTLccrN4x2FB_m8v+_gJNXCYFfQf=O50mfouiCd+Vsg@mail.gmail.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <CAFX2JfnGTLccrN4x2FB_m8v+_gJNXCYFfQf=O50mfouiCd+Vsg@mail.gmail.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.10-1
X-PR-Tracked-Commit-Id: 8c39076c276be0b31982e44654e2c2357473258a
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 59f0e7eb2f9ffa7715ca95908797b52ba35af11a
Message-Id: <160323126398.2890.17389048433911822002.pr-tracker-bot@kernel.org>
Date:   Tue, 20 Oct 2020 22:01:03 +0000
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 20 Oct 2020 14:55:52 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.10-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/59f0e7eb2f9ffa7715ca95908797b52ba35af11a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
