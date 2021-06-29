Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E91C3C11F67
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 18:37:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CFA6361DE3
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 18:37:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235132AbhF2SkJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jun 2021 14:40:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45276 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234140AbhF2SkJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2021 14:40:09 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C566BC061760;
        Tue, 29 Jun 2021 11:37:41 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 62D894F7D; Tue, 29 Jun 2021 14:37:41 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 62D894F7D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1624991861;
        bh=2QbbE4wdzDhWa/HYs+kh3NCvOdQKWn+UR2FdRNnA0Sc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=P1KDhAFBLUNiE9a3CmUaVdtGNfQJAFEhRocKudyIyrKi9Vt+30Khil9yWIVR5T6lL
         CoAEY547YRzSQoo0c7ciCLX3i4G46l7L3GkTMlkGFCw69rG3bTBxY3d+GieIWTCT3h
         I7mdRu1lk+E1kSUsOMQUlggvAhSKVtSSRZbz11Ew=
Date:   Tue, 29 Jun 2021 14:37:41 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, dai.ngo@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: automatic freeing of space on ENOSPC
Message-ID: <20210629183741.GC1926@fieldses.org>
References: <20210628194908.GB6776@fieldses.org>
 <20210629051149.GP2419729@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210629051149.GP2419729@dread.disaster.area>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jun 29, 2021 at 03:11:49PM +1000, Dave Chinner wrote:
> On Mon, Jun 28, 2021 at 03:49:08PM -0400, J. Bruce Fields wrote:
> > The NFS server currently revokes a client's state if the client fails to
> > contact it within a lease period (90 seconds by default).  That's
> > harsher than necessary--if a network partition lasts longer than a lease
> > period, but if nobody else needs that client's resources, it'd be nice
> > to be able to hang on to them so that the client could resume normal
> > operation after the network comes back.  So we'd delay revoking the
> > client's state until there's an actual conflict.  But that means we need
> > a way to clean up the client as soon as there is a conflict, to avoid
> > unnecessarily failing operations that conflict with resources held by an
> > expired client.
> 
> I'm not sure what you are asking for filesystems to do here.  This
> seems like an application problem - revoking the client's open file
> state and cleaning up silly rename files is application level
> garbage collection, not filesystem level stuff.

Right, the "application" in this case is knfsd.  It may be keeping some
unlinked files around that it doesn't really need to.  So I'm basically
wondering if I could get a notification from the filesystem that now
would be a good time to close those files.

I think Neil's convinced me this isn't a priority, though....

--b.
