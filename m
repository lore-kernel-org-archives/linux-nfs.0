Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753824Ab1GVLlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 07:41:13 -0400
Date: Fri, 22 Jul 2011 07:41:08 -0400
From: Jeff Layton <jlayton@redhat.com>
To: misch@schwartzkopff.org
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 grace time
Message-ID: <20110722074108.2213498d@tlielax.poochiereds.net>
In-Reply-To: <201107221324.22512.misch@schwartzkopff.org>
References: <201107211540.05673.misch@schwartzkopff.org>
	<20110722070742.776ae99d@tlielax.poochiereds.net>
	<201107221324.22512.misch@schwartzkopff.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 22 Jul 2011 13:24:22 +0200
Michael Schwartzkopff <misch@schwartzkopff.org> wrote:

> > On Thu, 21 Jul 2011 15:40:05 +0200
> > 
> > Michael Schwartzkopff <misch@schwartzkopff.org> wrote:
> > > Hi,
> > > 
> > > setting up a linux NFS server cluster I experience a strange problem
> > > during a failover. A client can access a file only after 60 to 90
> > > seconds. On the line I see a NFS4ERR_GRACE from the server to the
> > > client.
> > > 
> > > I already set the /proc/fs/nfsd/nfsv4leastime to 10.
> > > 
> > > Any other idea?
> > > 
> > > For the tests I have a simple setup:
> > > 
> > > One host with a simple script that simulates failover:
> > > 
> > > #!/bin/bash
> > > 
> > > ip a d 1.2.3.4/24 dev eth0
> > > exportfs -u *:/srv/nfs/home
> > > exportfs -u *:/srv/nfs
> > > /etc/init.d/nfsserver stop
> > > #
> > > /etc/init.d/nfsserver start
> > > exportfs -o fsid=0,rw,crossmnt,no_root_squash *:/srv/nfs
> > > exportfs -o fsid=1000,rw,mountpoint,no_root_squash *:/srv/nfs/home
> > > ip a a 1.2.3.4/24 dev eth0
> > 
> > This is normal. The grace period is there to allow clients to reclaim
> > their state without other clients racing in and grabbing their locks on
> > the new server, etc.
> 
> Ok. But this is the same client that cannot its own data.
>  

That may be the case in your situation, but the protocol has to allow for that.

> > You can play with /proc/fs/nfsd/nfsv4gracetime too but I'd be very
> > leery of setting that too low. It should never be lower than the
> > previous leasetime (see the comments on write_gracetime in the kernel).
> 
> I did already set this to 10 seconds without success. The client still has to 
> wait 60 seconds to access its data.
> 

You may need to restart the server and remount the clients in order for it to work.

> By the way: Is there a nice way to set this during startup of the nfsserver, 
> i.e. a mount option for nfsd?
> 

Not currently, but a module parm for this would seem to make more sense
than this file in /proc.

-- 
Jeff Layton <jlayton@redhat.com>
