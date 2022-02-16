Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F045FC433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Feb 2022 19:50:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235259AbiBPTuY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Feb 2022 14:50:24 -0500
Received: from mxb-00190b01.gslb.pphosted.com ([23.128.96.19]:48296 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234886AbiBPTuX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2022 14:50:23 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 288FC2B1015
        for <linux-nfs@vger.kernel.org>; Wed, 16 Feb 2022 11:50:10 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 62E876215; Wed, 16 Feb 2022 14:50:09 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 62E876215
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1645041009;
        bh=2VbnN38C1A4gLqVittV7kf3/OYrIMiAvJNi8hBQjHqk=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=AKUT9S8k6AoOdel+glH7qQsi3xdVthDeOaAH+sEbqwOoBbDhayJVJcxv6jX6K7MpJ
         wA9ovcevkPm9+JIvQdgwkinX4iVrJkG/YsBim382PS6nGNOFKi/k3lKtTABFxcrAwA
         UOt+t92wCeEVWWcJ2X/yh1XkBkDR9aSb1BC/xGIo=
Date:   Wed, 16 Feb 2022 14:50:09 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Patrick Goetz <pgoetz@math.utexas.edu>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: How are client requests load balanced across multiple nfsd
 processes?
Message-ID: <20220216195009.GC29074@fieldses.org>
References: <19e14932-ed88-60a1-844a-0e17deee269d@math.utexas.edu>
 <20220216192215.GB29074@fieldses.org>
 <715a5da9-a7a1-f2b6-b02b-8cc2712b001d@math.utexas.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <715a5da9-a7a1-f2b6-b02b-8cc2712b001d@math.utexas.edu>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 16, 2022 at 01:33:55PM -0600, Patrick Goetz wrote:
> On 2/16/22 13:22, J. Bruce Fields wrote:
> >There's no user process that calls "listen"; knfsd's normal rpc handling
> >is all in-kernel.  Incoming rpc's may be handed to any of those 16 tasks
> >for processing.  A single task just runs a loop where it receives an
> >rpc, handles it, and sends a response back.
> >
> 
> How does knfsd decide what user space nfsd process to hand a task
> off to?

To be clear, knfsd tasks never run in userspace at all.

> Is it random, round robin, or something more sophisticated?

It's complicated, and I'd have to look at the code.  It's an
implementation detail that nobody should have to depend on.

> Or does it even matter if nfsd is only handling one request at a
> time anyway?

If you're running with 16 threads, then it can be (oversimplifying a
bit) handling up to 16 requests at a time.

--b.
