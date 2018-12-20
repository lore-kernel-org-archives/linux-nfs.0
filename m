Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADBC4C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:24:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7551C2186A
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:24:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545319482;
	bh=9q3cIEO0qYjmzf7y4KJz1fzRqV3CjEMbwB4PEQFWmxY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=JA3pNUMmeYlNLjVKpuHEJS8S1Il4YL9PV4/nR1W86LySlaE9rjqWGTGEu5NwUtlDW
	 pKv8Du4316sJt0OhlPKfZLtei+42F4CGhM4NfHe0R1fKAJ0dYYLOJWNgcsXAYWjK4H
	 0pUAfNVckNqjLQvM4dpptcAdpyQeP3+3oFpX8vL8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730289AbeLTPYl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 10:24:41 -0500
Received: from mail.kernel.org ([198.145.29.99]:51668 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729211AbeLTPYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 10:24:41 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 59EDD21852;
        Thu, 20 Dec 2018 15:24:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545319480;
        bh=9q3cIEO0qYjmzf7y4KJz1fzRqV3CjEMbwB4PEQFWmxY=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=W2aLoWiU7dClSvgxhng7HT6QZnUbDpudxPIW+kB8DZwHsAnu2mNmIJ7p31S2B7UFw
         43T7Al04jzM5v8vEWXtmieFz1ytrPvTtqOR6HSPWNeR1KeezZNX6byGtBY1ljDYQox
         SmUTCLbmfZoTF93st3FtD6zgXA15aQLUGOR1HtqA=
Message-ID: <8865f5319bd793de33938c58a74e20826dfdcc88.camel@kernel.org>
Subject: Re: [PATCH v2 2/3] nfsd: un-deprecate nfsdcld
From:   Jeff Layton <jlayton@kernel.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Date:   Thu, 20 Dec 2018 10:24:28 -0500
In-Reply-To: <20181220015934.GC31570@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
         <20181218142926.27933-3-smayhew@redhat.com>
         <04e5de8ca245ee9d2fc9607690ff87b763ab5fde.camel@kernel.org>
         <20181219221118.GT27213@coeurl.usersys.redhat.com>
         <89285646ae8755f94cffb5a389ec19a7eeed0fd6.camel@kernel.org>
         <20181220015934.GC31570@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2018-12-19 at 20:59 -0500, J. Bruce Fields wrote:
> On Wed, Dec 19, 2018 at 07:19:53PM -0500, Jeff Layton wrote:
> > On Wed, 2018-12-19 at 17:11 -0500, Scott Mayhew wrote:
> > > On Wed, 19 Dec 2018, Jeff Layton wrote:
> > > > It seems like we probably ought to check to see if the daemon is up
> > > > before attempting a UMH upcall now? If someone starts up the daemon
> > > > they'll probably be surprised that it didn't get used because there was
> > > > a UMH upcall program present.
> > > 
> > > I figured that the UMH upcall program would still be the default and
> > > that the admin would have to do some extra configuration to use nfsdcld,
> > > namely remove the /var/lib/nfs/v4recovery directory and set an empty
> > > value for nfsd's 'cltrack_prog' module option.  Do you think that's a
> > > bad idea?
> > > 
> > > -Scott
> > > 
> > 
> > The only real issue there is that that is several steps, any of which
> > someone could screw up. I think we probably do want to aim for allowing
> > someone to enable nfsdcld (via systemd or whatever) and have it all
> > "just work" without needing to do anything else.
> 
> If we just care about being able to set this up for users, the rpm (or
> other package) install could remove /var/lib/nfs/v4recovery, drop a
> configuration file in /etc/modprobe.d to set cltrack_prog, and enable a
> systemd unit.
> 
> But you're thinking somebody might want to switch a system back and
> forth?  I guess that could be useful for debugging and, yeah the
> multiple steps would be more error prone.
> 

Yes.

That said, you wouldn't have compatible databases when switching back
(and I don't think we want to try to handle that case automatically
anyhow). At the very least though, I think we need to shoot for seamless
migration from legacy or umh upcalls to nfsdcld.

> > Assuming that daemon works better and in more places than the umh
> > helper, should we aim for it to eventually become the default?
> 
> I hope so.  If we have to switch this again I'm going to quit and go
> into some other business....
> 

Indeed!

Given that, we should be quite careful about introducing this. How do we
make that seamless for the vast majority of users who are just doing
simple serving and won't likely be downgrading?

Part of that may mean reworking the upcall method selection, so I'd like
to get that part hashed out before we merge this.
-- 
Jeff Layton <jlayton@kernel.org>

