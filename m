From: "NeilBrown" <neilb@suse.de>
Subject: Re: [NFS] the infamous" device is busy" bug
Date: Sat, 14 Jun 2008 10:59:11 +1000 (EST)
Message-ID: <53236.192.168.1.70.1213405151.squirrel@neil.brown.name>
References: <mailman.32188.1213350650.3945.nfs@lists.sourceforge.net>
	<p06240404c478afa53f34@[129.98.90.227]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Maurice Volaski" <mvolaski-Q33DkHiyi7z2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34315 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757596AbYFNA7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 20:59:34 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K7K79-0006os-Lp
	for linux-nfs@vger.kernel.org; Sat, 14 Jun 2008 10:59:31 +1000
In-Reply-To: <p06240404c478afa53f34@[129.98.90.227]>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, June 14, 2008 9:22 am, Maurice Volaski wrote:
> I'm running 2.6.25-gentoo-r1 on an AMD 64 box along with
> nfs-utils-1.1.2-r1 and I have /var/lib/nfs symlinked to a separate
> filesystem, /database/nfs
>
> Now the system is running drbd and heartbeat and /database is on
> drbd, so that if the server fails, the secondary server will be able
> to immediately take over nfs using the identical data on its
> /database/nfs.
>
> If, however, I want to manually stop heartbeat on the primary server,
> I cannot because /database will not umount, complaining "the device
> is busy". I've tried to manually by shutting down all things nfs, but
> something is still holding it, and nfsd in the kernel is the culprit.
> I tested that by loading the module and from that point forward,
> trying to unmount /database just results in the "device is busy"
> complaint. That means the only way I can shutdown heartbeat is to
> physically shut down the server.

If nfsd is keeping the filesystem active, then
   exportfs -f
should release it, though if there are active clients, one could grab it
again very quickly.
Alternately
   rpc.nfsd 0
   exportfs -f
   umount
   rpc.nfsd 16

NeilBrown



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

