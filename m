From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS performance debugging
Date: Wed, 25 Jun 2008 12:56:58 -0400
Message-ID: <20080625165658.GA12629@fieldses.org>
References: <200806231659.58158@fortytwo.ch> <200806241217.29243@fortytwo.ch>
	<20080624202931.GA22757@fieldses.org>
	<200806250902.42880@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34339 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbYFYQ5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2008 12:57:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBYIw-0004EO-J0
	for linux-nfs@vger.kernel.org; Thu, 26 Jun 2008 02:57:10 +1000
In-Reply-To: <200806250902.42880-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 25, 2008 at 09:02:42AM +0200, Adrian von Bidder wrote:
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
> 
> At this time, I really need to collect more data on where the problem is 
> since all I'm doing right now is fooling around based on assumptions... :-(
> 
> OTOH I'd suspect KDE/oo.org startup to be mostly reads of those config 
> files, so the problem shouldn't be close latencies.  Assumptions again.
> 
> > > TODO today: play around with NFSv4 on the shaky assumption that nfsv3
> > > is actually working but net latency is killing my performance.
> >
> > Delegations *might* help if the problem is really open latency.
> 
> First tries showed
>  * There are no acl on my files now

NFSv4 uses an entirely different type of ACL, for which you need
different client-side tools; see

	http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/

>  * user id mapping seems funny: some users map to nobody, others map 
> correctly.  Huh?

And whereas v2/v3 require only uid's and gid's to agree, v4 (if you're
using auth_sys) requires uid's, gid's, *and* user and group names to
agree.

--b.

>  * Performance seems to be ok (timing desktop applications is always 
> difficult, and so far I'm working against on the production server with 
> varying load anyway...)
> 
> Haven't investigated these yet...


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

