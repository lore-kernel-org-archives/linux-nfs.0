From: Greg KH <greg@kroah.com>
Subject: Re: [stable] nfsd changes for 2.6.34
Date: Wed, 21 Apr 2010 15:50:48 -0700
Message-ID: <20100421225048.GB27883@kroah.com>
References: <20100306175212.GB22650@fieldses.org>
 <20100324142414.GE12057@fieldses.org>
 <20100329182443.GC3778@kroah.com>
 <20100330144054.GD11545@fieldses.org>
 <20100330200320.GB1693@kroah.com>
 <20100331193029.GC4937@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-nfs@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:54167 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754787Ab0DUXPn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Apr 2010 19:15:43 -0400
In-Reply-To: <20100331193029.GC4937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 31, 2010 at 03:30:29PM -0400, J. Bruce Fields wrote:
> On Tue, Mar 30, 2010 at 01:03:20PM -0700, Greg KH wrote:
> > On Tue, Mar 30, 2010 at 10:40:54AM -0400, J. Bruce Fields wrote:
> > > On Mon, Mar 29, 2010 at 11:24:43AM -0700, Greg KH wrote:
> > > > On Wed, Mar 24, 2010 at 10:24:14AM -0400, J. Bruce Fields wrote:
> > > > > On Sat, Mar 06, 2010 at 12:52:12PM -0500, bfields wrote:
> > > > > > Please pull the following nfsd changes from the 'nfsd' branch at:
> > > > > > 
> > > > > >   git://linux-nfs.org/~bfields/linux.git for-2.6.34 nfsd
> > > > > > 
> > > > > > This is an unusually quiet cycle for the NFS server--bugfixes, some IPv6
> > > > > > progress, and one new export operation to improve sync performance.
> > > > > > 
> > > > > > One exception to the 'mostly quiet' statement was a regression in the
> > > > > > rpc code which hit a lot of people: enormous thanks to Neil for tracking
> > > > > > that down.
> > > > > 
> > > > > However, I forgot to Cc stable on all of those.  Stable people, could
> > > > > you also take the following three commits?:
> > > > > 
> > > > > 	f5822754ea006563e1bf0a1f43faaad49c0d8bb2 Revert "sunrpc: fix
> > > > > 	peername failed on closed listener"
> > > > > 	1b644b6e6f6160ae35ce4b52c2ca89ed3e356e18 Revert "sunrpc: move
> > > > > 	the close processing after do recvfrom method"
> > > > > 	301e99ce4a2f42a317129230fd42e6cd874c64b0 nfsd: ensure sockets
> > > > > 	are closed on error
> > > > > 
> > > > > Let me know if you need more information.
> > > > 
> > > > I've queued all of these up for the .33 -stable tree.  If any of them
> > > > need to go into .32 (maybe that last one?), please let me know.
> > > 
> > > Thanks; .32 needs all three of those.
> > 
> > Ok, care to backport them and send them to stable@kernel.org?  They
> > don't all apply cleanly from what I can see.
> 
> Huh.  I just checked out 2.6.32.10 and tried applying the patches a
> couple different ways, and the worst I got was stuff like:
> 
> 	patching file net/sunrpc/svc_xprt.c
> 	Hunk #1 succeeded at 711 (offset 5 lines).
> 
> Is that enough that you don't consider them clean?
> 
> In any case, I'll follow up with patches generated against 2.6.32.10.

You are right, I don't know what I did wrong, sorry.  I've now queued
all of these up for the next .32 tree, as they are already in
.33-stable.

thanks,

greg k-h
