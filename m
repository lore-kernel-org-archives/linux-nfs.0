Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B83C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 23:18:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A216218A1
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 23:18:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727489AbfCNXSe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 19:18:34 -0400
Received: from mx1.redhat.com ([209.132.183.28]:59950 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727412AbfCNXSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 19:18:34 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F1FBF30AA38A;
        Thu, 14 Mar 2019 23:18:33 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D4E6A6BF6C;
        Thu, 14 Mar 2019 23:18:33 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 81C3B213F8; Thu, 14 Mar 2019 19:18:33 -0400 (EDT)
Date:   Thu, 14 Mar 2019 19:18:33 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 0/4] nfs4.1: add a bunch of reboot tests
Message-ID: <20190314231833.GX4975@coeurl.usersys.redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
 <20190314214832.GC1431@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314214832.GC1431@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 14 Mar 2019 23:18:34 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 14 Mar 2019, J. Bruce Fields wrote:

> On Thu, Mar 14, 2019 at 05:12:06PM -0400, Scott Mayhew wrote:
> > (Note: These patches go on top of "nfs4.1: clean up the session and
> > client created in Environment.init()" from Jeff Layton sent on March
> > 14th).
> 
> That was yours, wasn't it?  Applied, anyway.

No, my patch modified Environment.finish().  Jeff's modifies
Environment.init().  You'll need his patch too or these tests won't
work.

-Scott

> 
> > These patches add the following reboot tests:
> 
> Those look like good ideas, I've applied the patches.
> 
> The one thing I notice on a quick skim is that REBT5 depends on Linux
> knfsd-specific behavior.  That's worth noting in a comment.
> 
> (Also maybe we should add a flag to such tests.  "knfsd"?  We've got
> some tests flagged "ganesha".)
> 
> --b.
> 
> > 
> > REBT2x: Server reboot with N clients reclaiming opens.
> > REBT3x: Server reboot with N clients reclaming opens.  Server reboots
> >         again after half the clients have reclaimed.
> > REBT4x: Server reboot with N clients reclaiming opens.  Half the
> >         clients attempt to reclaim twice.
> > (where x in {a, b, c}, with 'a' using 10 clients, 'b' using 100 clients,
> > and 'c' testing 1000 clients)
> > REBT5:  Server reboot where the client starts reclaiming shortly before
> >         the end of grace.
> > 
> > Note all of these tests require the use of a helper script or manual
> > intervention to restart the server.
> > 
> > Scott Mayhew (4):
> >   nfs4.1: add some reboot tests
> >   nfs4.1: add some more reboot tests
> >   nfs4.1: still more reboot tests
> >   nfs4.1: test delayed reclaim following a server reboot
> > 
> >  nfs4.1/server41tests/st_reboot.py | 284 +++++++++++++++++++++++++++++-
> >  1 file changed, 278 insertions(+), 6 deletions(-)
> > 
> > -- 
> > 2.17.2
