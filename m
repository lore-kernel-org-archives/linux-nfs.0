Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:38983 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557Ab3ADKOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2013 05:14:53 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Tr4Iq-0007gK-8G
	for linux-nfs@vger.kernel.org; Fri, 04 Jan 2013 11:15:04 +0100
Received: from p549E60A8.dip.t-dialin.net ([84.158.96.168])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 04 Jan 2013 11:15:04 +0100
Received: from mario.bachmann by p549E60A8.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 04 Jan 2013 11:15:04 +0100
To: linux-nfs@vger.kernel.org
From: Mario Bachmann <mario.bachmann@gmail.com>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Date: Fri, 4 Jan 2013 10:05:22 +0000 (UTC)
Message-ID: <loom.20130104T105915-661@post.gmane.org>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net> <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com> <20120419093025.GA2916@zeus> <20120419134847.GC2916@zeus> <1334856549.21419.48.camel@lade.trondhjem.org> <20120419204638.GB22948@zeus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Luis Henriques <luis.henriques@...> writes:

> 
> On Thu, Apr 19, 2012 at 05:29:09PM +0000, Myklebust, Trond wrote:
> > On Thu, 2012-04-19 at 14:48 +0100, Luis Henriques wrote:
> > > On Thu, Apr 19, 2012 at 10:30:25AM +0100, Luis Henriques wrote:
> > > > On Wed, Apr 18, 2012 at 01:36:52PM -0400, Trond Myklebust wrote:
> > > > > The first patch addresses the Oops.
> > > > > The second will hopefully address the looping.
> > > > > 
> > > > > Trond Myklebust (2):
> > > > >   NFSv4: Ensure that the LOCK code sets exception->inode
> > > > >   NFSv4: Ensure that we check lock exclusive/shared type against open
> > > > >     modes
> > > > > 
> > > > >  fs/nfs/nfs4proc.c |   23 +++++++++++++++++++++--
> > > > >  1 files changed, 21 insertions(+), 2 deletions(-)
I use kernel 3.7.1 from kernel.org which has the patches included, 
which should fix the problems (I checked the source code). But:
I get "NFS: nfs4_reclaim_open_state: Lock reclaim failed!" on the 
client, which mounts home over nfs4. 
I get senseless network traffic (50MB/s on my gigabit network). 
Finally I get Kernel Ops on the Server sometimes. 


