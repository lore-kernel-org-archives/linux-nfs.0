Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:37096 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757858Ab0KSWD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 17:03:57 -0500
Date: Fri, 19 Nov 2010 14:03:56 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101119220356.GB3270@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org> <20101119202004.GA3270@hostway.ca> <1290201888.3135.61.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290201888.3135.61.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 04:24:48PM -0500, Trond Myklebust wrote:

> On Fri, 2010-11-19 at 12:20 -0800, Simon Kirby wrote:
> > On Thu, Nov 11, 2010 at 01:22:47PM +0800, Trond Myklebust wrote:
> > 
> > > On Wed, 2010-11-10 at 18:35 -0800, Simon Kirby wrote:
> > > > Still seeing all sorts of boxes fall over with 2.6.35 and 2.6.36 NFS.
> > > > Unfortunately, it doesn't happen all the time...only certain load
> > > > patterns seem to start it off.  Once it starts, I can't find a way to
> > > > make it recover without rebooting.
> > > >...
> > > > NFS: permission(0:4c/5284877), mask=0x1, res=0
> > > > NFS: revalidating (0:4c/3247737045)
> > > > 
> > > > 900ms matches the probably-silly nfs mount settings we're currently using:
> > > > 
> > > > rw,hard,intr,tcp,timeo=9,retrans=3,rsize=8192,wsize=8192
> > > > 
> > > > Full kernel log here: http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > > 
> > > timeo=9 is a completely insane retransmit value for a tcp connection.
> > > 
> > > Please use the default timeo=600, and all will work correctly.
> > 
> > Ok, so, we were running with timeo=300 instead on a number of servers,
> > and we were still seeing the problem on 2.6.36.  I've uploaded a new
> > kernel log (lsh1051) here:
> > 
> > 	http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > 
> > The log starts out with the hung task warnings occurring after
> > otherwise-normal operation.  Once I noticed, I set rpc/nfs_debug to 1,
> > and then later set it to 255.
> 
> Were the NFS servers hung at this point? If so, then that probably
> suffices to explain the hung task warnings (which would be false
> positives) as being due to the page cache waiting to lock pages on which
> I/O is being performed.

Nope...Many other NFS clients did not notice anything, and there were no
obvious problems on any NFS server.  This was only affecting two clients
at the same time, but we had a limited LVS pool pointing at them at the
time to try to isolate load patterns that might be tickling the issue.

> > Since several servers were stuck at the same time and we were losing
> > quorum, I decided to try something more drastic and booted into
> > 2.6.37-rc2-git3.  This kernel hasn't got stuck yet!  However, it's
> > spitting out some new errors which may be worth looking into:
> > 
> > [ 1574.088812] NFS: server 10.10.52.222 error: fileid changed
> > [ 1574.088814] fsid 0:18: expected fileid 0x4c081940, got 0x4c081950
> > [11340.409447] NFS: server 10.10.52.228 error: fileid changed
> > [11340.409450] fsid 0:45: expected fileid 0x696ff82, got 0x16a98bd7
> > [20832.579912] NFS: server 10.10.52.225 error: fileid changed
> > [20832.579914] fsid 0:2a: expected fileid 0x8c67ebab, got 0x8c6811e5
> > [32775.957351] NFS: server 10.10.52.230 error: fileid changed
> > [32775.957354] fsid 0:52: expected fileid 0x919041fd, got 0x93f1962d
> > 
> > These are also in the same kernel log.  The error code isn't new, so
> > something else seems to have changed to cause it.
> 
> These indicate server bugs: your failover event appears to have caused
> the inode numbers to have changed on a number of files. This is
> something that shouldn't happen in a normal NFS environment, and so the
> client prints out the above warnings...

There was no fail-over event on any NFS server for the last week, so
I'm not sure what would be causing this.  The IPs listed there are
running 2.6.30.10 with XFS-exported fses.

All of the other clients running 2.6.36 (another 20 or so boxes) with the
same NFS mounts are not logging any "fileid changed" messages.  The first
time I've seen this message is with this 2.6.37-rc2-git3 kernel.

Cheers,

Simon-
