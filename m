Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6990DC433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Feb 2021 19:24:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1687E64F3F
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Feb 2021 19:24:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230386AbhBYTYw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Feb 2021 14:24:52 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59892 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233615AbhBYTWr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Feb 2021 14:22:47 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CDF70C061756
        for <linux-nfs@vger.kernel.org>; Thu, 25 Feb 2021 11:21:26 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id A755E241A; Thu, 25 Feb 2021 14:21:25 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org A755E241A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1614280885;
        bh=/C2VntqjEj5YeUaNPkhQCU+T1eJpJChL7WM4vKTu4p8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=ayITaVcLJ0Ld4ArSwkn1HgXpG0nsn/0ADwPOAQUjn7XxFV7r3GYOLVSw8C90JBjqK
         92THureKyL6Wl1A0hUVKVuJVYyhsa8fPL1W0xbb+sl647V/MJUMo8uQEAr31KTtES5
         qY5EvlxipGrCbB/UdmB7Vr6Cq6R17BMBr0H6foSs=
Date:   Thu, 25 Feb 2021 14:21:25 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Tom Talpey <tom@talpey.com>
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Subject: Re: [PATCH] nfsd: don't abort copies early
Message-ID: <20210225192125.GF17634@fieldses.org>
References: <20210224183950.GB11591@fieldses.org>
 <20210224193135.GC11591@fieldses.org>
 <59A5F476-EE0C-454F-8365-3F16505D9D45@oracle.com>
 <20210224223349.GB25689@fieldses.org>
 <CDFF4F84-1A0C-4E4C-A18B-AC39F715E6D8@oracle.com>
 <CAN-5tyFLLLfMwZVFrnQaCnR36Rfq_hPsmLEOLG2Qtrpc+pT7fA@mail.gmail.com>
 <20210225155715.GD17634@fieldses.org>
 <83f6cd8f-5a29-3dee-4359-6be01ab6d894@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83f6cd8f-5a29-3dee-4359-6be01ab6d894@talpey.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 25, 2021 at 01:39:34PM -0500, Tom Talpey wrote:
> On 2/25/2021 10:57 AM, Bruce Fields wrote:
> >Yes, that was part of some Y2038 project on Arnd Bergman's part:
> >
> >	20b7d86f29d3 nfsd: use boottime for lease expiry calculation
> >
> >I think 64-bit time_t is good for something like a hundred billion
> >years, so wraparound isn't an issue.
> 
> Well, the universe is somewhere below 14B so that's good, but is this
> time guaranteed to be monotonic? If someone sets the system time, many
> clocks can go backward...

Yeah, Arnd makes a note about this in the above commit.

--b.
