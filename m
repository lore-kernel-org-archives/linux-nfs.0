Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E8A7C433F5
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Jun 2022 00:06:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1348795AbiFAAGr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 31 May 2022 20:06:47 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38542 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1348796AbiFAAGq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2022 20:06:46 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 98AC4F6D
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2022 17:06:42 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 4CA8AB80FAF
        for <linux-nfs@vger.kernel.org>; Wed,  1 Jun 2022 00:06:41 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 19B1AC385A9;
        Wed,  1 Jun 2022 00:06:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1654042000;
        bh=Qb+eJqcyNMkPnYnCaszfdVSeSE94RHh+nZPXnbnzeuw=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=f2+SzLjiMsmC/Od6Dr3SZXQn86e8OOSC3gfEbVS7b1wSZhAJNhehcsgwi1m3QiuNi
         ynzRIqnNOGpBKRwq1PxDvzFGDPJ1w3BFjcUjIEgvyFL//I8VTJO8ZpOIYqNYxu4FGN
         ufITSd6/Z9hc6137OhvWJYBTgWIh3020O876k0Ra0kEFLc+LS6kAAa5gwcKI0UA8pu
         IAPcqfBQzIrd9Ey5lWwBBX7By6R+oqInXqjBwxp3fDXpbXW7Oa+TKR4tuJMQdR5lRE
         QqcbX1zb8lGbPfDBLPmoTbX71tr+/rRyPJwfWxEyJHC/p93/rzXtLyIRu5Vm9ZSYXA
         EBrcLzbixWLTw==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id EC4E1F03944;
        Wed,  1 Jun 2022 00:06:39 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Updates for Linux 5.19
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20220531212053.144805-1-anna@kernel.org>
References: <20220531212053.144805-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20220531212053.144805-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.19-1
X-PR-Tracked-Commit-Id: 118f09eda21d392e1eeb9f8a4bee044958cccf20
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 700170bf6b4d773e328fa54ebb70ba444007c702
Message-Id: <165404199996.13836.4732077341367205049.pr-tracker-bot@kernel.org>
Date:   Wed, 01 Jun 2022 00:06:39 +0000
To:     Anna Schumaker <anna@kernel.org>
Cc:     linux-nfs@vger.kernel.org, torvalds@linux-foundation.org,
        anna@kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Tue, 31 May 2022 17:20:53 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.19-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/700170bf6b4d773e328fa54ebb70ba444007c702

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
