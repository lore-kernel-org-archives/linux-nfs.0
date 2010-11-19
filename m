Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52860 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757960Ab0KSWRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 17:17:23 -0500
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101119220356.GB3270@hostway.ca>
References: <20101111023520.GH16939@hostway.ca>
	 <1289452967.4062.10.camel@heimdal.trondhjem.org>
	 <20101119202004.GA3270@hostway.ca>
	 <1290201888.3135.61.camel@heimdal.trondhjem.org>
	 <20101119220356.GB3270@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 17:17:19 -0500
Message-ID: <1290205039.3135.74.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-11-19 at 14:03 -0800, Simon Kirby wrote:
> On Fri, Nov 19, 2010 at 04:24:48PM -0500, Trond Myklebust wrote:
> 
> > On Fri, 2010-11-19 at 12:20 -0800, Simon Kirby wrote:
> > > On Thu, Nov 11, 2010 at 01:22:47PM +0800, Trond Myklebust wrote:
> > > 
> > > > On Wed, 2010-11-10 at 18:35 -0800, Simon Kirby wrote:
> > > > > Still seeing all sorts of boxes fall over with 2.6.35 and 2.6.36 NFS.
> > > > > Unfortunately, it doesn't happen all the time...only certain load
> > > > > patterns seem to start it off.  Once it starts, I can't find a way to
> > > > > make it recover without rebooting.
> > > > >...
> > > > > NFS: permission(0:4c/5284877), mask=0x1, res=0
> > > > > NFS: revalidating (0:4c/3247737045)
> > > > > 
> > > > > 900ms matches the probably-silly nfs mount settings we're currently using:
> > > > > 
> > > > > rw,hard,intr,tcp,timeo=9,retrans=3,rsize=8192,wsize=8192
> > > > > 
> > > > > Full kernel log here: http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > > > 
> > > > timeo=9 is a completely insane retransmit value for a tcp connection.
> > > > 
> > > > Please use the default timeo=600, and all will work correctly.
> > > 
> > > Ok, so, we were running with timeo=300 instead on a number of servers,
> > > and we were still seeing the problem on 2.6.36.  I've uploaded a new
> > > kernel log (lsh1051) here:
> > > 
> > > 	http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > > 
> > > The log starts out with the hung task warnings occurring after
> > > otherwise-normal operation.  Once I noticed, I set rpc/nfs_debug to 1,
> > > and then later set it to 255.
> > 
> > Were the NFS servers hung at this point? If so, then that probably
> > suffices to explain the hung task warnings (which would be false
> > positives) as being due to the page cache waiting to lock pages on which
> > I/O is being performed.
> 
> Nope...Many other NFS clients did not notice anything, and there were no
> obvious problems on any NFS server.  This was only affecting two clients
> at the same time, but we had a limited LVS pool pointing at them at the
> time to try to isolate load patterns that might be tickling the issue.

So what were all the 

'lockd: server 10.10.52.xxx not responding, still trying'

messages all about? There were quite a few of them for a number of
different servers in the moments leading up to the hang. Could it be a
problem with the switch these clients are attached to?

> > > Since several servers were stuck at the same time and we were losing
> > > quorum, I decided to try something more drastic and booted into
> > > 2.6.37-rc2-git3.  This kernel hasn't got stuck yet!  However, it's
> > > spitting out some new errors which may be worth looking into:
> > > 
> > > [ 1574.088812] NFS: server 10.10.52.222 error: fileid changed
> > > [ 1574.088814] fsid 0:18: expected fileid 0x4c081940, got 0x4c081950
> > > [11340.409447] NFS: server 10.10.52.228 error: fileid changed
> > > [11340.409450] fsid 0:45: expected fileid 0x696ff82, got 0x16a98bd7
> > > [20832.579912] NFS: server 10.10.52.225 error: fileid changed
> > > [20832.579914] fsid 0:2a: expected fileid 0x8c67ebab, got 0x8c6811e5
> > > [32775.957351] NFS: server 10.10.52.230 error: fileid changed
> > > [32775.957354] fsid 0:52: expected fileid 0x919041fd, got 0x93f1962d
> > > 
> > > These are also in the same kernel log.  The error code isn't new, so
> > > something else seems to have changed to cause it.
> > 
> > These indicate server bugs: your failover event appears to have caused
> > the inode numbers to have changed on a number of files. This is
> > something that shouldn't happen in a normal NFS environment, and so the
> > client prints out the above warnings...
> 
> There was no fail-over event on any NFS server for the last week, so
> I'm not sure what would be causing this.  The IPs listed there are
> running 2.6.30.10 with XFS-exported fses.
> 
> All of the other clients running 2.6.36 (another 20 or so boxes) with the
> same NFS mounts are not logging any "fileid changed" messages.  The first
> time I've seen this message is with this 2.6.37-rc2-git3 kernel.

The only change in 2.6.37-rcX I can think of that might have caused an
issue here would be Bryan's readdir changes.

If you can reproduce the above error condition, then could you try
turning off readdirplus (using the 'nordirplus' mount option) and seeing
if that makes a difference?

Trond

