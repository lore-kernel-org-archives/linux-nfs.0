From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS performance debuggins
Date: Mon, 23 Jun 2008 15:28:36 -0400
Message-ID: <20080623192836.GI24373@fieldses.org>
References: <200806231659.58158@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53692 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992AbYFWT3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 15:29:08 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KArir-0001bT-P8
	for linux-nfs@vger.kernel.org; Tue, 24 Jun 2008 05:29:05 +1000
In-Reply-To: <200806231659.58158-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2008 at 04:59:57PM +0200, Adrian von Bidder wrote:
> Hi,
> 
> Environment:
> 
> several Debian based clients (Debian etch and etchnhalf kernels, this means 
> 2.6.18 or 2.6.24); Debian etch (2.6.18 kernel) NFS (v3) server.  Network 
> seems basically ok ("ping -f -s 3000" works without losses, ifconfig and 
> switch monitoring shows no errors) with no noticeable load.  Disks seem to 
> have very little load either, NFS server has no other tasks.
> 
> Performance is sluggish :-(  Basically works, though -- no spurious errors.

In what way exactly is it sluggish?

> tcpdump shows many "reply ERR 1448" etc. msgs whenever NFS activitiy is 
> going on (both stat like with "find /home" or read/write with dd)

I'm afraid I don't know how to read that tcpdump output.

--b.

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

