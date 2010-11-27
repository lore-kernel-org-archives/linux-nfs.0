Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:57991 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab0K0BlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Nov 2010 20:41:12 -0500
Date: Fri, 26 Nov 2010 17:41:08 -0800
From: Simon Kirby <sim@hostway.ca>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Bryan Schumaker <bjschuma@netapp.com>, rees@umich.edu
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache
	array" is bad
Message-ID: <20101127014108.GB20008@hostway.ca>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange> <1290794726.4905.8.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.1011261923330.16655@axis700.grange>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.64.1011261923330.16655@axis700.grange>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 26, 2010 at 07:34:10PM +0100, Guennadi Liakhovetski wrote:

> On Fri, 26 Nov 2010, Trond Myklebust wrote:
> 
> > On Fri, 2010-11-26 at 13:05 +0100, Guennadi Liakhovetski wrote:
> > > Hi all
> > > 
> > > I've bisected the problem, reported several times before:
> > > 
> > > http://www.spinics.net/lists/linux-nfs/msg17208.html
> > > http://www.spinics.net/lists/linux-nfs/msg17298.html
> > > 
> > > (authors cc'ed) and also causing reproducibly problems on my sh7724 SuperH 
> > > and sh7372 ARM Debian systems. Commit
> > > 
> > > commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
> > > Author: Bryan Schumaker <bjschuma@netapp.com>
> > > Date:   Fri Sep 24 14:48:42 2010 -0400
> > > 
> > >     NFS: add readdir cache array
> > > 
> > > can be verified to be the culprit. Would be nice, if the other two 
> > > reporters could also verify this commit. Or is there already a fix 
> > > available?
> > > 
> > 
> > That patch removes readdirplus, and cannot therefore be responsible for
> > the fileid changed error that is reported in the emails below (which
> > does not occur when mounting with -onordirplus). It introduces a bunch
> > of other bugs (most which have been fixed), but not that one.
> > 
> > I've asked Simon for info about which NFS versions he is seeing this
> > with. He has not replied so far, but if you are seeing the same bug,
> > then I'd appreciate the same info.
> > Does the fileid bug occur with NFSv3 and NFSv4 or is it limited to one
> > or the other?
> 
> v3 here. As for errors - as I bisected, I didn't specifically watch out 
> for the "fileid" bug. There are a couple of warnings appearing, of which 
> "fileid" is just one. It is quite possible, that as I've found this 
> commit, the actual bug(s) that it introduces are different ones. For me it 
> is just "NFS works before this commit" and "NFS stops working reliably 
> after it." Symptoms vary indeed. Apart from "fileid" I'm also getting 
> warnings like
> 
> nfs_update_inode: inode 297450 mode changed, 0100005 to 0120777
> 
> Sometimes also there are no warnings, the action, currently in progress 
> (like apt-get or ldconfig) just hangs forever, consuming CPU and thrushing 
> the network.

My report was the first one, but I'm actually seeing what seems to be
an improvement on 2.6.37-rc3 for that issue.  That post was complaining
about NFS getting stuck on 2.6.35 and 2.6.36.

However, I did report problems similar to the second post ("fileid
changed"), and "nordirplus" made them stop.  I am not sure if these two
problems are the same thing, since I've also seen an issue on 2.6.36 that
might be related to the hang issue ("flush" processes take all of the
CPU, NFS stuck, eventually recovers).  Do you see problems at all on
2.6.37 with the nordirplus mount option?

It sounds like your are using root on NFS, and some apt-get
upgrade/ldconfig type command is preproducing the issue?  Any guesses
on how to reproduce it with a simple testcase? :)

Simon-
