Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0E51C433E0
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Feb 2021 23:07:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 67B1A600CF
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Feb 2021 23:07:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232177AbhBWXBy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Feb 2021 18:01:54 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54368 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233994AbhBWXAY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2021 18:00:24 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F0D5AC061786
        for <linux-nfs@vger.kernel.org>; Tue, 23 Feb 2021 14:59:18 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 97D642824; Tue, 23 Feb 2021 17:59:18 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 97D642824
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1614121158;
        bh=EzOyWJsUUHLB8/jY+JwuMcL9ppreXa21tTxcwwKMCj0=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=vpzzw115zRa466eoY0W9AtSRPBD3iUvpwg+/l4SPh70boDEKE28FurqPXRt2oTSKf
         LS4wdx1rN2tVZFStaDk9HiL09dXwIXR+uZaxb2a52NfPq0dILOsbl4WuyRopH6qraQ
         z1hxNLdmaok0lDLBY2R34bPX3CdQu9KJ0ETPIjBQ=
Date:   Tue, 23 Feb 2021 17:59:18 -0500
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Rue Mohr <sn0297@sunshine.net>, linux-nfs@vger.kernel.org
Subject: Re: nfs kernel server bug
Message-ID: <20210223225918.GE8042@fieldses.org>
References: <602020C9.50705@sunshine.net>
 <5B1E0F4D-F26F-4CB5-858A-E49D0819C864@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B1E0F4D-F26F-4CB5-858A-E49D0819C864@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 08, 2021 at 06:58:38AM -0500, Benjamin Coddington wrote:
> On 7 Feb 2021, at 12:18, Rue Mohr wrote:
> 
> >I'm having an issue where the kernel server is dishing out all
> >zeros for file content being read over NFS. The file byte count is
> >correct.
> >Writing files is fine.
> >With the same client, a different server works just fine.
> >
> >I have been trying to pin this down, so far all I know is that the
> >packets from the server actually contain zeros for the file
> >contents.
> >
> >The troubled server kernel is 5.4.1
> >
> >Has anyone encountered this or is it just me?
> 
> Haven't heard of this before, but sounds like a fascinating problem.
> 
> What version of nfs, and what security?  You're seeing READ
> operations returning
> with rsize-ed blocks of all-zero data in a network capture?

It might also be useful to know what filesystem you're exporting, with
what mount and export options.

--b.
