Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab1FURJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 13:09:40 -0400
Date: Tue, 21 Jun 2011 13:09:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ruediger Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] manpage: add info about IPv6 configuration to
 exports(5) (try #2)
Message-ID: <20110621130935.0bd6751e@tlielax.poochiereds.net>
In-Reply-To: <201106211825.08240.sweet_f_a@gmx.de>
References: <1308665441-16704-1-git-send-email-jlayton@redhat.com>
	<20110621160057.GC25534@fieldses.org>
	<20110621120704.3b256de4@tlielax.poochiereds.net>
	<201106211825.08240.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 21 Jun 2011 18:25:07 +0200
Ruediger Meier <sweet_f_a@gmx.de> wrote:

> On Tuesday 21 June 2011, Jeff Layton wrote:
> > On Tue, 21 Jun 2011 12:00:57 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Tue, Jun 21, 2011 at 10:10:41AM -0400, Jeff Layton wrote:
> > > >  /srv/www        \-sync,rw server @trusted @external(ro)
> > > > +/foo            2001:321:9:e54::/64(rw) 192.168.1.0/24(rw)
> > >
> > > (Any reason for that particular example address?  Just curious.)
> > >
> > > --b.
> >
> > Nope -- pulled that out of my nether regions.
> 
> To make it perfect you could use address blocks reserved for 
> documentation. For example
> 2001:DB8::/32
> and
> 192.0.2.0/24
> 
> see rfc 3849 and 5737
> 
> http://tools.ietf.org/html/rfc3849
> http://tools.ietf.org/html/rfc5737
> 
> cu,
> Rudi

Good idea. I'll change those and respin the patch.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
