Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:59875 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756783Ab1FUQZL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2011 12:25:11 -0400
From: Ruediger Meier <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] manpage: add info about IPv6 configuration to exports(5) (try #2)
Date: Tue, 21 Jun 2011 18:25:07 +0200
References: <1308665441-16704-1-git-send-email-jlayton@redhat.com> <20110621160057.GC25534@fieldses.org> <20110621120704.3b256de4@tlielax.poochiereds.net>
In-Reply-To: <20110621120704.3b256de4@tlielax.poochiereds.net>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201106211825.08240.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 21 June 2011, Jeff Layton wrote:
> On Tue, 21 Jun 2011 12:00:57 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Tue, Jun 21, 2011 at 10:10:41AM -0400, Jeff Layton wrote:
> > >  /srv/www        \-sync,rw server @trusted @external(ro)
> > > +/foo            2001:321:9:e54::/64(rw) 192.168.1.0/24(rw)
> >
> > (Any reason for that particular example address?  Just curious.)
> >
> > --b.
>
> Nope -- pulled that out of my nether regions.

To make it perfect you could use address blocks reserved for 
documentation. For example
2001:DB8::/32
and
192.0.2.0/24

see rfc 3849 and 5737

http://tools.ietf.org/html/rfc3849
http://tools.ietf.org/html/rfc5737

cu,
Rudi
