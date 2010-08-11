Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54486 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363Ab0HKXWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Aug 2010 19:22:42 -0400
Date: Thu, 12 Aug 2010 09:22:32 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Jim Rees <rees@umich.edu>,
        Daniel.Muntz@emc.com, linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100812092232.344314b2@notabene>
In-Reply-To: <20100805153421.GD27141@fieldses.org>
References: <201008030401.33552.dreck@vmsd.ath.cx>
	<20100803164318.GB13896@merit.edu>
	<20100803192216.GC31579@fieldses.org>
	<DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
	<20100803215704.GA15494@merit.edu>
	<1280873719.14520.17.camel@heimdal.trondhjem.org>
	<20100803222337.GA9752@fieldses.org>
	<1280874675.14520.23.camel@heimdal.trondhjem.org>
	<20100803224245.GB9752@fieldses.org>
	<1280887336.24669.23.camel@heimdal.trondhjem.org>
	<20100805153421.GD27141@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 5 Aug 2010 11:34:21 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Aug 03, 2010 at 10:02:16PM -0400, Trond Myklebust wrote:
> > On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
> > > On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
> > > > We know it has a bunch of problems,
> > > > not least the one that limits ngroups <= 16, and the fact that it relies
> > > > on uids (as opposed to login names) being the same on client and server
> > > > so why not try to fix those limitations?
> > > 
> > > Sure, that would be great.
> > > 
> > > Again, that doesn't address the complaints above.
> > 
> > Yes it does.
> 
> See the stated scenario:
> 
> 	http://marc.info/?l=linux-nfs&m=128080127215350&w=2
> 
> It's a dumb client making a copy of a filesystem over NFS for backup.
> 
> It's not true that this case could be dealt with by an auth_sys
> replacement that uses names instead of id's.
> 
> (You could argue that it's a hypothetical case, crazy, not important, or
> whatever--just not that it has much to do with the authentication
> flavor.
> 
> Personally I think it *is* of at least some importance, since anyone
> depending on that sort of behavior will see their systems stop working
> if they switch from v2/v3 to v4.  The v2/v3 install base being massive
> compared to v4's, the success of v4+ depends in part on reducing the
> chances of that kind of thing happening.)

I agree.  And surely it can all be solved in idmapd.

On the server, tell idmapd to map all users to "NUMERIC_USER:%d" and all
groups to "NUMERIC_GROUP:%d" (or whatever) for some given clients (i.e. stop
ignoring the 'authentication name'.  And of course map those names back to
numbers.

I don't know if the client can easily differentiate based on which server it
is talking to, but there is probably less need there (and maybe it can
anyway).

It shouldn't take more that half an hour to hack something into
idmapd.c:nfsdcb() for the server side and nfscb for the client side - or
for a quicker hack, just go directly to imconv and ignore the client name on
the server.  (all this in nfs-utils of course).

NeilBrown
