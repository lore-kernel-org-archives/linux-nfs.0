Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC11DC7EE32
	for <linux-nfs@archiver.kernel.org>; Mon, 22 May 2023 19:14:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232921AbjEVTOK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 May 2023 15:14:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37136 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232823AbjEVTOF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2023 15:14:05 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 669C1188
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2023 12:14:01 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E6A6862710
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2023 19:14:00 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 57104C4339C;
        Mon, 22 May 2023 19:14:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1684782840;
        bh=xkR0CoZaEJFpIDRX+soROQRZ4MzfVQL1YoxKOOADBI8=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=I2nNMq0Vnu24n22UUIiLpx6J5BgWAsb6uEjJ1tOxFHiCkE8bmhRbir25JfGyaXaQD
         LRTk30ZdxzUVDE7276QVQJDZ/IFz9rSLR/vI18fzX6wS4oSypv9Fr1izAX1zUcvOI9
         zp/y7iPrbEPCXLQkFP3TyKiD5eWVmnWvr7jN4Y5dTbzc8ouiQnERsYDaGtpUrfxSrX
         o8lUrXHR5jaVBOVqE6rZPuYefJnkmdohhe2D0hwGrtM7QUP/p1N9B2skhIZlgsrUDB
         o1vz6dXjpsj2tOPytf8s/vSlITzxSzszDt3AXc9IbCCimbCFikJdKxWBFxNzUTq8kV
         Co/Q/PO5bVHQQ==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 4647AE22AEC;
        Mon, 22 May 2023 19:14:00 +0000 (UTC)
Subject: Re: [GIT PULL] Please pull NFS Client bugfixes for 6.4-rc
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20230522184329.5173-1-anna@kernel.org>
References: <20230522184329.5173-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20230522184329.5173-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-6.4-2
X-PR-Tracked-Commit-Id: 43439d858bbae244a510de47f9a55f667ca4ed52
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 421ca22e313871d4104617bab077b275b30950ae
Message-Id: <168478284028.6284.15202081407954258245.pr-tracker-bot@kernel.org>
Date:   Mon, 22 May 2023 19:14:00 +0000
To:     Anna Schumaker <anna@kernel.org>
Cc:     linux-nfs@vger.kernel.org, torvalds@linux-foundation.org,
        anna@kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Mon, 22 May 2023 14:43:29 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-6.4-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/421ca22e313871d4104617bab077b275b30950ae

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
