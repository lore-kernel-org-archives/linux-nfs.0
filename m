Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:49612 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751798Ab0KZSeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Nov 2010 13:34:04 -0500
Date: Fri, 26 Nov 2010 19:34:10 +0100 (CET)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, Bryan Schumaker <bjschuma@netapp.com>,
        rees@umich.edu, sim@hostway.ca
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache array"
 is bad
In-Reply-To: <1290794726.4905.8.camel@heimdal.trondhjem.org>
Message-ID: <Pine.LNX.4.64.1011261923330.16655@axis700.grange>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange>
 <1290794726.4905.8.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond

On Fri, 26 Nov 2010, Trond Myklebust wrote:

> 
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

v3 here. As for errors - as I bisected, I didn't specifically watch out 
for the "fileid" bug. There are a couple of warnings appearing, of which 
"fileid" is just one. It is quite possible, that as I've found this 
commit, the actual bug(s) that it introduces are different ones. For me it 
is just "NFS works before this commit" and "NFS stops working reliably 
after it." Symptoms vary indeed. Apart from "fileid" I'm also getting 
warnings like

nfs_update_inode: inode 297450 mode changed, 0100005 to 0120777

Sometimes also there are no warnings, the action, currently in progress 
(like apt-get or ldconfig) just hangs forever, consuming CPU and thrushing 
the network.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
