Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B84BDC636D6
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Feb 2023 22:51:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233028AbjBVWvV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Feb 2023 17:51:21 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42410 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232885AbjBVWvV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2023 17:51:21 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 49342301B6
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2023 14:51:20 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id B6ACC615BB
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2023 22:51:19 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 3766FC4339B;
        Wed, 22 Feb 2023 22:51:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1677106279;
        bh=aJ0GgazDqX3G1tp8urLRDGgXmdxeuCsAJg2aCfnR3Hw=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=SErlHmhk7F1u4mesF48EDc0+8EjVd/LgInirrddIzghdxweWkVZlhvd+JFkHbeWFj
         C86aBAEtPT498Lp+4ZFRNyhz4dgPe95FUFCPQA0MTRs18r7qtVQqKDfUpCBtUYiHpR
         idGybLjEriPkktO3XP1gg8/SS0eqOBJDZ80mmpk0Bpwm2p/t0YvJ/Fk4oPNnHuyBI8
         /Qh3XZvdGptNacGnELG7yY8FZcVWCe7BUiC0s7Kw9Z7h2wVYnxGQ/J0gqHdp8KGayp
         nCw7beCUWejyXh3YovwoPmS7JEjCescu/kv9tIA8nNhgDQ9wiotzZYgZN+5wh1A/15
         LeoPpKW3/bggw==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 1D0B4C43151;
        Wed, 22 Feb 2023 22:51:19 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Updates for Linux 6.3
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20230222222752.1838386-1-anna@kernel.org>
References: <20230222222752.1838386-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20230222222752.1838386-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-6.3-1
X-PR-Tracked-Commit-Id: 1683ed16ff1a51705f58e8083ed93a7428a543f2
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: d8ca6dbb8de7923fcfb18e0b0b123f37c3225519
Message-Id: <167710627911.4041.17723650752078139354.pr-tracker-bot@kernel.org>
Date:   Wed, 22 Feb 2023 22:51:19 +0000
To:     Anna Schumaker <anna@kernel.org>
Cc:     linux-nfs@vger.kernel.org, torvalds@linux-foundation.org,
        anna@kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Wed, 22 Feb 2023 17:27:52 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-6.3-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/d8ca6dbb8de7923fcfb18e0b0b123f37c3225519

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
