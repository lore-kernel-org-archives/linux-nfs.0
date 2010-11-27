Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:42703 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752619Ab0K0AZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Nov 2010 19:25:54 -0500
Date: Fri, 26 Nov 2010 16:25:48 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Bryan Schumaker <bjschuma@netapp.com>, rees@umich.edu
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache
	array" is bad
Message-ID: <20101127002548.GA20008@hostway.ca>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange> <1290794726.4905.8.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290794726.4905.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 26, 2010 at 01:05:26PM -0500, Trond Myklebust wrote:

> On Fri, 2010-11-26 at 13:05 +0100, Guennadi Liakhovetski wrote:
> > Hi all
> > 
> > I've bisected the problem, reported several times before:
> > 
> > http://www.spinics.net/lists/linux-nfs/msg17208.html
> > http://www.spinics.net/lists/linux-nfs/msg17298.html
> > 
> > (authors cc'ed) and also causing reproducibly problems on my sh7724 SuperH 
> > and sh7372 ARM Debian systems. Commit
> > 
> > commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
> > Author: Bryan Schumaker <bjschuma@netapp.com>
> > Date:   Fri Sep 24 14:48:42 2010 -0400
> > 
> >     NFS: add readdir cache array
> > 
> > can be verified to be the culprit. Would be nice, if the other two 
> > reporters could also verify this commit. Or is there already a fix 
> > available?
> > 
> 
> That patch removes readdirplus, and cannot therefore be responsible for
> the fileid changed error that is reported in the emails below (which
> does not occur when mounting with -onordirplus). It introduces a bunch
> of other bugs (most which have been fixed), but not that one.
> 
> I've asked Simon for info about which NFS versions he is seeing this
> with. He has not replied so far, but if you are seeing the same bug,
> then I'd appreciate the same info.
> Does the fileid bug occur with NFSv3 and NFSv4 or is it limited to one
> or the other?

Sorry, it's NFSv3.  We still need to fix the ID mapper's ability to work
with libnss-mysql-bg before we can try NFSv4.  I went trying to track
down the inodes on the server, but didn't get very far.  Would this still
be helpful?

Some of the file handles do seem to have recurred in the errors:

# zfgrep -i 'expected fileid' kern.log kern.log.0 kern.log.?.gz | cut -f6- -d' ' | tail
[62767.492630] fsid 0:51: expected fileid 0x8dbd93c3, got 0x8dbd93aa
[62767.492777] fsid 0:51: expected fileid 0x8dbd93c4, got 0x8dbee995
[62767.492925] fsid 0:51: expected fileid 0x8dbd93c5, got 0x8db992b0
[62767.493074] fsid 0:51: expected fileid 0x8dbd93c6, got 0x8db992b3
[62767.493221] fsid 0:51: expected fileid 0x8dbd93c7, got 0x8db992c2
[62767.493370] fsid 0:51: expected fileid 0x8dbd93c8, got 0x8dbee99e
[62767.493518] fsid 0:51: expected fileid 0x8dbd93c9, got 0x8db992aa
[62767.493666] fsid 0:51: expected fileid 0x8dbd93ca, got 0x8db992ae
[62767.493818] fsid 0:51: expected fileid 0x8dbd93cb, got 0x8dbee996
[62768.125674] fsid 0:51: expected fileid 0x4e387db6, got 0x5dc463aa
# zfgrep -i 'expected fileid' kern.log kern.log.0 kern.log.?.gz | wc -l
1387
# zfgrep -i 'expected fileid' kern.log kern.log.0 kern.log.?.gz | cut -f1 -d, | cut -f3 -dx | sort | uniq -d | wc -l
222
# zfgrep -i 'expected fileid' kern.log kern.log.0 kern.log.?.gz | cut -f1 -d, | cut -f3 -dx | sort | uniq -d | tail
c27f7de0
c27f7de1
c2b3f216
c49cdbd9
c4dfde81
c7f6da82
c7f6da84
c7f6da85
c7f6da86
c7f6da87
# zfgrep -i 'expected fileid' kern.log kern.log.0 kern.log.?.gz | cut -f1 -d, | cut -f3 -dx | sort | uniq -c | sort -nr | head
     34 4d388eb6
     18 c49cdbd9
     17 c7f6da82
     13 c7f6da84
     13 80bf4a5e
     12 4f670322
     12 4e3a515b
     11 4d100339
     10 4dcd298a
     10 4dbfffa4

It looks like maybe a directory that is growing or shrinking or
something, and corruption is happening on a boundary somewhere.. It
definitely goes away wit "nordirplus".  XFS is hosting the FSes on the
server side, and all the ones I see here are just under 1 TB and thus not
using the XFS inode64 option.

I'll try to dig up those inodes.

Simon-
