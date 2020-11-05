Return-Path: <SRS0=7e9X=EL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75D99C388F7
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Nov 2020 20:52:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E39A520719
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Nov 2020 20:52:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="PVn1aKXd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732235AbgKEUwI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 5 Nov 2020 15:52:08 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48228 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729783AbgKEUwH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2020 15:52:07 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6E278C0613D2
        for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2020 12:52:07 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7A2461509; Thu,  5 Nov 2020 15:52:05 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7A2461509
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1604609525;
        bh=tZbdz25Jh3tUk79L85NkD6dh3U0qvw857r06NkSeLec=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=PVn1aKXdsSR6/jIxbA1A0L3nhf2dscXPl9gGGBoHGpkO+Hkv9LLrbUzCxnOBDTegL
         8qlpVVSUoJDPvEuTFXG3BvpPh26SBcEUJre5j2TqJqkIg89K0T5bBuzySK/G67CZd1
         4V4epvytl6xE/r4afm61d7VdgzAFJa+azmd1uRIY=
Date:   Thu, 5 Nov 2020 15:52:05 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Anna Schumaker <schumakeranna@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: xfstests generic/263
Message-ID: <20201105205205.GC25512@fieldses.org>
References: <20201027174945.GC1644@fieldses.org>
 <CAFX2Jf=-Y905+cMtLike2ddpthCV=K6CM8iS4EPeAz1RYzF-pA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFX2Jf=-Y905+cMtLike2ddpthCV=K6CM8iS4EPeAz1RYzF-pA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 27, 2020 at 03:59:56PM -0400, Anna Schumaker wrote:
> On Tue, Oct 27, 2020 at 1:49 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Generic/263 is failing whenever client and server both supports
> > READ_PLUS.
> >
> > I'm not even sure the failure is wrong.  The NFS FALLOC operation doesn't
> > support those other other fallocate modes, are they implemented elsewhere in
> > the kernel or libc somehow?  Anyway, odd that it would have anything to do with
> > READ_PLUS.
> 
> I just ran xfstests, and I'm seeing this too. The test passes using
> basic READ on v4.2, so there might be something farther down the log
> that diff is cutting off. I'll see if anything sticks out to me this
> week.

I think 091 is failing from the same cause, by the way.  I haven't
investigated any more though.

--b.
