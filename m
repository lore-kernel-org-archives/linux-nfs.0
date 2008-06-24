From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS performance debugging
Date: Tue, 24 Jun 2008 16:29:31 -0400
Message-ID: <20080624202931.GA22757@fieldses.org>
References: <200806231659.58158@fortytwo.ch>
	<20080623192836.GI24373@fieldses.org>
	<200806241217.29243@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34792 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbYFXUb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2008 16:31:27 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBF9p-0000Jo-91
	for linux-nfs@vger.kernel.org; Wed, 25 Jun 2008 06:30:46 +1000
In-Reply-To: <200806241217.29243-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 24, 2008 at 12:17:24PM +0200, Adrian von Bidder wrote:
> Hi again,
> 
> Thanks for your replies (You too, Trond)

The custom around here is to leave everyone on the cc: line.

> 
> On Monday 23 June 2008 21.28:36 you wrote:
> 
> [... NFS performance ...]
> 
> > In what way exactly is it sluggish?
> 
> Starting KDE, opening documents, sometimes also closing oo.org and saving 
> documents takes several seconds longer than on local disk.

"close" on nfs is an operation that requires a round-trip to the server
and waiting for the disk to commit any writes made before the close, so
if you've got to do a lot of those it can take time.  Fooling with the
journaling on the exported filesystem may help.

> Certainly network latency (especially with these silly lots of small config 
> files) takes some time, but I'm still surprised.  At the same time, I don't 
> have data to compare a "known good" NFS against ours, so perhaps NFS is 
> indeed so slow?
> 
> >
> > > tcpdump shows many "reply ERR 1448" etc. msgs whenever NFS activitiy is
> > > going on (both stat like with "find /home" or read/write with dd)
> >
> > I'm afraid I don't know how to read that tcpdump output.
> 
> tcpdump "-vvv" doesn't give more information on these packets; at the same 
> time wireshark doesn't show anything suspicious except tons of wrong TCP 
> checksums caused (I hope...) by offloading.

Yes, that's normal.

> I'll have to look if I can get 
> the raw traffic at the network switch to check this (but I think with 30% 
> and more wrong tcp checksums, traffic would completely break down so I'm 
> quite confident here.)
> 
> 
> Slightly different topic: is there an NFS related mailing list I can 
> subscribe to?  This one is apparently closed for new subscribers, and the 
> bounce instructs me to send mail to majordomo-MogPR669STc76Z2rM5mHXA@public.gmane.org which 
						^^^^
						vger

Where'd the typo in that address get introduced?

> bounces :-(  Reading others' NFS postings might just give me more ideas on 
> where to look.

Should be: http://vger.kernel.org/vger-lists.html#linux-nfs

> TODO today: play around with NFSv4 on the shaky assumption that nfsv3 is 
> actually working but net latency is killing my performance.

Delegations *might* help if the problem is really open latency.

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

