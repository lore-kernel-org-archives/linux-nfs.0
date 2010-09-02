Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab0IBAXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 20:23:18 -0400
Date: Wed, 1 Sep 2010 20:23:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Cc: Sorin Faibish <sfaibish@emc.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: Does the 2.6.34 kernel support NFS over IPv6?
Message-ID: <20100901202311.7d8df835@tlielax.poochiereds.net>
In-Reply-To: <4C7EE6AE.6060209@candelatech.com>
References: <4C7ECD62.7020802@candelatech.com>
	<op.vidoaslgrwwil4@sfaibish1.corp.emc.com>
	<4C7EE6AE.6060209@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 01 Sep 2010 16:50:06 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 09/01/2010 04:45 PM, Sorin Faibish wrote:
> > Yes. We tested at connectathon with Fedora.
> >
> >
> > On Wed, 01 Sep 2010 18:02:10 -0400, Ben Greear <greearb@candelatech.com>
> > wrote:
> >
> >> If not, do more recent kernels?
> >>
> >> I'm using Fedora 13.
> > Should work if configured properly.
> 
> How about as a server?  It doesn't seem to listen on IPv6
> addresses.  I tried 2.6.36-rc2+ kernel as well.
> 
> I tried setting /etc/exports to look like this:
> 
> [root@localhost ~]# more /etc/exports
> /exports/tmp [2002::0/16](rw)
> 
> [root@localhost ~]# netstat -an|grep LISTEN |grep 2049
> tcp        0      0 0.0.0.0:2049                0.0.0.0:*                   LISTEN
> 
> I'm trying to test some NFS/IPv6 client changes, but I need
> at least a minimal IPv6 server to test against!
> 
> Thanks,
> Ben
> 

Not quite  -- we tested an earlier version of Chuck's mountd/exportfs
patches at Connectathon. Those are still not merged yet in mainline
nfs-utils.

For now, no Linux distro that I know of has server-side IPv6 support.
Once Chuck finishes posting his patches for mountd and exportfs, and
those are merged in mainline nfs-utils, it will.

The kernel is pretty much IPv6-ready though, so once you have a
suitably enabled nfs-utils it should work. If you want to play with
the patches for this, you can pull down Chuck's git repo from here:

http://git.linux-nfs.org/?p=cel/nfs-utils.git;a=summary

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
