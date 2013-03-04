Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757741Ab3CDPEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 10:04:36 -0500
Date: Mon, 4 Mar 2013 10:04:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Ming Lei <ming.lei@canonical.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130304100432.5c7ea704@tlielax.poochiereds.net>
In-Reply-To: <CACVXFVM5VhU_ZgYr1KxERY7DXxMQpkWoiTyjyar91Hz=vU4-ug@mail.gmail.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	<CACVXFVM5VhU_ZgYr1KxERY7DXxMQpkWoiTyjyar91Hz=vU4-ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Mar 2013 22:40:02 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> On Mon, Mar 4, 2013 at 10:14 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2013-03-04 at 21:57 +0800, Ming Lei wrote:
> >> Hi,
> >>
> >> The below warning can be triggered each time when mount.nfs is
> >> running on 3.9-rc1.
> >>
> >> Not sure if freezable_schedule() inside rpc_wait_bit_killable should
> >> be changed to schedule() since nfs_clid_init_mutex is held in the path.
> >
> > Cc:ing Jeff, who added freezable_schedule(), and applied it to
> > rpc_wait_bit_killable.
> >
> > So this is occurring when the kernel enters the freeze state?
> 
> No, but the situation can really be triggered in freeze case, so
> lockdep forecasts the problem correctly, :-)
> 
> > Why does it occur only with nfs_clid_init_mutex, and not with all the
> > other mutexes that we hold across RPC calls? We hold inode->i_mutex
> > across RPC calls all the time when doing renames, unlinks, file
> > creation,...
> 
> At least in the mount.nfs context, only nfs_clid_init_mutex is held.
> 
> IMO, if locks might be held in the path, it isn't wise to call
> freezable_schedule
> inside rpc_wait_bit_killable().
> 

I don't get it -- why is it bad to hold a lock across a freeze event?

The problem that we have is that we must often hold locks across
long-running syscalls (consider something like sync()). In the event
that there is a lot of dirty data, it might take a long time for that
to finish.

There's also the problem that it's not uncommon for the freezer to take
down userland processes (such as NetworkManager) which in turn take
down network interfaces that we need to talk to the server.

The fix from a couple of years ago (which admittedly needs more work)
was to allow the freezing of tasks that are waiting on a reply from the
server. That sort of necessitates that we are allowed to hold our locks
across the try_to_freeze call though.

If that's no longer allowed then we're back to square one with laptops
that fail to suspend when they have NFS mounts. Is there some other
solution we should pursue instead?

-- 
Jeff Layton <jlayton@redhat.com>
