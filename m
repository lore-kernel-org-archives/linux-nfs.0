Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60846 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758440Ab3CDPxg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 10:53:36 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ming Lei <ming.lei@canonical.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@ZenIV.linux.org.uk>
CC: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, Ben Chan <benchan@chromium.org>,
        "Oleg Nesterov" <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Mon, 4 Mar 2013 15:53:33 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD381@sacexcmbx05-prd.hq.netapp.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	 <CACVXFVM5VhU_ZgYr1KxERY7DXxMQpkWoiTyjyar91Hz=vU4-ug@mail.gmail.com>
	 <20130304100432.5c7ea704@tlielax.poochiereds.net>
	 <CACVXFVPvTnfH98KqAQxDzMi5Pbf1fbi5HEGb=ggWWg4FX_4G=g@mail.gmail.com>
In-Reply-To: <CACVXFVPvTnfH98KqAQxDzMi5Pbf1fbi5HEGb=ggWWg4FX_4G=g@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-03-04 at 23:33 +0800, Ming Lei wrote:
> Hi,
> 
> CC guys who introduced the lockdep change.
> 
> On Mon, Mar 4, 2013 at 11:04 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> >
> > I don't get it -- why is it bad to hold a lock across a freeze event?
> 
> At least this may deadlock another mount.nfs during freezing, :-)
> 
> See detailed explanation in the commit log:
> 
> commit 6aa9707099c4b25700940eb3d016f16c4434360d
> Author: Mandeep Singh Baines <msb@chromium.org>
> Date:   Wed Feb 27 17:03:18 2013 -0800
> 
>     lockdep: check that no locks held at freeze time
> 
>     We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>     deadlock if the lock is later acquired in the suspend or hibernate path
>     (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>     cgroup_freezer if a lock is held inside a frozen cgroup that is later
>     acquired by a process outside that group.
> 

This is bloody ridiculous... If you want to add functionality to
implement cgroup or per-process freezing, then do it through some other
api instead of trying to push your problems onto others by adding new
global locking rules.

Filesystems are a shared resource that have _nothing_ to do with process
cgroups. They need to be suspended when the network goes down or other
resources that they depend on are suspended. At that point, there is no
"what if I launch a new mount command?" scenario.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
