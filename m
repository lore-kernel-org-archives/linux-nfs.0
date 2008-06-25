From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] NFS performance debugging
Date: Wed, 25 Jun 2008 09:59:16 -0400
Message-ID: <48624F34.1070108@RedHat.com>
References: <200806231659.58158@fortytwo.ch>	<200806241217.29243@fortytwo.ch>
	<20080624202931.GA22757@fieldses.org>	<200806250902.42880@fortytwo.ch>
	<1214400051.7225.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44572 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbYFYN75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2008 09:59:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBVXP-0003gY-BI
	for linux-nfs@vger.kernel.org; Wed, 25 Jun 2008 23:59:55 +1000
In-Reply-To: <1214400051.7225.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2008-06-25 at 09:02 +0200, Adrian von Bidder wrote:
>> On Tuesday 24 June 2008 22.29:31 J. Bruce Fields wrote:
>>> On Tue, Jun 24, 2008 at 12:17:24PM +0200, Adrian von Bidder wrote:
>>>> Starting KDE, opening documents, sometimes also closing oo.org and
>>>> saving documents takes several seconds longer than on local disk.
>>> "close" on nfs is an operation that requires a round-trip to the server
>>> and waiting for the disk to commit any writes made before the close, so
>>> if you've got to do a lot of those it can take time.  Fooling with the
>>> journaling on the exported filesystem may help.
>> Are there tools to measure latencies on NFS?  Given a network dump, desired 
>> output would be histograms of latencies by file operation?  (Or maybe I can 
>> catch the information on the client, VFS side instead of NFS?
> 
> You can catch the info on the client. See the 'nfs-iostat' tool in the
> latest nfs-utils git tree:
One side note on the current state of the nfs-iostat tool... There is some talk 
about changing the name from 'nfs-iostat' to 'nfsiostat' so it will map better 
with the current command names that are in nfs-utils (i.e. no other commands
use have a '-' in their names). So at this point, even though the script is in the tree, 
its not being installed (via a make install) which allows us to make these types
of changes. 

But please do not let this caveat stop you from trying this script and
mountstats script. We definitely need feedback on how well they do or
don't work (and as always... patches are welcomed! ;-) ) Once things harden 
up (via any feedback), I'll added the install code to make these scripts be 
installed (probably in /usr/sbin) which means they will be ready for 
prime time... 

steved.



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

