Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:39468 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab0K0K1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 27 Nov 2010 05:27:39 -0500
Date: Sat, 27 Nov 2010 02:27:32 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Bryan Schumaker <bjschuma@netapp.com>, rees@umich.edu
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache
	array" is bad
Message-ID: <20101127102732.GD12175@hostway.ca>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange> <1290794726.4905.8.camel@heimdal.trondhjem.org> <20101127002548.GA20008@hostway.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101127002548.GA20008@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 26, 2010 at 04:25:48PM -0800, Simon Kirby wrote:

> On Fri, Nov 26, 2010 at 01:05:26PM -0500, Trond Myklebust wrote:
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
> Sorry, it's NFSv3.  We still need to fix the ID mapper's ability to work
> with libnss-mysql-bg before we can try NFSv4.  I went trying to track
> down the inodes on the server, but didn't get very far.  Would this still
> be helpful?

Ok, so I tracked them down, and they didn't seem to be particularly
unusual, so I tried a not-particularly-unusual thing that I figured might
work, and reproduced it:

server: echo test > a
client: ls -l
server: echo test > b ; mv b a
client: ls -l

That's it.  The kernel (2.6.37-rc3), on the final "ls -l", says:

[12814.611197] NFS: server 10.10.52.228 error: fileid changed
[12814.611200] fsid 0:3f: expected fileid 0x122efbf1, got 0x122efc15

"ls -li" shows the inode updated, so maybe this isn't even a bug?

Simon-
