Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1C89C64E7A
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 15:20:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 016FE2076C
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 15:20:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="xIIxpy7o"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389984AbgLAPU3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Dec 2020 10:20:29 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54146 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389163AbgLAPU3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2020 10:20:29 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2153DC0613CF
        for <linux-nfs@vger.kernel.org>; Tue,  1 Dec 2020 07:19:49 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id E6D7E6F4C; Tue,  1 Dec 2020 10:19:47 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org E6D7E6F4C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1606835987;
        bh=bnPcyCic6y35tCpzo23VDYN8wcIBw+YH09i0p3cbdYs=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=xIIxpy7oRJve/4YNzqLMHLz0vcQktS+2Ge4Vl/sZhPNAHVh+BOGuQZrJi4MNqY1/y
         BWU1Rpx/WMPIAYZJkx8pMWmkaztSVDnOdR2gT4YZW/e70Pt57b6Ch19PSVNCOszr+A
         eadpO6UPSKtBU0kn+WbuIb0uXDCwVGbJjmVeCI4Y=
Date:   Tue, 1 Dec 2020 10:19:47 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/6] nfsd: add a new EXPORT_OP_NOWCC flag to struct
 export_operations
Message-ID: <20201201151947.GA15368@fieldses.org>
References: <20201130212455.254469-1-trondmy@kernel.org>
 <20201130212455.254469-2-trondmy@kernel.org>
 <20201130225842.GA22446@fieldses.org>
 <1b525278a9a7541529290588a83852a0754cee3e.camel@hammerspace.com>
 <20201201022834.GA241188@pick.fieldses.org>
 <66f93208c6edf2dad70ee41c349c5130b30b8ed4.camel@hammerspace.com>
 <20201201031130.GD22446@fieldses.org>
 <213a0908e8c9e743d6ae4d6f3b2679e2e879cce4.camel@hammerspace.com>
 <a1db16841eb3e710a0245234c88ef2ceea2336fb.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a1db16841eb3e710a0245234c88ef2ceea2336fb.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 01, 2020 at 03:23:00AM +0000, Trond Myklebust wrote:
> On Tue, 2020-12-01 at 03:16 +0000, Trond Myklebust wrote:
> > On Mon, 2020-11-30 at 22:11 -0500, bfields@fieldses.org wrote:
> > > On Tue, Dec 01, 2020 at 03:06:46AM +0000, Trond Myklebust wrote:
> > > > A local filesystem might choose to set the 'non-atomic' flag
> > > > without
> > > > wanting to turn off NFSv3 WCC attributes. Yes, the latter are
> > > > assumed
> > > > to be atomic, but a number of commercial servers do abuse that
> > > > assumption in practice.
> > > 
> > > What do you mean by abusing that assumption?
> > > 
> > > I thought that leaving off the post-op attrs was the v3 protocol's
> > > way
> > > of saying that it couldn't give you atomic wcc information.
> > > 
> > 
> > I mean that a number of commercial servers will happily return NFSv3
> > pre/post-operation WCC information that is not atomic with the
> > operation that is supposed to be 'protected'. This is, after all, why
> > the NFSv4 "struct change_info4" added the 'atomic' field in the first
> > place.
> 
> BTW: To be fair, so does knfsd...
> 
> At Hammerspace, we had some real problems recently due to XFS exports
> returning non-atomic values for the "space used" field. Speculative
> preallocation is a real bitch:
> https://xfs.org/index.php/XFS_FAQ#Q:_What_is_speculative_preallocation.3F

So you think xfs should omit v3 post-operation attributes and still set
the atomic bit in v4 replies?

Would that have helped in the cases you saw?  It seems like speculative
preallocation isn't a problem with atomicity exactly--it couldn't be
avoided by applications cooperating with some locking scheme, for
example, if I'm understanding right.

--b.
