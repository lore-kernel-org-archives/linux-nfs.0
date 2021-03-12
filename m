Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E7AC433E6
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Mar 2021 22:26:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 556C264F5F
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Mar 2021 22:26:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235469AbhCLWZm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Mar 2021 17:25:42 -0500
Received: from mail.kernel.org ([198.145.29.99]:52154 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S235529AbhCLWZh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Mar 2021 17:25:37 -0500
Received: by mail.kernel.org (Postfix) with ESMTPS id 6975F64F5E;
        Fri, 12 Mar 2021 22:25:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1615587937;
        bh=c5626PkGoJoyJZCO+jd67VofuyjDwRm2obPYVjDaLqw=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=u7Yo7eZdzvDcL3w4ux+SdLdPgdBA95MmZyVg0kj6JOsnlncNZABr9pNATSpQcyqIo
         To6oyJ5NbR7ADWT/cnlEDUXT3xLl4gr5r1oJlFL5xxRXivmmX2hSZVHCd5hgvRdmR4
         wy44OAN6DNhJRbkQ6gXH/acxs/Sk/oTzPLSIYwx7V0iR4m0T3E9lxswf6OUQfCPkW3
         B2dSmnJQZRnhqmNOT/Taoex+y3Nb/grK390l+S7Q3/btZZYsbPDLAO6gUNit8Kz/w2
         9/xUbnZAeyN1Kh/nIIXDNDeFOuD98myM+IGK4B/ZEBrSIB7K1Q5T9HmAivcN4OTADL
         fy23RlP244OeA==
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for 5.12-rc3
From:   pr-tracker-bot@kernel.org
In-Reply-To: <CAFX2Jfks7yEAs9xhG-9Znwzzmiz8JpRQv9XDpOAEM=EaxhiEpA@mail.gmail.com>
References: <CAFX2Jfks7yEAs9xhG-9Znwzzmiz8JpRQv9XDpOAEM=EaxhiEpA@mail.gmail.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <CAFX2Jfks7yEAs9xhG-9Znwzzmiz8JpRQv9XDpOAEM=EaxhiEpA@mail.gmail.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.12-2
X-PR-Tracked-Commit-Id: 4f8be1f53bf615102d103c0509ffa9596f65b718
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f296bfd5cd04cbb49b8fc9585adc280ab2b58624
Message-Id: <161558793727.5966.2318231053158541850.pr-tracker-bot@kernel.org>
Date:   Fri, 12 Mar 2021 22:25:37 +0000
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 12 Mar 2021 15:28:44 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.12-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f296bfd5cd04cbb49b8fc9585adc280ab2b58624

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
