Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92976C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 13:34:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60BFA21B1C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 13:34:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="WbnyVO7W";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="62bv5DfH"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727725AbfBKNe6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 08:34:58 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58613 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727718AbfBKNe6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 08:34:58 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.nyi.internal (Postfix) with ESMTP id 4E2E222133;
        Mon, 11 Feb 2019 08:34:57 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Mon, 11 Feb 2019 08:34:57 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
        date:from:to:cc:subject:message-id:references:mime-version
        :content-type:in-reply-to; s=fm3; bh=CynrtZbJPgChcTYCDjOxwNtVoVp
        K5Ey306ErauvG0QY=; b=WbnyVO7W9+kH9uC7WjvuG9p21eWVoSXqmtD4oisCa7q
        QY/9ZHwId7ekKn+a2ld+ri3dQys9UnaLUV5DHBj01hv7NsEUCCRsPrG+hlT4HVCT
        QU6shuAKObQw2VGZ16hjePUrob5mEc1Fq+QegOxSAh0GF/tmnDRO5pJAjJcV7Vks
        YVVmO8RimsfJbEedo0UAag/yNBPFQUbRYNikKB6kQ/iszORfHE7BOSBVgJIC8uVS
        SJF1LS6qVJAlXb8XkMTCz6fi9bK09hjdu0HhlSd4rpOnkfcWoM6jLO/dscKAc65b
        vbeVjM56dHJRL/8J9VPkTGEMq1R9X+rOYPIio4Ohsow==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=CynrtZ
        bJPgChcTYCDjOxwNtVoVpK5Ey306ErauvG0QY=; b=62bv5DfHi/rYA6pBzqKt5S
        6YbdicCguDkEsKXM2CQkKWm7w3QK8XKX9KpCK9mYR7x+KtpBTtJ8V5G0+b4EV0Ur
        lObyMk0ERK3PHRWQW6Rjdr6MFBiaGlcINwR97OGqVxIXkCCpM5EMLNlRiohBuhF2
        mC67AL5A6rZFrFKvnzcNkYCmcSsWZ50bb7DrYMlb0gK4oTzny58Sxx8Crur7NVjO
        2/EIDtHVK80pr/hd5nc8tl83M3wIYNqXo68aAwyqhzofSqjs60YDUkeM+s0ugRNf
        3vA1aZ3Jt0xelwwrL32K5pW2z/XwnR816eRHbYZ5WGPpgocPbW82CNQXxpCgWy/Q
        ==
X-ME-Sender: <xms:AXphXOSvpoS9GR8L9Bt-fOD_qUD6AaIPxuUxtENX9wPKaqX91_FK4Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrleelgdefiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepfffhvffukfhfgg
    gtuggjfgesthdtredttdervdenucfhrhhomhepifhrvghgucfmjfcuoehgrhgvgheskhhr
    ohgrhhdrtghomheqnecukfhppeekfedrkeeirdekledruddtjeenucfrrghrrghmpehmrg
    hilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhmnecuvehluhhsthgvrhfuihiivgep
    ud
X-ME-Proxy: <xmx:AXphXBejQyTjOPwFqKRjPjYqBsOQxBEF1NEgA3JYPTzm-Lk3r7ln9Q>
    <xmx:AXphXNkE-tNlydhnEZa9x5EaZzOM96uMQQzQZb9MaSmbtM_9Lg4e1A>
    <xmx:AXphXGi_RgM8gRLbZ8gqHJ4nXl6Y1BHQZYr07tNII02GlMe-aOrt9Q>
    <xmx:AXphXIoy5R7if22-8HREV-0WdBYLc6S6KFd3HWHkJRacq_mXW38pbA>
Received: from localhost (5356596b.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        by mail.messagingengine.com (Postfix) with ESMTPA id 8E0AB100E5;
        Mon, 11 Feb 2019 08:34:56 -0500 (EST)
Date:   Mon, 11 Feb 2019 14:34:54 +0100
From:   Greg KH <greg@kroah.com>
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190211133454.GB17709@kroah.com>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205100141.25304-1-buczek@molgen.mpg.de>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 05, 2019 at 11:01:39AM +0100, Donald Buczek wrote:
> Please include the upstream patches
> 
>     *  commit 085def3ade52 ("nfsd4: fix cached replies to solo SEQUENCE
> compounds")
>     *  commit 53da6a53e1d4 ("nfsd4: catch some false session retries")
> 
> into longterm kernel 4.14.
> 
> Because these patches went upstream in 4.15, they are already
> included in longterm 4.19 and stable.

Both now queued up, thanks.

greg k-h
