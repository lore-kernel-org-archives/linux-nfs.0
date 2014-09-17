Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:63680 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153AbaIQUPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 16:15:35 -0400
Received: by mail-qa0-f42.google.com with SMTP id j7so2557753qaq.1
        for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 13:15:34 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 17 Sep 2014 16:15:32 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 1/9] lockd: move lockd's grace period handling into
 its own module
Message-ID: <20140917161532.39e20a3b@tlielax.poochiereds.net>
In-Reply-To: <20140917193642.GA2855@fieldses.org>
References: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
	<1410786850-18194-2-git-send-email-jlayton@primarydata.com>
	<20140915150221.2437635b@tlielax.poochiereds.net>
	<20140917193642.GA2855@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Sep 2014 15:36:43 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 15, 2014 at 03:02:21PM -0400, Jeff Layton wrote:
> > On Mon, 15 Sep 2014 09:14:02 -0400
> > Jeff Layton <jlayton@primarydata.com> wrote:
> > 
> > > Currently, all of the grace period handling is part of lockd. Eventually
> > > though we'd like to be able to build v4-only servers, at which point
> > > we'll need to put all of this elsewhere.
> > > 
> > > Move the code itself into fs/nfs_common and have it build a grace.ko
> > > module. Then, rejigger the Kconfig options so that both nfsd and lockd
> > > enable it automatically.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > ---
> > >  fs/Kconfig              |   6 ++-
> > >  fs/lockd/Makefile       |   2 +-
> > >  fs/lockd/grace.c        |  65 ----------------------------
> > >  fs/lockd/netns.h        |   1 -
> > >  fs/lockd/svc.c          |   1 -
> > >  fs/nfs_common/Makefile  |   3 +-
> > >  fs/nfs_common/grace.c   | 113 ++++++++++++++++++++++++++++++++++++++++++++++++
> > >  fs/nfsd/Kconfig         |   1 +
> > >  include/linux/proc_fs.h |   2 +
> > >  9 files changed, 124 insertions(+), 70 deletions(-)
> > >  delete mode 100644 fs/lockd/grace.c
> > >  create mode 100644 fs/nfs_common/grace.c
> > > 
> > > diff --git a/fs/Kconfig b/fs/Kconfig
> > > index 312393f32948..db5dc1598716 100644
> > > --- a/fs/Kconfig
> > > +++ b/fs/Kconfig
> > > @@ -233,9 +233,13 @@ if NETWORK_FILESYSTEMS
> > >  source "fs/nfs/Kconfig"
> > >  source "fs/nfsd/Kconfig"
> > >  
> > > +config GRACE_PERIOD
> > > +	tristate
> > > +
> > >  config LOCKD
> > >  	tristate
> > >  	depends on FILE_LOCKING
> > > +	select GRACE_PERIOD
> > >  
> > >  config LOCKD_V4
> > >  	bool
> > > @@ -249,7 +253,7 @@ config NFS_ACL_SUPPORT
> > >  
> > >  config NFS_COMMON
> > >  	bool
> > > -	depends on NFSD || NFS_FS
> > > +	depends on NFSD || NFS_FS || LOCKD
> > >  	default y
> > >  
> > >  source "net/sunrpc/Kconfig"
> > > diff --git a/fs/lockd/Makefile b/fs/lockd/Makefile
> > > index ca58d64374ca..6a0b351ce30e 100644
> > > --- a/fs/lockd/Makefile
> > > +++ b/fs/lockd/Makefile
> > > @@ -5,6 +5,6 @@
> > >  obj-$(CONFIG_LOCKD) += lockd.o
> > >  
> > >  lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
> > > -	        svcshare.o svcproc.o svcsubs.o mon.o xdr.o grace.o
> > > +	        svcshare.o svcproc.o svcsubs.o mon.o xdr.o
> > >  lockd-objs-$(CONFIG_LOCKD_V4) += clnt4xdr.o xdr4.o svc4proc.o
> > >  lockd-objs		      := $(lockd-objs-y)
> > > diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
> > > deleted file mode 100644
> > > index 6d1ee7204c88..000000000000
> > > --- a/fs/lockd/grace.c
> > > +++ /dev/null
> > > @@ -1,65 +0,0 @@
> > > -/*
> > > - * Common code for control of lockd and nfsv4 grace periods.
> > > - */
> > > -
> > > -#include <linux/module.h>
> > > -#include <linux/lockd/bind.h>
> > > -#include <net/net_namespace.h>
> > > -
> > > -#include "netns.h"
> > > -
> > > -static DEFINE_SPINLOCK(grace_lock);
> > > -
> > > -/**
> > > - * locks_start_grace
> > > - * @lm: who this grace period is for
> > > - *
> > > - * A grace period is a period during which locks should not be given
> > > - * out.  Currently grace periods are only enforced by the two lock
> > > - * managers (lockd and nfsd), using the locks_in_grace() function to
> > > - * check when they are in a grace period.
> > > - *
> > > - * This function is called to start a grace period.
> > > - */
> > > -void locks_start_grace(struct net *net, struct lock_manager *lm)
> > > -{
> > > -	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > > -
> > > -	spin_lock(&grace_lock);
> > > -	list_add(&lm->list, &ln->grace_list);
> > > -	spin_unlock(&grace_lock);
> > > -}
> > > -EXPORT_SYMBOL_GPL(locks_start_grace);
> > > -
> > > -/**
> > > - * locks_end_grace
> > > - * @lm: who this grace period is for
> > > - *
> > > - * Call this function to state that the given lock manager is ready to
> > > - * resume regular locking.  The grace period will not end until all lock
> > > - * managers that called locks_start_grace() also call locks_end_grace().
> > > - * Note that callers count on it being safe to call this more than once,
> > > - * and the second call should be a no-op.
> > > - */
> > > -void locks_end_grace(struct lock_manager *lm)
> > > -{
> > > -	spin_lock(&grace_lock);
> > > -	list_del_init(&lm->list);
> > > -	spin_unlock(&grace_lock);
> > > -}
> > > -EXPORT_SYMBOL_GPL(locks_end_grace);
> > > -
> > > -/**
> > > - * locks_in_grace
> > > - *
> > > - * Lock managers call this function to determine when it is OK for them
> > > - * to answer ordinary lock requests, and when they should accept only
> > > - * lock reclaims.
> > > - */
> > > -int locks_in_grace(struct net *net)
> > > -{
> > > -	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > > -
> > > -	return !list_empty(&ln->grace_list);
> > > -}
> > > -EXPORT_SYMBOL_GPL(locks_in_grace);
> > > diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
> > > index 5010b55628b4..097bfa3adb1c 100644
> > > --- a/fs/lockd/netns.h
> > > +++ b/fs/lockd/netns.h
> > > @@ -11,7 +11,6 @@ struct lockd_net {
> > >  
> > >  	struct delayed_work grace_period_end;
> > >  	struct lock_manager lockd_manager;
> > > -	struct list_head grace_list;
> > >  
> > >  	spinlock_t nsm_clnt_lock;
> > >  	unsigned int nsm_users;
> > > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > > index 09857b48d0c3..c35cd43a06e6 100644
> > > --- a/fs/lockd/svc.c
> > > +++ b/fs/lockd/svc.c
> > > @@ -586,7 +586,6 @@ static int lockd_init_net(struct net *net)
> > >  	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > >  
> > >  	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
> > > -	INIT_LIST_HEAD(&ln->grace_list);
> > 
> > Ahh, just found a bug. Now that we can initialize the grace_list
> > independently of the lockd_manager, we must ensure that we initialize
> > the lockd_manager's list_head in lockd_init_net. So, we need to add
> > this in here:
> > 
> > 	INIT_LIST_HEAD(&ln->lockd_manager.list);
> > 
> > ...or we can end up oopsing if sm-notify runs and writes to the
> > nlm_grace_end file before lockd comes up.
> > 
> > I've fixed this in my tree, but I'll wait to resend just yet to see
> > whether there are any more comments on the rest of the set.
> 
> I don't have any more comments.  I can fix this up if this is all there
> is to do, or you can resend or give me a git url.--b.
> 

That's all there is that needs fixing, AFAIK.

The fix is in my tree at:

    git://git.samba.org/jlayton/linux.git

in my nfsd-3.18 branch. Thanks for reviewing and merging it.

The only remaining bit is to make sure that Steve D. (or anyone else
for that matter) has no problem with the userland piece.

Steve, does the v4 userland set look OK to you?

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
