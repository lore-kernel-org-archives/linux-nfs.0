From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Fix /proc/net/rpc/auth.unix.ip/content output [Was Re:
	stuff]
Date: Mon, 12 May 2008 10:15:15 +1000
Message-ID: <18471.35859.781495.449872@notabene.brown>
References: <20080509192319.GG1907@fieldses.org>
	<20080509204807.GI1907@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Cc: linux-nfs@vger.kernel.org,
	Aurelien Charbon <aurelien.charbon@bull.net>,
	Brian Haley <brian.haley@hp.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:37943 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbYELAP1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 May 2008 20:15:27 -0400
In-Reply-To: message from J. Bruce Fields on Friday May 9
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday May 9, bfields@fieldses.org wrote:
> Um, sorry about that subject line.

I liked it ;-)  Gave a bit of an informal feel....


>=20
> On Fri, May 09, 2008 at 03:23:19PM -0400, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> >=20
> > Commit f15364bd4cf8799a7677b6daeed7b67d9139d974 ("IPv6 support for =
NFS
> > server export caches") dropped a couple spaces, rendering the outpu=
t
> > here difficult to read.
> >=20
> > (However note that we expect the output to be parsed only by humans=
, not
> > machines, so this shouldn't have broken any userland software.)
> >=20
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > Cc: Aurelien Charbon <aurelien.charbon@bull.net>
> > Cc: Neil Brown <neilb@suse.de>
> > Cc: Brian Haley <brian.haley@hp.com>
> > Cc:  YOSHIFUJI Hideaki / =E5=90=1B(Ih=1B$(O$h=8B=B1=E6=98=8E=1B(B <=
yoshfuji@linux-ipv6.org>
> >=20
> > ---
> >  net/sunrpc/svcauth_unix.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >=20
> > I just noticed this while doing some debugging at Connectathon.  I'=
m
> > undecided whether to take it seriously.  Does anyone other than me =
use
> > these /content files?  I suppose it should probably go into 2.6.26 =
but
> > not 2.6.25.x.

I don't think any code uses them, but it's very good to be able to
look at them when something doesn't seem to be working as expected.

But I don't think the patch would apply to 2.6.25.  'git name-rev' on
the offending commit say:

f15364bd4cf8799a7677b6daeed7b67d9139d974 tags/v2.6.26-rc1~1083^2~47

which means it was in 2.6.26-rc1 but not the previous release.

NeilBrown
