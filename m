Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BF62C4151A
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 14:25:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3AEF2222B2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 14:25:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="CH3INqVb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="k37h6K7t"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392140AbfBMOZq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 09:25:46 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59501 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1731144AbfBMOZq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 09:25:46 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.nyi.internal (Postfix) with ESMTP id 1D51620B77;
        Wed, 13 Feb 2019 09:25:45 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Wed, 13 Feb 2019 09:25:45 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
        date:from:to:cc:subject:message-id:references:mime-version
        :content-type:in-reply-to; s=fm3; bh=EEwawwk0Y/TypUv7Is2mbpWQOjO
        g347U0Q/mGw07Xz8=; b=CH3INqVbzp6qWVV2p+DYEkdCB42eingnJuJocj9Ug/7
        nQXRTSrt4ngXrfS/tgNDAzwZDt3ljb+1nxTPb+BIKjVQ1CeSm13qkwQaKELGGqJw
        orLrXkLRHuwuEsLBHc0AWahTmWNoW53e9IVOFw8XPxHt2lr4j4PvGCgveaDO+J0D
        R0Hyy9aCX3b9ThBWRs1d3wOUkQ/BRYdSU6Uf8ZXpsfZntkOGuQCNEYoWRsu8rHgC
        xIfdDeQRCr8PauNAz98UaBf0HqsqnPy/j4ZB2oBO9uLh9t816mfmwOjSeteXBn5Z
        txsWRi4hl1BpE16iJVIOXU37d4N4R101Z2DeSR3GWgA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=EEwaww
        k0Y/TypUv7Is2mbpWQOjOg347U0Q/mGw07Xz8=; b=k37h6K7t6mlZ6K1738tEqD
        HqasIH5Qp/vPsqWsi3eGEmSjVRsMlLhLVTRuIWapWGvB3LlplXu/7YquGZmowIqX
        6Xdpt+WQLH8I/WE0VH549CzPOAHzqvznOzKJRZGYS33mr0qAOSt3+bOTKAvx0yoR
        Epp6bhHncZLTyErQHl3GSedBfdXVkxWfraBG4KdLGhEhvQyiLLwcaWpWjEN79/8q
        1kJxdZJ26hBby5NOEiRHMVEWq3ZpiPS2d3yy94Rmsg0MWDu+KhA4W8SUn7rnviLj
        O4kMt7z7ZN/KCy4TIQCYOgv1UDd1kobtmomkkT9rkDguGkP5M29XdBw7GcIX93qw
        ==
X-ME-Sender: <xms:6ChkXNHBEEhQMiFdpaPHTZtxfwhS65GXBs88CYfE3Sifj0SXjwh08Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtfedgieegucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfquhhtnecuuegrihhlohhuthemucef
    tddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpeffhffvuffkfh
    ggtggujggfsehttdertddtredvnecuhfhrohhmpefirhgvghcumffjuceoghhrvghgsehk
    rhhorghhrdgtohhmqeenucfkphepkeefrdekiedrkeelrddutdejnecurfgrrhgrmhepmh
    grihhlfhhrohhmpehgrhgvgheskhhrohgrhhdrtghomhenucevlhhushhtvghrufhiiigv
    pedt
X-ME-Proxy: <xmx:6ChkXMSRJ0n-aUELqp9mb51TVE_XGXnj5jjJAtRDgBHHWDZJEyXYsw>
    <xmx:6ChkXBAyXiOfIgkkIXMCXyIRjuBbU8J4srfH5j5-gOyTwAcUn3J7BQ>
    <xmx:6ChkXOgv3YylXrr8Nzaknwealg3r4kayV1o7jdvPfbzDw54ga3N44Q>
    <xmx:6ShkXMWFNSEhl6ouB45nTvD-N31IZIKiK7qKzZbbSBrRZw_QnumnHQ>
Received: from localhost (5356596b.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        by mail.messagingengine.com (Postfix) with ESMTPA id E8DAC1030F;
        Wed, 13 Feb 2019 09:25:43 -0500 (EST)
Date:   Wed, 13 Feb 2019 15:25:42 +0100
From:   Greg KH <greg@kroah.com>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     stable@vger.kernel.org, dwysocha@redhat.com,
        linux-nfs@vger.kernel.org, smayhew@redhat.com,
        trondmy@hammerspace.com
Subject: Re: [STABLE PATCH] SUNRPC: Always drop the XPRT_LOCK on
 XPRT_CLOSE_WAIT
Message-ID: <20190213142542.GF10202@kroah.com>
References: <f3dda1a55b9a5d5a7416925358379608cc3a431e.1547069858.git.bcodding@redhat.com>
 <f3dda1a55b9a5d5a7416925358379608cc3a431e.1549453044.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3dda1a55b9a5d5a7416925358379608cc3a431e.1549453044.git.bcodding@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 06, 2019 at 06:42:15AM -0500, Benjamin Coddington wrote:
> This patch is only appropriate for stable kernels v4.16 - v4.19

Now queued up, thanks.

greg k-h
