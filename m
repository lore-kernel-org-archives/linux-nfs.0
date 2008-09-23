From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Tue, 23 Sep 2008 13:03:45 -0400
Message-ID: <20080923170344.GC2700@fieldses.org>
References: <20080912224323.GN22126@fieldses.org> <48CAF80A.4010109@opengridcomputing.com> <1221296243.2534.7.camel@localhost.localdomain> <1221544139.2534.18.camel@localhost.localdomain> <48CF9AC3.6060801@opengridcomputing.com> <1221577412.28572.60.camel@zakaz.uk.xensource.com> <48CFD7C3.5080207@opengridcomputing.com> <1221582285.28572.67.camel@zakaz.uk.xensource.com> <1222156770.6869.13.camel@localhost.localdomain> <1222169589.6869.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60422 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707AbYIWRED (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2008 13:04:03 -0400
In-Reply-To: <1222169589.6869.20.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:33:09PM +0100, Ian Campbell wrote:
> On Tue, 2008-09-23 at 08:59 +0100, Ian Campbell wrote:
> > I've found that the problem was backported into the stable stream since
> > I cannot reproduce the issue with 2.6.26 but I can with 2.6.26.5. This
> > is quite useful since there are only 3 relevant looking changesets in
> > that range. I will bisect between these before confirming the culprit on
> > mainline.

Could you double-check that this is reproduceable with this commit
applied, and not reproduceable when it's not?

I suppose it's not impossible that this could be triggering the problem
in some very roundabout way, but it seems a bit out of left field--so I
wonder whether one of the bisection points could have gotten marked good
when it should have been bad, or vice-versa.

> It reports:
> 
>         daedfbe2a67628a40076a6c75fb945c60f608a2e is first bad commit
>         commit daedfbe2a67628a40076a6c75fb945c60f608a2e
>         Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>         Date:   Wed Jun 11 17:39:04 2008 -0400
>         
>             NFS: Ensure we zap only the access and acl caches when setting new acls
>             
>             commit f41f741838480aeaa3a189cff6e210503cf9c42d upstream
>             
>             ...and ensure that we obey the NFS_INO_INVALID_ACL flag when retrieving the
>             acls.
>             
>             Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>             Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> I'm just about to build f41f741838480aeaa3a189cff6e210503cf9c42d and the
> one before and try those.
> 
> I'm not using ACLs as far as I am aware.

I think commands like "ls" try to get posix acls these days, so it's
possible that the nfs3_proc_getacl code at least might be getting
called.  Why that would matter I can't see.

--b.
