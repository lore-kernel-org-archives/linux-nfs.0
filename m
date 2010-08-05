Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44423 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933600Ab0HEPfv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 11:35:51 -0400
Date: Thu, 5 Aug 2010 11:34:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com, linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100805153421.GD27141@fieldses.org>
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
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280887336.24669.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 10:02:16PM -0400, Trond Myklebust wrote:
> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
> > On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
> > > We know it has a bunch of problems,
> > > not least the one that limits ngroups <= 16, and the fact that it relies
> > > on uids (as opposed to login names) being the same on client and server
> > > so why not try to fix those limitations?
> > 
> > Sure, that would be great.
> > 
> > Again, that doesn't address the complaints above.
> 
> Yes it does.

See the stated scenario:

	http://marc.info/?l=linux-nfs&m=128080127215350&w=2

It's a dumb client making a copy of a filesystem over NFS for backup.

It's not true that this case could be dealt with by an auth_sys
replacement that uses names instead of id's.

(You could argue that it's a hypothetical case, crazy, not important, or
whatever--just not that it has much to do with the authentication
flavor.

Personally I think it *is* of at least some importance, since anyone
depending on that sort of behavior will see their systems stop working
if they switch from v2/v3 to v4.  The v2/v3 install base being massive
compared to v4's, the success of v4+ depends in part on reducing the
chances of that kind of thing happening.)

--b.
