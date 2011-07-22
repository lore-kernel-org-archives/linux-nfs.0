Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571Ab1GVLHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 07:07:49 -0400
Date: Fri, 22 Jul 2011 07:07:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: misch@schwartzkopff.org
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 grace time
Message-ID: <20110722070742.776ae99d@tlielax.poochiereds.net>
In-Reply-To: <201107211540.05673.misch@schwartzkopff.org>
References: <201107211540.05673.misch@schwartzkopff.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 21 Jul 2011 15:40:05 +0200
Michael Schwartzkopff <misch@schwartzkopff.org> wrote:

> Hi,
> 
> setting up a linux NFS server cluster I experience a strange problem during a 
> failover. A client can access a file only after 60 to 90 seconds. On the line I 
> see a NFS4ERR_GRACE from the server to the client.
> 
> I already set the /proc/fs/nfsd/nfsv4leastime to 10.
> 
> Any other idea?
> 
> For the tests I have a simple setup:
> 
> One host with a simple script that simulates failover:
> 
> #!/bin/bash
> 
> ip a d 1.2.3.4/24 dev eth0
> exportfs -u *:/srv/nfs/home
> exportfs -u *:/srv/nfs
> /etc/init.d/nfsserver stop
> #
> /etc/init.d/nfsserver start
> exportfs -o fsid=0,rw,crossmnt,no_root_squash *:/srv/nfs
> exportfs -o fsid=1000,rw,mountpoint,no_root_squash *:/srv/nfs/home
> ip a a 1.2.3.4/24 dev eth0
> 

This is normal. The grace period is there to allow clients to reclaim
their state without other clients racing in and grabbing their locks on
the new server, etc.

You can play with /proc/fs/nfsd/nfsv4gracetime too but I'd be very
leery of setting that too low. It should never be lower than the
previous leasetime (see the comments on write_gracetime in the kernel).

Note that setting the leasetime that small has an effect on performance
too as the clients have to renew their state more frequently.

It also affects the resiliency of your entire setup in the face of
network partitions (including the network partition that occurs during
failover). If the client can't reclaim its state during the grace
period, then it's lost and nasty things can occur (like other clients
stealing posix locks out from under you).

-- 
Jeff Layton <jlayton@redhat.com>
