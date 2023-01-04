Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64A46C46467
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Jan 2023 20:17:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239580AbjADURq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Jan 2023 15:17:46 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60944 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235176AbjADURm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2023 15:17:42 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EF337EA0;
        Wed,  4 Jan 2023 12:17:41 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 8BCF36181E;
        Wed,  4 Jan 2023 20:17:41 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id EF3DFC433EF;
        Wed,  4 Jan 2023 20:17:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1672863461;
        bh=bdBgMAZ70NSXqd87jqex/E47m7m/OIGhX0jESFYYbTg=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=F5XH3xS6btqhCVh/Ed+CkoJri+b05hEFnxgyWInHuj8Bh02tt5hTiAWWBG+m+X/vD
         lyyAIgT8RUVXIFMm9obwKbW4DCE92qf00ajzgZO5XW3jrd/ZDG49SZ9/5JwNIyalLX
         wOZetH2MnqackZpdt6UX3CbbxBsq5/tA813FLofK91Hu9ZmhhZ7vppxDbAJriktUzP
         WNT/LOnW0hD12NkxW4BFp8VgRCuTlj2MYgWtZJvnw1Y8IlZPQa59I+mBs4HSWPB8ev
         VwoIFFAKukhMKdthpzURxRO6/haW9SGNrA64G12NRFWKDYbsgyT0jpDcWfdBNc5xgC
         NPaxGThE3ghzw==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id D3B39E57249;
        Wed,  4 Jan 2023 20:17:40 +0000 (UTC)
Subject: Re: [GIT PULL]: first v6.2-rc pull request for nfsd
From:   pr-tracker-bot@kernel.org
In-Reply-To: <CE9B9622-234C-462D-9125-5DDDB00DB9A2@oracle.com>
References: <CE9B9622-234C-462D-9125-5DDDB00DB9A2@oracle.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <CE9B9622-234C-462D-9125-5DDDB00DB9A2@oracle.com>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.2-2
X-PR-Tracked-Commit-Id: cad853374d85fe678d721512cecfabd7636e51f3
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: b61778fa5173021e628b3c9372c9ceae01951b34
Message-Id: <167286346085.24547.5961508170538498439.pr-tracker-bot@kernel.org>
Date:   Wed, 04 Jan 2023 20:17:40 +0000
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 4 Jan 2023 14:58:01 +0000:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.2-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/b61778fa5173021e628b3c9372c9ceae01951b34

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
