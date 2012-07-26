Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52329 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab2GZWgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jul 2012 18:36:11 -0400
Date: Thu, 26 Jul 2012 18:36:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120726223607.GA28982@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120724143748.GC8570@fieldses.org>
 <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 05:28:02PM +0000, ZUIDAM, Hans wrote:
> Hi Bruce,
> 
> Thanks for the clarification.
> 
> (I'm repeating a lot of my original mail because of the Cc: list.)
> 
> > J. Bruce Fields
> > I think that's right, though I'm curious how you're managing to hit
> > that case reliably every time.  Or is this an intermittent failure?
> It's an intermittent failure, but with the procedure shown below it is
> fairly easy to reproduce.    The actual problem we see in our product
> is because of the way external storage media are handled in user-land.
> 
>         192.168.1.10# mount -t xfs /dev/sdcr/sda1 /mnt
>         192.168.1.10# exportfs 192.168.1.11:/mnt
> 
>         192.168.1.11# mount 192.168.1.10:/mnt /mnt
>         192.168.1.11# umount /mnt
> 
>         192.168.1.10# exportfs -u 192.168.1.11:/mnt
>         192.168.1.10# umount /mnt
>         umount: can't umount /media/recdisk: Device or resource busy
> 
> What I actually do is the mount/unmount on the client via ssh.  That
> is a good way to trigger the problem.
> 
> We see that during the un-export the NFS caches are not flushed
> properly which is why the final unmount fails.
> 
> In net/sunrpc/cache.c the cache times (last_refresh, expiry_time,
> flush_time) are measured in seconds.  If I understand the code somewhat
> then during an NFS un-export the is done by setting the flush_time to
> the current time.  The cache_flush() is called.  If in that same second
> last_refresh is set to the current time then the cached item is not
> flushed.  This will subsequently cause un-mount to fail because there
> is still a reference to the mount point.
> 
> > J. Bruce Fields
> > I ran across that recently while reviewing the code to fix a related
> > problem.  I'm not sure what the best fix would be.
> >
> > Previously raised here:
> >
> >       http://marc.info/?l=linux-nfs&m=133514319408283&w=2
> 
> The description in your mail does indeed looks the same as the problem
> that we see.
> 
> >From reading the code in net/sunrpc/cache.c I get the impression that it is
> not really possible to reliably flush the caches for an un-exportfs such
> that after flushing they will not accept entries for the un-exported IP/mount
> point combination.

Right.  So, possible ideas, from that previous message:

	- As Neil suggests, modify exportfs to wait a second between
	  updating etab and flushing the cache.  At that point any
	  entries still using the old information are at least a second
	  old.  That may be adequate for your case, but if someone out
	  there is sensitive to the time required to unexport then that
	  will annoy them.  It also leaves the small possibility of
	  races where an in-progress rpc may still be using an export at
	  the time you try to flush.
	- Implement some new interface that you can use to flush the
	  cache and that doesn't return until in-progress rpc's
	  complete.  Since it waits for rpc's it's not purely a "cache"
	  layer interface any more.  So maybe something like
	  /proc/fs/nfsd/flush_exports.
	- As a workaround requiring no code changes: unexport, then shut
	  down the server entirely and restart it.  Clients will see
	  that as a reboot recovery event and recover automatically, but
	  applications may see delays while that happens.  Kind of a big
	  hammer, but if unexporting while other exports are in use is
	  rare maybe it would be adequate for your case.

--b.
