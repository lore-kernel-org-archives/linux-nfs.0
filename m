Return-Path: <SRS0=W7TE=Z6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA403C2D0BE
	for <linux-nfs@archiver.kernel.org>; Sun,  8 Dec 2019 01:10:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 953B62467C
	for <linux-nfs@archiver.kernel.org>; Sun,  8 Dec 2019 01:10:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575767411;
	bh=+aXi0y29sp+1fBUlwrX8MFWtBjL3VzO0IV0Gwhgi9NI=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=BF0Rv+jHZPb8FM79t6adhWCI25XM84F2E4qTQfcRhmma6kqESXT8cNgIUXA5pN5Oe
	 IJE8zsVS/CaNTMk16Slu7twYtpf777DHo57gcfZ8eZaBjR8sRCt+6AF54VpIbc/nL0
	 xRVsf+H2JKrqvqaK7f7QQHsxCtNbjCzvQfhvc9k4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726635AbfLHBKG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 7 Dec 2019 20:10:06 -0500
Received: from mail.kernel.org ([198.145.29.99]:47450 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725834AbfLHBKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 7 Dec 2019 20:10:06 -0500
Subject: Re: [GIT PULL] nfsd change for 5.5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575767405;
        bh=+aXi0y29sp+1fBUlwrX8MFWtBjL3VzO0IV0Gwhgi9NI=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=Yzy4jxFJrXDRE6AfsKrACVKzSZhGu4NEVTQyRAFXLfDmAz51O1Qr38GZ4+J9WEN5n
         iJC7AUhY4RquLfIkXAbALl8naTBPeX0UV+/E2RqmrpARyIKmQt+YGZwbosR5mGhTAs
         /Y9yfP66tMT/lpImMMblcZKHpcPdG/KO2mb6uZ+Y=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20191207171402.GA24017@fieldses.org>
References: <20191207171402.GA24017@fieldses.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20191207171402.GA24017@fieldses.org>
X-PR-Tracked-Remote: git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.5
X-PR-Tracked-Commit-Id: 38a2204f5298620e8a1c3b1dc7b831425106dbc0
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 911d137ab027e6dac03695bfe71702e64b6aa161
Message-Id: <157576740563.7292.8729033731998452747.pr-tracker-bot@kernel.org>
Date:   Sun, 08 Dec 2019 01:10:05 +0000
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pull request you sent on Sat, 7 Dec 2019 12:14:02 -0500:

> git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.5

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/911d137ab027e6dac03695bfe71702e64b6aa161

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
