Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f177.google.com ([209.85.160.177]:47578 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbaH1Xx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2014 19:53:29 -0400
Received: by mail-yk0-f177.google.com with SMTP id 200so957419ykr.8
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2014 16:53:28 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 28 Aug 2014 19:53:26 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] lockd: move lockd's grace period handling into
 its own module
Message-ID: <20140828195326.100c15a9@synchrony.poochiereds.net>
In-Reply-To: <20140828202442.GC25203@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<1408473509-14010-2-git-send-email-jlayton@primarydata.com>
	<20140828200059.GB25203@fieldses.org>
	<20140828202442.GC25203@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 Aug 2014 16:24:43 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Aug 28, 2014 at 04:01:00PM -0400, J. Bruce Fields wrote:
> > On Tue, Aug 19, 2014 at 02:38:25PM -0400, Jeff Layton wrote:
> > > Currently, all of the grace period handling is part of lockd. Eventually
> > > though we'd like to be able to build v4-only servers, at which point
> > > we'll need to put all of this elsewhere.
> > > 
> > > Move the code itself into fs/nfs_common and have it build a grace.ko
> > > module. Then, rejigger the Kconfig options so that both nfsd and lockd
> > > enable it automatically.
> > 
> > Thanks, applying this one for 3.18 indepedently of the others.
> 
> This code should also be fixed, though.
> 
> Currently nfsd is recording the grace period as done when its own timer
> runs out, but then it continuing to accept reclaims until lockd is also
> done.
> 
> This is an unusual bug to actually hit in part because lockd's grace
> period is by default less than nfsd's.
> 
> Your code introduces new cases when nfsd's grace period could end before
> lockd's, but in all of them future reclaims would be denied (because the
> only clients active on last shutdown would be 4.1 clients that have all
> issued RECLAIM_COMPLETE, so reclaims are all going to be denied).
> 
> So maybe it's not urgent.
> 
> --b.
> 

Yeah, I don't really see a bug here...

We'll only lift the nfsd grace period once all the v4.1 clients have
sent a RECLAIM_COMPLETE and if there aren't any v4.0 ones. At that
point, no one should be sending any reclaims but we'll still allow them
if the lockd grace period hasn't been lifted yet.

I suppose that we could deny them in principle, but there doesn't seem
to be any real harm in allowing it to happen. The simple "fix" for it
would be to have nfs4_check_open_reclaim do a test for
NFSD4_CLIENT_RECLAIM_COMPLETE, and reject the reclaim request if it has
been set.

It also occurs to me that we probably ought to have the nfsdcltrack
upcall set and test NFSD4_CLIENT_STABLE to reduce upcalls. The fact
that we don't do that there seems inefficient (though it shouldn't harm
correctness).

> > 
> > --b.
> > 
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > ---
> > >  fs/Kconfig                       |  6 +++-
> > >  fs/lockd/Makefile                |  2 +-
> > >  fs/lockd/netns.h                 |  1 -
> > >  fs/lockd/svc.c                   |  1 -
> > >  fs/nfs_common/Makefile           |  3 +-
> > >  fs/{lockd => nfs_common}/grace.c | 68 ++++++++++++++++++++++++++++++++++------
> > >  fs/nfsd/Kconfig                  |  1 +
> > >  include/linux/proc_fs.h          |  2 ++
> > >  8 files changed, 69 insertions(+), 15 deletions(-)
> > >  rename fs/{lockd => nfs_common}/grace.c (50%)
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
> > > index 8f27c93f8d2e..3599c9ca28ae 100644
> > > --- a/fs/lockd/svc.c
> > > +++ b/fs/lockd/svc.c
> > > @@ -583,7 +583,6 @@ static int lockd_init_net(struct net *net)
> > >  	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > >  
> > >  	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
> > > -	INIT_LIST_HEAD(&ln->grace_list);
> > >  	spin_lock_init(&ln->nsm_clnt_lock);
> > >  	return 0;
> > >  }
> > > diff --git a/fs/nfs_common/Makefile b/fs/nfs_common/Makefile
> > > index f689ed82af3a..d153ca3ea577 100644
> > > --- a/fs/nfs_common/Makefile
> > > +++ b/fs/nfs_common/Makefile
> > > @@ -3,5 +3,6 @@
> > >  #
> > >  
> > >  obj-$(CONFIG_NFS_ACL_SUPPORT) += nfs_acl.o
> > > -
> > >  nfs_acl-objs := nfsacl.o
> > > +
> > > +obj-$(CONFIG_GRACE_PERIOD) += grace.o
> > > diff --git a/fs/lockd/grace.c b/fs/nfs_common/grace.c
> > > similarity index 50%
> > > rename from fs/lockd/grace.c
> > > rename to fs/nfs_common/grace.c
> > > index 6d1ee7204c88..ae6e58ea4de5 100644
> > > --- a/fs/lockd/grace.c
> > > +++ b/fs/nfs_common/grace.c
> > > @@ -1,17 +1,20 @@
> > >  /*
> > >   * Common code for control of lockd and nfsv4 grace periods.
> > > + *
> > > + * Transplanted from lockd code
> > >   */
> > >  
> > >  #include <linux/module.h>
> > > -#include <linux/lockd/bind.h>
> > >  #include <net/net_namespace.h>
> > > +#include <net/netns/generic.h>
> > > +#include <linux/fs.h>
> > >  
> > > -#include "netns.h"
> > > -
> > > +static int grace_net_id;
> > >  static DEFINE_SPINLOCK(grace_lock);
> > >  
> > >  /**
> > >   * locks_start_grace
> > > + * @net: net namespace that this lock manager belongs to
> > >   * @lm: who this grace period is for
> > >   *
> > >   * A grace period is a period during which locks should not be given
> > > @@ -21,18 +24,20 @@ static DEFINE_SPINLOCK(grace_lock);
> > >   *
> > >   * This function is called to start a grace period.
> > >   */
> > > -void locks_start_grace(struct net *net, struct lock_manager *lm)
> > > +void
> > > +locks_start_grace(struct net *net, struct lock_manager *lm)
> > >  {
> > > -	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > > +	struct list_head *grace_list = net_generic(net, grace_net_id);
> > >  
> > >  	spin_lock(&grace_lock);
> > > -	list_add(&lm->list, &ln->grace_list);
> > > +	list_add(&lm->list, grace_list);
> > >  	spin_unlock(&grace_lock);
> > >  }
> > >  EXPORT_SYMBOL_GPL(locks_start_grace);
> > >  
> > >  /**
> > >   * locks_end_grace
> > > + * @net: net namespace that this lock manager belongs to
> > >   * @lm: who this grace period is for
> > >   *
> > >   * Call this function to state that the given lock manager is ready to
> > > @@ -41,7 +46,8 @@ EXPORT_SYMBOL_GPL(locks_start_grace);
> > >   * Note that callers count on it being safe to call this more than once,
> > >   * and the second call should be a no-op.
> > >   */
> > > -void locks_end_grace(struct lock_manager *lm)
> > > +void
> > > +locks_end_grace(struct lock_manager *lm)
> > >  {
> > >  	spin_lock(&grace_lock);
> > >  	list_del_init(&lm->list);
> > > @@ -56,10 +62,52 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
> > >   * to answer ordinary lock requests, and when they should accept only
> > >   * lock reclaims.
> > >   */
> > > -int locks_in_grace(struct net *net)
> > > +int
> > > +locks_in_grace(struct net *net)
> > >  {
> > > -	struct lockd_net *ln = net_generic(net, lockd_net_id);
> > > +	struct list_head *grace_list = net_generic(net, grace_net_id);
> > >  
> > > -	return !list_empty(&ln->grace_list);
> > > +	return !list_empty(grace_list);
> > >  }
> > >  EXPORT_SYMBOL_GPL(locks_in_grace);
> > > +
> > > +static int __net_init
> > > +grace_init_net(struct net *net)
> > > +{
> > > +	struct list_head *grace_list = net_generic(net, grace_net_id);
> > > +
> > > +	INIT_LIST_HEAD(grace_list);
> > > +	return 0;
> > > +}
> > > +
> > > +static void __net_exit
> > > +grace_exit_net(struct net *net)
> > > +{
> > > +	struct list_head *grace_list = net_generic(net, grace_net_id);
> > > +
> > > +	BUG_ON(!list_empty(grace_list));
> > > +}
> > > +
> > > +static struct pernet_operations grace_net_ops = {
> > > +	.init = grace_init_net,
> > > +	.exit = grace_exit_net,
> > > +	.id   = &grace_net_id,
> > > +	.size = sizeof(struct list_head),
> > > +};
> > > +
> > > +static int __init
> > > +init_grace(void)
> > > +{
> > > +	return register_pernet_subsys(&grace_net_ops);
> > > +}
> > > +
> > > +static void __exit
> > > +exit_grace(void)
> > > +{
> > > +	unregister_pernet_subsys(&grace_net_ops);
> > > +}
> > > +
> > > +MODULE_AUTHOR("Jeff Layton <jlayton@primarydata.com>");
> > > +MODULE_LICENSE("GPL");
> > > +module_init(init_grace)
> > > +module_exit(exit_grace)
> > > diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> > > index f994e750e0d1..4fa98764de21 100644
> > > --- a/fs/nfsd/Kconfig
> > > +++ b/fs/nfsd/Kconfig
> > > @@ -71,6 +71,7 @@ config NFSD_V4
> > >  	select FS_POSIX_ACL
> > >  	select SUNRPC_GSS
> > >  	select CRYPTO
> > > +	select GRACE_PERIOD
> > >  	help
> > >  	  This option enables support in your system's NFS server for
> > >  	  version 4 of the NFS protocol (RFC 3530).
> > > diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> > > index 9d117f61d976..b97bf2ef996e 100644
> > > --- a/include/linux/proc_fs.h
> > > +++ b/include/linux/proc_fs.h
> > > @@ -74,6 +74,8 @@ static inline int remove_proc_subtree(const char *name, struct proc_dir_entry *p
> > >  
> > >  #endif /* CONFIG_PROC_FS */
> > >  
> > > +struct net;
> > > +
> > >  static inline struct proc_dir_entry *proc_net_mkdir(
> > >  	struct net *net, const char *name, struct proc_dir_entry *parent)
> > >  {
> > > -- 
> > > 1.9.3
> > > 


-- 
Jeff Layton <jlayton@primarydata.com>
