Return-Path: <SRS0=uE3C=6L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2F51C81857
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 22:20:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 95BFE2074F
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 22:20:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726259AbgD0WUW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 27 Apr 2020 18:20:22 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51882 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726204AbgD0WUV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2020 18:20:21 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00::f03c:91ff:fe50:41d6])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C4847C0610D5
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2020 15:20:21 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 5788383B; Mon, 27 Apr 2020 18:20:21 -0400 (EDT)
Date:   Mon, 27 Apr 2020 18:20:21 -0400
To:     sea you <seayou@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: TestStateID woes with recent clients
Message-ID: <20200427222021.GH31277@fieldses.org>
References: <CAL9i7GFknrUDyp9PsGK-wbJ=0m30vHnvzoxpOjKtpRJPGDArjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL9i7GFknrUDyp9PsGK-wbJ=0m30vHnvzoxpOjKtpRJPGDArjQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 20, 2020 at 04:32:27PM +0200, sea you wrote:
> Time-to-time we're plagued with a lot of "TestStateID" RPC calls on a
> 4.15.0-88 (Ubuntu Bionic) kernel, where clients (~310 VMS) are using
> either 4.19.106 or 4.19.107 (Flatcar Linux). What we see during these
> "storms", is that _some_ clients are testing the same id for callback
> like
...
> Due to this, some processes on some clients are stuck and these nodes
> need to be rebooted. Initially, we thought we're facing the issue that
> was fixed in 44f411c353bf, but as I see we're already using a kernel
> where it was backported to via 90d73c1cadb8.
> 
> Clients are mounting as
> "rw,nosuid,nodev,noexec,noatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,acregmin=600,acregmax=600,acdirmin=600,acdirmax=600,hard,proto=tcp,timeo=600,retrans=2,sec=sys"
> 
> Export options are the following
> "<world>(rw,async,wdelay,crossmnt,no_root_squash,no_subtree_check,fsid=762,sec=sys,rw,secure,no_root_squash,no_all_squash)"

Sorry for the derail, but the "async" export option is almost a never
good idea.

> Can you please point me in a direction that I should check further?

Off the top of my head, my only suggestion is to retest if possible on
the latest upstream kernel.

--b.
