From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Weird exportfs behavior
Date: Tue, 19 Jan 2010 16:10:15 -0500
Message-ID: <20100119211015.GA10048@fieldses.org>
References: <1263933130.2399.160.camel@moss-terrapins.epoch.ncsc.mil> <20100119204828.GJ5694@fieldses.org> <1263934773.2399.162.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53593 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755563Ab0ASVI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jan 2010 16:08:57 -0500
In-Reply-To: <1263934773.2399.162.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 19, 2010 at 03:59:33PM -0500, David P. Quigley wrote:
> On Tue, 2010-01-19 at 15:48 -0500, J. Bruce Fields wrote:
> > Looks like you have to modify both support/nfs/exports.c:putexportent()
> > and utils/exportfs/exportfs.c:dump(), in addition to parseopts().
> > (Which is really confusing.  Someone should fix that..) Maybe you're
> > forgetting one of those?
> > 
> > --b.
> 
> I'm almost certain I am. I'll look over my patches again to take a look
> at that. I also need to look over my update code for the kernel export
> function because I was getting the labelloc entry in /var/lib/nfs/etab
> on initial daemon start but subsequent exportfs options seem to make it
> go away.

You might have been missing code to parse it or store it in an export,
so it got lost before it wrote the entry back out again?  I don't know.

If you're feeling community-minded, that business with having two
entirely separate bits of code to write out an etab entry seems silly.
(Maybe there are two different formats, I'm forgetting, but if so
couldn't they at least share common code to lookup the string names of
the options?)

--b.
