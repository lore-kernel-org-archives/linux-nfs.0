Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF435C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 01:00:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9729C2085A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 01:00:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728261AbfCOBAh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 21:00:37 -0400
Received: from fieldses.org ([173.255.197.46]:32852 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728260AbfCOBAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 21:00:37 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id EFF421C84; Thu, 14 Mar 2019 21:00:36 -0400 (EDT)
Date:   Thu, 14 Mar 2019 21:00:36 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 0/4] nfs4.1: add a bunch of reboot tests
Message-ID: <20190315010036.GD1431@fieldses.org>
References: <20190314211210.7454-1-smayhew@redhat.com>
 <20190314214832.GC1431@fieldses.org>
 <20190314231833.GX4975@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314231833.GX4975@coeurl.usersys.redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 14, 2019 at 07:18:33PM -0400, Scott Mayhew wrote:
> On Thu, 14 Mar 2019, J. Bruce Fields wrote:
> 
> > On Thu, Mar 14, 2019 at 05:12:06PM -0400, Scott Mayhew wrote:
> > > (Note: These patches go on top of "nfs4.1: clean up the session and
> > > client created in Environment.init()" from Jeff Layton sent on March
> > > 14th).
> > 
> > That was yours, wasn't it?  Applied, anyway.
> 
> No, my patch modified Environment.finish().  Jeff's modifies
> Environment.init().  You'll need his patch too or these tests won't
> work.

Whoops, sorry.

I don't see that mail from Jeff anywhere.  Would someone mind resending?

--b.

> 
> -Scott
> 
> > 
> > > These patches add the following reboot tests:
> > 
> > Those look like good ideas, I've applied the patches.
> > 
> > The one thing I notice on a quick skim is that REBT5 depends on Linux
> > knfsd-specific behavior.  That's worth noting in a comment.
> > 
> > (Also maybe we should add a flag to such tests.  "knfsd"?  We've got
> > some tests flagged "ganesha".)
> > 
> > --b.
> > 
> > > 
> > > REBT2x: Server reboot with N clients reclaiming opens.
> > > REBT3x: Server reboot with N clients reclaming opens.  Server reboots
> > >         again after half the clients have reclaimed.
> > > REBT4x: Server reboot with N clients reclaiming opens.  Half the
> > >         clients attempt to reclaim twice.
> > > (where x in {a, b, c}, with 'a' using 10 clients, 'b' using 100 clients,
> > > and 'c' testing 1000 clients)
> > > REBT5:  Server reboot where the client starts reclaiming shortly before
> > >         the end of grace.
> > > 
> > > Note all of these tests require the use of a helper script or manual
> > > intervention to restart the server.
> > > 
> > > Scott Mayhew (4):
> > >   nfs4.1: add some reboot tests
> > >   nfs4.1: add some more reboot tests
> > >   nfs4.1: still more reboot tests
> > >   nfs4.1: test delayed reclaim following a server reboot
> > > 
> > >  nfs4.1/server41tests/st_reboot.py | 284 +++++++++++++++++++++++++++++-
> > >  1 file changed, 278 insertions(+), 6 deletions(-)
> > > 
> > > -- 
> > > 2.17.2
