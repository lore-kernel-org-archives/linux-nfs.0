Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6508C433EF
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Sep 2021 14:41:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A41C2604AC
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Sep 2021 14:41:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229868AbhIQOm5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Sep 2021 10:42:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39202 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229942AbhIQOm5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2021 10:42:57 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 42ADAC061574
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2021 07:41:35 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 21353702A; Fri, 17 Sep 2021 10:41:34 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 21353702A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1631889694;
        bh=EBJ0zK60OXNpwyBsAwZLMhfhzM1La6+umwhOyctMi+I=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=QCPlz9ymTjzZxD1E3nsXRfIoiSpnO+IuyIP+7kxuIwwdicNGGRTuT32nKJoGpiEg4
         OvWPvLsF9S5MApu9SIutKIhGgOLsXzj+1XfJQkjsvkmPhZCvYmwcjVxGHuCD0fiuuH
         BulIMWQjQwbaHqmtx7rz8DBLWCiQOfVDLbgcOUaM=
Date:   Fri, 17 Sep 2021 10:41:34 -0400
To:     Mike Javorski <mike.javorski@gmail.com>
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Mel Gorman <mgorman@suse.com>, Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS server regression in kernel 5.13 (tested w/ 5.13.9)
Message-ID: <20210917144134.GA3075@fieldses.org>
References: <CAOv1SKANNnAQms8mGJzTAW4dDWTF=EeCWM0tQJNiGQ=7Jekqzg@mail.gmail.com>
 <A4BF67CE-BD6A-4B23-A5E2-5B71EDEF0EDD@oracle.com>
 <CAOv1SKAKs=2yjdjJxuuFDib3FJJsXmSgqqyrXaamoj864ifH2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOv1SKAKs=2yjdjJxuuFDib3FJJsXmSgqqyrXaamoj864ifH2A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Sep 16, 2021 at 12:21:28PM -0700, Mike Javorski wrote:
> Thanks for the insight Chuck. I will give it a bit more time as you
> suggest; I will ask if the arch devs can pull in the fix to their
> kernel in the meantime.
> I didn't see anyone making "backport fixes" requests in the stable
> list archive recently, so it doesn't seem to be the norm, but I don't
> see any other methods.

Yes, I think you just send them mail.

But like Chuck says they're probably just working through a bit of a
backlog.

--b.

> 
> - mike
> 
> On Thu, Sep 16, 2021 at 11:58 AM Chuck Lever III <chuck.lever@oracle.com> wrote:
> >
> >
> >
> > > On Sep 15, 2021, at 10:45 PM, Mike Javorski <mike.javorski@gmail.com> wrote:
> > >
> > > Chuck:
> > >
> > > I see that the patch was merged to Linus' branch, but there have been
> > > 2 stable patch releases since and the patch hasn't been pulled in.
> >
> > The v5.15 merge window just closed on Monday. I'm sure there is a
> > long queue of fixes to be pulled into stable. I'd give it more time.
> >
> >
> > > You
> > > mentioned I should reach out to the stable maintainers in this
> > > instance, is the stable@vger.kernel.org list the appropriate place to
> > > make such a request?
> >
> > That could be correct, but the automated process has worked for me
> > long enough that I'm no longer sure how to make such a request.
> >
> > --
> > Chuck Lever
> >
> >
> >
