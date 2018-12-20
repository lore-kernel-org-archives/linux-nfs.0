Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51370C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:59:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 25BC820672
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:59:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728835AbeLTB7f (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 20:59:35 -0500
Received: from fieldses.org ([173.255.197.46]:47592 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729731AbeLTB7f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 20:59:35 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E24FC1C56; Wed, 19 Dec 2018 20:59:34 -0500 (EST)
Date:   Wed, 19 Dec 2018 20:59:34 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfsd: un-deprecate nfsdcld
Message-ID: <20181220015934.GC31570@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-3-smayhew@redhat.com>
 <04e5de8ca245ee9d2fc9607690ff87b763ab5fde.camel@kernel.org>
 <20181219221118.GT27213@coeurl.usersys.redhat.com>
 <89285646ae8755f94cffb5a389ec19a7eeed0fd6.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89285646ae8755f94cffb5a389ec19a7eeed0fd6.camel@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 19, 2018 at 07:19:53PM -0500, Jeff Layton wrote:
> On Wed, 2018-12-19 at 17:11 -0500, Scott Mayhew wrote:
> > On Wed, 19 Dec 2018, Jeff Layton wrote:
> > > It seems like we probably ought to check to see if the daemon is up
> > > before attempting a UMH upcall now? If someone starts up the daemon
> > > they'll probably be surprised that it didn't get used because there was
> > > a UMH upcall program present.
> > 
> > I figured that the UMH upcall program would still be the default and
> > that the admin would have to do some extra configuration to use nfsdcld,
> > namely remove the /var/lib/nfs/v4recovery directory and set an empty
> > value for nfsd's 'cltrack_prog' module option.  Do you think that's a
> > bad idea?
> > 
> > -Scott
> > 
> 
> The only real issue there is that that is several steps, any of which
> someone could screw up. I think we probably do want to aim for allowing
> someone to enable nfsdcld (via systemd or whatever) and have it all
> "just work" without needing to do anything else.

If we just care about being able to set this up for users, the rpm (or
other package) install could remove /var/lib/nfs/v4recovery, drop a
configuration file in /etc/modprobe.d to set cltrack_prog, and enable a
systemd unit.

But you're thinking somebody might want to switch a system back and
forth?  I guess that could be useful for debugging and, yeah the
multiple steps would be more error prone.

> Assuming that daemon works better and in more places than the umh
> helper, should we aim for it to eventually become the default?

I hope so.  If we have to switch this again I'm going to quit and go
into some other business....

--b.
