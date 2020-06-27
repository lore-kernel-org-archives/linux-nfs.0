Return-Path: <SRS0=mw3P=AI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E621C433DF
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Jun 2020 16:40:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E901620720
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Jun 2020 16:40:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1593276003;
	bh=qjwzU4pzrbllzR2WpoCI9BmMVT6/EDRvGYN6gKEMnRk=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=dOdcq7MDuNrpo6KWF4cr5ADniCOloqAruY9+L4mkeOaoH8rcIPb+n3/cpfVI9RPBo
	 0ZAEClnNXSObqDpAi1lxVdRaBKtZCpjYqWI9OzsMtgEh32rHQV2UvcHkwCZ/M/lErb
	 FglkVc7kExPF1+ErYm2AzMbYKe/k8MaeCmBoVjn4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725882AbgF0QkC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Jun 2020 12:40:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:52206 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725831AbgF0QkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 Jun 2020 12:40:02 -0400
Subject: Re: [GIT PULL] Please pull NFS client fixes for 5.8-rc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1593276001;
        bh=qjwzU4pzrbllzR2WpoCI9BmMVT6/EDRvGYN6gKEMnRk=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=PDreWrQPcDVtn+kHG9zlI1+E7ZL942wl/1J3GVdkpmskP2aDycEW1hHzidIlqFYvc
         EYwqOWRCih0wTe2EZnxsE6eMcTdcPcHwU28bk4VTQjq9T7YLN7jVkACoc7rN2VpBHY
         QqWmwxwRFqcdI7sF1x5K5+SPOI8+T39khWfuhwl4=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <CAFX2JfkFH1gQQNyLJ88_oe0Zu+_S=XDODoo1nG9PZX=bEKVFFg@mail.gmail.com>
References: <CAFX2JfkFH1gQQNyLJ88_oe0Zu+_S=XDODoo1nG9PZX=bEKVFFg@mail.gmail.com>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <CAFX2JfkFH1gQQNyLJ88_oe0Zu+_S=XDODoo1nG9PZX=bEKVFFg@mail.gmail.com>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git
 tags/nfs-for-5.8-2
X-PR-Tracked-Commit-Id: 89a3c9f5b9f0bcaa9aea3e8b2a616fcaea9aad78
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 4e99b32169e84b4ece5a1d74eb0b7e4ef07866b3
Message-Id: <159327600180.18454.2577829758820824542.pr-tracker-bot@kernel.org>
Date:   Sat, 27 Jun 2020 16:40:01 +0000
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Fri, 26 Jun 2020 17:53:02 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.8-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/4e99b32169e84b4ece5a1d74eb0b7e4ef07866b3

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
