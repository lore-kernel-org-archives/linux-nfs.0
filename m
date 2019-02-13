Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDBE9C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 14:15:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA575222BA
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 14:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="s1FXZE36";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ja9f2Y/a"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729738AbfBMOPn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 09:15:43 -0500
Received: from wout2-smtp.messagingengine.com ([64.147.123.25]:60921 "EHLO
        wout2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726654AbfBMOPn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 09:15:43 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.west.internal (Postfix) with ESMTP id 435363060;
        Wed, 13 Feb 2019 09:15:42 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Wed, 13 Feb 2019 09:15:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
        date:from:to:cc:subject:message-id:references:mime-version
        :content-type:in-reply-to; s=fm3; bh=sNro6bY0ZzqDjLOiq94IZ6FX4a2
        AoTEHLVIw15V1T0g=; b=s1FXZE36GWpigJ4x7ZMUedJg9mgEBvV+GjusxmE1ZuK
        FC2YSWepCgEUmDFjL1HP94dAqDl9b3em/lePIcYewhn15SIr/M1SwYH/SDG++uCV
        pLvzRyCl2BSr5LGbIil6rx7/G99na0j2KGv50hwErxnPnNWzJzSrKOgq2vzsyKGL
        s8irTmjrV+khbJEA5CoVTGuqGm+DUZUAyRtGvELiIGv+F3uS/yZKQb2fRPvaAEtE
        ztn3K/aguYaTFV0EHY3pIOPWjDdHPqfzgJpbxdgdcGOPZ+2lkfB5vb1b8xKgMW9E
        hG6DZqTNoLGzUpkgHzAzUp41D2mjjhDGqZU7R/d5/WQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=sNro6b
        Y0ZzqDjLOiq94IZ6FX4a2AoTEHLVIw15V1T0g=; b=ja9f2Y/aku+xDCW6yNZ2sJ
        T5VXWtyL5pLGWh87OZ1CgBs8PEajzH0uBxJQ353VGwFis6Uw6AgYe9LL2EsAUiC5
        KbNJgrqG0kUL2sl/SOevhIyUNzLV8OrDQL2XkhBvZYB+jfSprrRi84eH7/St8UtQ
        TsjH9Ekbm/ZcGteEqckGmWrouAV9F1AU4uPRgyYniar1dC+Nn6gOplCF8CqzjMyw
        0lgb9ELI6fZPGqeFneBFVpJ7CZuP3nX28ukqJcc/sPks7OB8M2WvA+ejauU35VVO
        pB9waoqxbdsHWa6PA3o86rF4f4taJZyveJRScanHqaJPl5T2TOJDKy3GZ2Pzt6Aw
        ==
X-ME-Sender: <xms:jCZkXEEICqy4LBg_8Q75rwI9fT1vJ0MP8tanbcRXC6PvNtn-ShfrcQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtfedgiedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfquhhtnecuuegrihhlohhuthemucef
    tddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpeffhffvuffkfh
    ggtggujggfsehttdertddtredvnecuhfhrohhmpefirhgvghcumffjuceoghhrvghgsehk
    rhhorghhrdgtohhmqeenucffohhmrghinhepuggvsghirghnrdhorhhgnecukfhppeekfe
    drkeeirdekledruddtjeenucfrrghrrghmpehmrghilhhfrhhomhepghhrvghgsehkrhho
    rghhrdgtohhmnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:jCZkXKGT5tonlZeJkEMYGlcFNIZ4kXDCIhUyViuzA1YdMEkm57FlOw>
    <xmx:jCZkXIsB0G0yJH7nYITicUSwLO3BHhfYnEaQv0ArsFZvusEra9khqw>
    <xmx:jCZkXJVEFaWn7qoP8SknGrF7gF1cJ_azjOBoffP__jhHIlN71izuBQ>
    <xmx:jSZkXCLL8nBh99Fv7OCMyYi2BU9IUb9RdoejHQ6Nx8huEktgOnkODA>
Received: from localhost (5356596b.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        by mail.messagingengine.com (Postfix) with ESMTPA id 29DBEE4543;
        Wed, 13 Feb 2019 09:15:40 -0500 (EST)
Date:   Wed, 13 Feb 2019 15:15:38 +0100
From:   Greg KH <greg@kroah.com>
To:     Salvatore Bonaccorso <carnil@debian.org>
Cc:     Donald Buczek <buczek@molgen.mpg.de>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190213141538.GB10202@kroah.com>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
 <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
 <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
 <20190211133441.GA17709@kroah.com>
 <20190211155926.GA19955@eldamar.local>
 <20190213064956.i57glcw5qql6t6qr@lorien.valinor.li>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213064956.i57glcw5qql6t6qr@lorien.valinor.li>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 13, 2019 at 07:49:56AM +0100, Salvatore Bonaccorso wrote:
> On Mon, Feb 11, 2019 at 04:59:26PM +0100, Salvatore Bonaccorso wrote:
> > On Mon, Feb 11, 2019 at 02:34:41PM +0100, Greg KH wrote:
> > > On Tue, Feb 05, 2019 at 03:59:04PM +0100, Donald Buczek wrote:
> > > > On 02/05/19 12:59, Salvatore Bonaccorso wrote:
> > > > 
> > > > > Are you planning to submit the same as well for 4.9 LTS? The two
> > > > > commits apply on top of 4.9.154 with line number updated.
> > > > 
> > > > No, I'm not, because I didn't do any testing with 4.9.
> > > > 
> > > > Additionally, I'm unsure about the right procedure for trivial backports
> > > > to multiple trees: Individual patch sets, which apply perfectly, a single
> > > > patch sets and Greg resolves that for the other trees or maybe no patch
> > > > set at all and just a "please cherry-pick .... from upstream" mail.
> > > 
> > > The first patch in this series applies to 4.9.y, but the second does
> > > not.
> > > 
> > > I'll be glad to take a backported, and tested, series, if someone still
> > > cares about NFS for 4.9.y.  But unless you really care about that tree,
> > > I would not worry about it.
> > 
> > Hmm, both apply on top of 4.9.155, still but with line numbers
> > adjusted (I'm attaching the respective rebased patches). Actually my
> > question on the respective backports was originally triggered due to
> > https://bugs-devel.debian.org/898060
> > 
> > The problem actually is on the 'tested' part, as Donald did no
> > testing/reproducing with 4.9 itself.
> 
> Attached rebased to apply on top of 4.9.156.

Thanks, both now queued up.

greg k-h
