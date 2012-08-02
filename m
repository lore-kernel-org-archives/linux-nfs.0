Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54154 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab2HBCuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 22:50:24 -0400
Date: Wed, 1 Aug 2012 22:50:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120802025022.GB9849@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120724143748.GC8570@fieldses.org>
 <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120726223607.GA28982@fieldses.org>
 <20120731150801.0a4b557b@notabene.brown>
 <20120731122546.GA26737@fieldses.org>
 <20120802100405.4dfc3169@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120802100405.4dfc3169@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 02, 2012 at 10:04:05AM +1000, NeilBrown wrote:
> On Tue, 31 Jul 2012 08:25:46 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Jul 31, 2012 at 03:08:01PM +1000, NeilBrown wrote:
> > > On Thu, 26 Jul 2012 18:36:07 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> > > wrote:
> > > 
> > > > On Tue, Jul 24, 2012 at 05:28:02PM +0000, ZUIDAM, Hans wrote:
> > > > > Hi Bruce,
> > > > > 
> > > > > Thanks for the clarification.
> > > > > 
> > > > > (I'm repeating a lot of my original mail because of the Cc: list.)
> > > > > 
> > > > > > J. Bruce Fields
> > > > > > I think that's right, though I'm curious how you're managing to hit
> > > > > > that case reliably every time.  Or is this an intermittent failure?
> > > > > It's an intermittent failure, but with the procedure shown below it is
> > > > > fairly easy to reproduce.    The actual problem we see in our product
> > > > > is because of the way external storage media are handled in user-land.
> > > > > 
> > > > >         192.168.1.10# mount -t xfs /dev/sdcr/sda1 /mnt
> > > > >         192.168.1.10# exportfs 192.168.1.11:/mnt
> > > > > 
> > > > >         192.168.1.11# mount 192.168.1.10:/mnt /mnt
> > > > >         192.168.1.11# umount /mnt
> > > > > 
> > > > >         192.168.1.10# exportfs -u 192.168.1.11:/mnt
> > > > >         192.168.1.10# umount /mnt
> > > > >         umount: can't umount /media/recdisk: Device or resource busy
> > > > > 
> > > > > What I actually do is the mount/unmount on the client via ssh.  That
> > > > > is a good way to trigger the problem.
> > > > > 
> > > > > We see that during the un-export the NFS caches are not flushed
> > > > > properly which is why the final unmount fails.
> > > > > 
> > > > > In net/sunrpc/cache.c the cache times (last_refresh, expiry_time,
> > > > > flush_time) are measured in seconds.  If I understand the code somewhat
> > > > > then during an NFS un-export the is done by setting the flush_time to
> > > > > the current time.  The cache_flush() is called.  If in that same second
> > > > > last_refresh is set to the current time then the cached item is not
> > > > > flushed.  This will subsequently cause un-mount to fail because there
> > > > > is still a reference to the mount point.
> > > > > 
> > > > > > J. Bruce Fields
> > > > > > I ran across that recently while reviewing the code to fix a related
> > > > > > problem.  I'm not sure what the best fix would be.
> > > > > >
> > > > > > Previously raised here:
> > > > > >
> > > > > >       http://marc.info/?l=linux-nfs&m=133514319408283&w=2
> > > > > 
> > > > > The description in your mail does indeed looks the same as the problem
> > > > > that we see.
> > > > > 
> > > > > >From reading the code in net/sunrpc/cache.c I get the impression that it is
> > > > > not really possible to reliably flush the caches for an un-exportfs such
> > > > > that after flushing they will not accept entries for the un-exported IP/mount
> > > > > point combination.
> > > > 
> > > > Right.  So, possible ideas, from that previous message:
> > > > 
> > > > 	- As Neil suggests, modify exportfs to wait a second between
> > > > 	  updating etab and flushing the cache.  At that point any
> > > > 	  entries still using the old information are at least a second
> > > > 	  old.  That may be adequate for your case, but if someone out
> > > > 	  there is sensitive to the time required to unexport then that
> > > > 	  will annoy them.  It also leaves the small possibility of
> > > > 	  races where an in-progress rpc may still be using an export at
> > > > 	  the time you try to flush.
> > > > 	- Implement some new interface that you can use to flush the
> > > > 	  cache and that doesn't return until in-progress rpc's
> > > > 	  complete.  Since it waits for rpc's it's not purely a "cache"
> > > > 	  layer interface any more.  So maybe something like
> > > > 	  /proc/fs/nfsd/flush_exports.
> > > > 	- As a workaround requiring no code changes: unexport, then shut
> > > > 	  down the server entirely and restart it.  Clients will see
> > > > 	  that as a reboot recovery event and recover automatically, but
> > > > 	  applications may see delays while that happens.  Kind of a big
> > > > 	  hammer, but if unexporting while other exports are in use is
> > > > 	  rare maybe it would be adequate for your case.
> > > 
> > > That's a shame...
> > > I had originally intended "rpc.nfsd 0" to simple stop all threads and nothing
> > > else.  Then you would be able to:
> > >    rpc.nfsd 0
> > >    exportfs -f
> > >    unmount
> > >    rpc.nfsd 16
> > > 
> > > and have a nice fast race-free unmount.
> > > But commit e096bbc6488d3e49d476bf986d33752709361277 'fixed' that :-(
> > > 
> > > I wonder if it can be resurrected ... maybe not worth the effort.
> > 
> > That also shut down v4 state.  Making the clients recover would
> > typically be more expensive than ditching the export table.  (Did it
> > also throw out NLM locks?  I can't tell on a quick check.)
> 
> No, it didn't do anything except stop all the threads.
> I never liked that fact that stopping the last thread did something extra.
> So when I added the ability to control the number of threads via sysfs I made
> sure that it *only* controlled the number of threads.  However I kept the
> legacy behaviour that sending SIGKILL to the nfsd threads would also unexport
> things.  Obviously I should have documented this better.
> 
> The more I think out it, the more I'd really like to go back to that.  It
> really is the *right* thing to do.

Could be.

The nfsd startup/shutdown has a number of problems, and figuring out how
to containerize it will uncover some more.  I'm open to any suggestions.

> > > The idea of a new interface to synchronise with all threads has potential and
> > > doesn't need to be at the nfsd level - it could be in sunrpc.  Maybe it could
> > > be built into the current 'flush' interface.
> > 
> > We need to keep compatible behavior to prevent deadlocks.  (Don't want
> > nfsd waiting on mountd waiting on nfsd.)
> > 
> > Looks like write_flush currently returns -EINVAL to anything that's not
> > an integer.  So exportfs could write something new and ignore the error
> > return (or try some other workaround) in the case of an old kernel.
> > 
> > > 1/ iterate through all no-sleeping threads setting a flag an increasing a
> > > counter.
> > > 2/ when a thread completes current request, if test_and_clear the flag, it
> > > atomic_dec_and_test the counter and then wakes up some wait_queue_head.
> > > 3/ 'flush'ing thread waits on the waut_queue_head for the counter to be 0.
> > > 
> > > If you don't hate it I could possibly even provide some code.
> > 
> > That sounds reasonable to me.  So you'd just add a single such
> > thread-synchronization after modifying mountd's idea of the export
> > table, ok.
> > 
> > It still wouldn't allow an unmount in the case a client held an NSM lock
> > or v4 open--but I think that's what we want.  If somebody wants a way to
> > unmount even in the presence of such state, then they really need to do
> > a complete shutdown.
> > 
> > I wonder if there's also still a use for an operation that stops all
> > threads temporarily but doesn't toss any state or caches?  I'm not
> > coming up with one off the top of my head.
> > 
> > --b.
> 
> Actually, I think you were right the first time.  The cache isn't really well
> positioned as it doesn't have a list of services to synchronise with.
> We could give it one, but I don't that is such a good idea.

OK.

> We already have a way to forcably drop all locks on a filesystem don't we?
>    /proc/fs/nfsd/unlock_filesystem
> 
> Does that unlock the filesystem from the nfsv4 perspective too?  Should it?

It doesn't, but yes it probably should.

> I wonder if it might make sense to insert an 'sync with various threads' call
> in there.

Probably so.

But we still need a version that doesn't break locks: an admin should be
able to say "unexport and unmount if you can, but not if it means
throwing away client state".

--b.
