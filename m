Return-Path: <SRS0=Tnvp=2B=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42388C43603
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Dec 2019 20:33:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F14A2077B
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Dec 2019 20:33:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726872AbfLKUdK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Dec 2019 15:33:10 -0500
Received: from fieldses.org ([173.255.197.46]:58766 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726686AbfLKUdK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Dec 2019 15:33:10 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 41D1F1C7C; Wed, 11 Dec 2019 15:33:10 -0500 (EST)
Date:   Wed, 11 Dec 2019 15:33:10 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Alex Lyakas <alex@zadara.com>
Cc:     linux-nfs@vger.kernel.org, Shyam Kaushik <shyam@zadara.com>
Subject: Re: [PATCH v2] nfsd: provide a procfs entry to release stateids of a
 particular local filesystem
Message-ID: <20191211203310.GA21338@fieldses.org>
References: <1568142147-21974-1-git-send-email-alex@zadara.com>
 <20191205160015.GC22402@fieldses.org>
 <CAOcd+r272sRYo==owcG90WT3MwrqWXJkSu7UADegmfPQWG2K3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOcd+r272sRYo==owcG90WT3MwrqWXJkSu7UADegmfPQWG2K3A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Dec 08, 2019 at 10:41:29AM +0200, Alex Lyakas wrote:
> Bottom line this issue happens to us in production, and it would be
> good for us to have it resolved. With our limited nfsd understanding,
> do you believe anybody from the community could help?

Yes: congratulations, you're a member of the community, and you can
help!

I'm afraid we've all got a lot on our plates.  This is on my list, but I
doubt I'll get to it in the next year.

--b.
