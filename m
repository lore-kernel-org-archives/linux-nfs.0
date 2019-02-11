Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 105A0C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 13:34:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D4D7621B1A
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 13:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="z+st/UPQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="7boi18uW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727728AbfBKNeq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 08:34:46 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50265 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728016AbfBKNep (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 08:34:45 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.nyi.internal (Postfix) with ESMTP id AB17E21E44;
        Mon, 11 Feb 2019 08:34:44 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Mon, 11 Feb 2019 08:34:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
        date:from:to:cc:subject:message-id:references:mime-version
        :content-type:in-reply-to; s=fm3; bh=qMr3vAe7JPYu2ieIG+3x4bA8Tac
        pY3S3oqTZwPOqEEI=; b=z+st/UPQgxxTU8tDbI3zcOKflwThGZ6NUhPVHvwGdeJ
        Pdqi8GvJWdRPYCQV57cMwdQEqe+E1J74sh7uCCQ3KoIbQGcMNCJTiNuXwbK6wk9m
        wrufn+QBNquU0c9U16ZMBcQGYx/hqhYe7T20HfYxS8QCKKr1a7izUvzbgEqdVh/Y
        LVaY7fr7sVe702iYjVQQ/gnubFzT4mVM+KkdBjCyXfSvj3wRVuEqcRvRrXa0qASu
        nIbK8I4pk6iwVVznCkD3oPy4+Yjo0pvP0nvi3kHx8g7mV/VpnqQct/+KUEcgfbfO
        SbCvFDqcjdHs75RX3m/lNcPpB1fwnyCpewD1Y1YYgug==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=qMr3vA
        e7JPYu2ieIG+3x4bA8TacpY3S3oqTZwPOqEEI=; b=7boi18uWm6i10K39sy5UeD
        NSEoaV0+XkrG6lX8QSCT3g06zjTVnpg5bd7kK0gg9T61QyKawk2fx7iQsYJwgZsN
        vwRDUQT1QjemBzrRtSGc0wWU8xMbC4x5VPcZHuPPs71OdumTUmCXSccn9Xf4ytVr
        xhsPArv+3qQPvCzDFUTHobH7ByH5SB/BJGMOCqJsVANQUGF4hwP+WPjWkjI9AE06
        4JzgKdFbJtRqMAeZDkDCTerahYbNKIMyZUjaQWHI2Vv0Z1qtNS/DHY5LZVoeG1Lu
        wBDPEJLCizMCZMLPkJp5woQ9ir5DY+nZ/dCY9Al12qI8fKuhThM4kLEDCyT9xaxg
        ==
X-ME-Sender: <xms:83lhXD3ikK5WJwdAQ8QAu9SwovFoQhugTvB13X5ca4v1UsaABXM_SA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrleelgdefiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepfffhvffukfhfgg
    gtuggjfgesthdtredttdervdenucfhrhhomhepifhrvghgucfmjfcuoehgrhgvgheskhhr
    ohgrhhdrtghomheqnecukfhppeekfedrkeeirdekledruddtjeenucfrrghrrghmpehmrg
    hilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhmnecuvehluhhsthgvrhfuihiivgep
    td
X-ME-Proxy: <xmx:83lhXGUXVJY0Ymk5jsSiwuaFfBz_UNU7lTt1yIFnV1IIveaWje1new>
    <xmx:83lhXO6gmXdRhRyrmk9xqU3eWmiDupX7cud5ILnYeCBcCa2TBAEVIg>
    <xmx:83lhXNJiZsE1tX7XiyEhIpIh7UqLTRqBmfGNYyOKzKwBcJjphRz9RA>
    <xmx:9HlhXBElapneJC8Z522Nl_ljezUH9YttcQ3FV0EfR74H6-NMTId0dg>
Received: from localhost (5356596b.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        by mail.messagingengine.com (Postfix) with ESMTPA id AC7B1E4068;
        Mon, 11 Feb 2019 08:34:42 -0500 (EST)
Date:   Mon, 11 Feb 2019 14:34:41 +0100
From:   Greg KH <greg@kroah.com>
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     Salvatore Bonaccorso <carnil@debian.org>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190211133441.GA17709@kroah.com>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
 <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
 <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 05, 2019 at 03:59:04PM +0100, Donald Buczek wrote:
> On 02/05/19 12:59, Salvatore Bonaccorso wrote:
> 
> > Are you planning to submit the same as well for 4.9 LTS? The two
> > commits apply on top of 4.9.154 with line number updated.
> 
> No, I'm not, because I didn't do any testing with 4.9.
> 
> Additionally, I'm unsure about the right procedure for trivial backports
> to multiple trees: Individual patch sets, which apply perfectly, a single
> patch sets and Greg resolves that for the other trees or maybe no patch
> set at all and just a "please cherry-pick .... from upstream" mail.

The first patch in this series applies to 4.9.y, but the second does
not.

I'll be glad to take a backported, and tested, series, if someone still
cares about NFS for 4.9.y.  But unless you really care about that tree,
I would not worry about it.

thanks,

greg k-h
