From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Add more entropy to selection of port and xid for NFS client.
Date: Thu, 6 Mar 2008 13:36:19 +1100
Message-ID: <18383.22691.365578.900629@notabene.brown>
References: <20080304163343.18442.patches@notabene>
	<1080304053553.18549@suse.de>
	<4AD9A05A-64F6-4F6C-BF8A-C013A361F1A4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:49154 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934361AbYCFCg1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 21:36:27 -0500
In-Reply-To: message from Chuck Lever on Tuesday March 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday March 4, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> On Mar 4, 2008, at 12:35 AM, NeilBrown wrote:
> > Hi Trond/Chunk
> >
> > I wonder what you think of this patch.
> >
> > I found we needed it for some customers who had machines with NFS root
> > who (for reasons I never fully understood) find they reboot their
> > machines fairly often (maybe it was a test setup or something).  The
> > often got "inode number mismatch" errors because the reply came out of
> > the server's cache and was left over from before the client's reboot.
> 
> If the problem is indeed lack of entropy at boot time, then random32 
> () should be fixed.  It suggests that random32_init() isn't getting  
> invoked soon enough during boot to have any effect on the starting  
> XID selection.  This seems to get broken periodically... perhaps  
> random32() should warn if it detects that random32_init() hasn't been  
> invoked yet.

Ahhh.....

This wasn't with the most recent kernel (at all) and I see that the
net_random being used at the time is somewhat more simplistic than the
random32 that is now being used.

So maybe the problem has already been fixed at a deeper level.
Certainly random32 is being initialised with a bit more entropy
than net_random was at the time.

My approach was:  these numbers really really need to not repeat, so
mix together as much potential entropy as possible, hoping that some
of it really will be different each reboot.

Maybe random32 is now sufficient in itself.

> 
> Another alternative: continue to use net_random(), but the RPC client  
> could add entropy via net_srandom() calls during it's  
> initialization.

There is nothing random in the MOUNT reply, is there?  I guess if TCP
were used, the servers sequence number would be random enough to
remove and XID collision problems.  But that is probably fairly hard
to extract.

I think I might just assume that the new net_random (aka random32) is
good enough, and that the problem only exists in older kernels.

Thanks,
NeilBrown
