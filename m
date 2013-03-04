Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:58680 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041Ab3CDPdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 10:33:51 -0500
MIME-Version: 1.0
In-Reply-To: <20130304100432.5c7ea704@tlielax.poochiereds.net>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	<CACVXFVM5VhU_ZgYr1KxERY7DXxMQpkWoiTyjyar91Hz=vU4-ug@mail.gmail.com>
	<20130304100432.5c7ea704@tlielax.poochiereds.net>
Date: Mon, 4 Mar 2013 23:33:49 +0800
Message-ID: <CACVXFVPvTnfH98KqAQxDzMi5Pbf1fbi5HEGb=ggWWg4FX_4G=g@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Ming Lei <ming.lei@canonical.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, Ben Chan <benchan@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

CC guys who introduced the lockdep change.

On Mon, Mar 4, 2013 at 11:04 PM, Jeff Layton <jlayton@redhat.com> wrote:

>
> I don't get it -- why is it bad to hold a lock across a freeze event?

At least this may deadlock another mount.nfs during freezing, :-)

See detailed explanation in the commit log:

commit 6aa9707099c4b25700940eb3d016f16c4434360d
Author: Mandeep Singh Baines <msb@chromium.org>
Date:   Wed Feb 27 17:03:18 2013 -0800

    lockdep: check that no locks held at freeze time

    We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
    deadlock if the lock is later acquired in the suspend or hibernate path
    (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
    cgroup_freezer if a lock is held inside a frozen cgroup that is later
    acquired by a process outside that group.

> The problem that we have is that we must often hold locks across
> long-running syscalls (consider something like sync()). In the event
> that there is a lot of dirty data, it might take a long time for that
> to finish.
>
> There's also the problem that it's not uncommon for the freezer to take
> down userland processes (such as NetworkManager) which in turn take
> down network interfaces that we need to talk to the server.
>
> The fix from a couple of years ago (which admittedly needs more work)
> was to allow the freezing of tasks that are waiting on a reply from the
> server. That sort of necessitates that we are allowed to hold our locks
> across the try_to_freeze call though.
>
> If that's no longer allowed then we're back to square one with laptops
> that fail to suspend when they have NFS mounts. Is there some other
> solution we should pursue instead?


Thanks,
--
Ming Lei
