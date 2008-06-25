From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] NFS performance debugging
Date: Wed, 25 Jun 2008 09:20:51 -0400
Message-ID: <1214400051.7225.4.camel@localhost>
References: <200806231659.58158@fortytwo.ch>
	<200806241217.29243@fortytwo.ch> <20080624202931.GA22757@fieldses.org>
	<200806250902.42880@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41644 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024AbYFYNVH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2008 09:21:07 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBUvp-0003be-TS
	for linux-nfs@vger.kernel.org; Wed, 25 Jun 2008 23:21:05 +1000
In-Reply-To: <200806250902.42880-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-25 at 09:02 +0200, Adrian von Bidder wrote:
> On Tuesday 24 June 2008 22.29:31 J. Bruce Fields wrote:
> > On Tue, Jun 24, 2008 at 12:17:24PM +0200, Adrian von Bidder wrote:
> 
> > > Starting KDE, opening documents, sometimes also closing oo.org and
> > > saving documents takes several seconds longer than on local disk.
> >
> > "close" on nfs is an operation that requires a round-trip to the server
> > and waiting for the disk to commit any writes made before the close, so
> > if you've got to do a lot of those it can take time.  Fooling with the
> > journaling on the exported filesystem may help.
> 
> Are there tools to measure latencies on NFS?  Given a network dump, desired 
> output would be histograms of latencies by file operation?  (Or maybe I can 
> catch the information on the client, VFS side instead of NFS?

You can catch the info on the client. See the 'nfs-iostat' tool in the
latest nfs-utils git tree:

  http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=summary

Trond


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

