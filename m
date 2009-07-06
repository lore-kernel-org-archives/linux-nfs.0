Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50077 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756596AbZGFAsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jul 2009 20:48:07 -0400
From: Neil Brown <neilb@suse.de>
To: Peter Staubach <staubach@redhat.com>
Date: Mon, 6 Jul 2009 10:48:52 +1000
Content-Type: text/plain; charset=us-ascii
Message-ID: <19025.18932.752801.870996@notabene.brown>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
References: <49C93526.70303@redhat.com>
   <20090324211917.GJ19389@fieldses.org> <4A1D9210.8070102@redhat.com>
   <1243457149.8522.68.camel@heimdal.trondhkem.org>
   <4A1EB09A.8030809@redhat.com>
   <1243892886.4868.74.camel@heimdal.trondhkem.org>
   <4A257167.9090304@redhat.com>
   <1243980736.4868.314.camel@heimdal.trondhkem.org>
   <4A268603.4090901@redhat.com> <4A2EE2F6.7010403@redhat.com>
   <1244588719.24750.20.camel@heimdal.trondhkem.org>
   <4A300CF0.6030002@redhat.com>
Subject: Re: [PATCH v2] flow control for WRITE requests
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> 
> I believe that we can help all applications by reviewing the
> page cache handling architecture for the NFS client.

(coming in on this a bit late ... we now have a customer hitting the
'stat' problem too :-( )

I think the problem is bigger than just an NFS problem, I think it
would be best if we could solve it in a system wide manner.  That
might be hard, and there might still be a case for some NFS specific
fix, but I'll try to explain how I see it and where I think the fix
should be.

As has been noted, the VM throttles writes when the amount if dirty
page-cache memory crosses some threshold - this is handled in
balance_dirty_pages.

The threshold can be set either with vm_dirty_ratio (20% of available
memory by default) or vm_dirty_bytes (which is useful when you want to
set a ratio below 1% due to the size of memory).

I think it would be very useful if this could be set in 'seconds'
rather than 'bytes'.  i.e. writeout should be throttled when the
amount of dirty memory is more than can be written out in N seconds -
e.g. '3'.
Implementing this would not be straight forward, but I think it should
be possible.
One approach might be for balance_dirty_pages to count how long it
took to write out it's allocation of pages and merge this into a
per-bdi floating 'writeout rate' number.  From this number we can
calculate a maximum number of dirty pages that are allowed for that
bdi, based on the maximum number of seconds we want writeout to take.

Doing this would cause 'sync' and similar functions to take a
controlled amount of time instead of time proportion to available
memory which on tens-of-gigabyte-machines can be an awfully long
time ... we had a different customer with 32Gig of RAM a 70MB/sec disk
drives.  That is 90 seconds to sync - best case.

I think this would address the 'stat' problem by limiting the time a
sequence of stats can take to approximately the configured 'sync'
time.
I don't think we need to worry about limiting each file.
If we are writing out to, say, 10 files in one directory, then each
will, on average, have 1/10 of the allowed number of pages.  So
syncing each file in turn for 'stat' should take about 10 times that,
or the total allowed time.
It could get a bit worse than that:  while one file is flushing, the
other files could each grow to 1/9 of the allowed number of
pages.  But 10 lots of 1/9 is still not much more than 1.
I think the worst case would be if two files in a directory were being
written to.  They might both be using 1/2 of the allowed number of
pages.
If we flush one, the other can grow to use all the allowed pages which
we must then flush.  This would make the total time to stat both files
about 1.5 time the configured time, which isn't a bad worst case
(actually I think you can get worse cases up to 2x if the dirty pages
in the files aren't balanced, but that is still a controlled number).


This might not address your problems with your interesting NFS server
with it's limited buffer.
Maybe for that you want a per-bdi 'dirty_bytes' configurable.  That
should be very easy to implement and test as you could easily make
such a configurable that could be accessed via sysfs, and
get_dirty_limits takes a bdi, so clipping the bdi_dirty value to this
configurable would be quite straight forward.

NeilBrown
