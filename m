Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:38114 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406Ab1LAVtU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 16:49:20 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc/nfs: don't allow TASK_KILLABLE sleeps to block the freezer
Date: Thu, 1 Dec 2011 22:52:13 +0100
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, tj@kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
References: <1322775223-19115-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1322775223-19115-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Message-Id: <201112012252.13568.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday, December 01, 2011, Jeff Layton wrote:
> Allow the freezer to skip wait_on_bit_killable sleeps in the sunrpc
> layer. This should allow suspend and hibernate events to proceed, even
> when there are RPC's pending on the wire.
> 
> Also, wrap the TASK_KILLABLE sleeps in NFS layer in freezer_do_not_count
> and freezer_count calls. This allows the freezer to skip tasks that are
> sleeping while looping on EJUKEBOX or NFS4ERR_DELAY sorts of errors.
> 
> Rafael, I've gone ahead and combined the two patches into one here
> and rebased this on top of the pm-freezer branch. Let me know if you'd
> prefer to keep it as two patches.

One patch is just fine for me, applied to linux-pm/linux-next.

Thanks,
Rafael


> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/inode.c          |    3 ++-
>  fs/nfs/nfs3proc.c       |    3 ++-
>  fs/nfs/nfs4proc.c       |    5 +++--
>  fs/nfs/proc.c           |    3 ++-
>  include/linux/freezer.h |   28 ++++++++++++++++++++++++++++
>  net/sunrpc/sched.c      |    3 ++-
>  6 files changed, 39 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 50a15fa..bf3a57b 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -38,6 +38,7 @@
>  #include <linux/nfs_xdr.h>
>  #include <linux/slab.h>
>  #include <linux/compat.h>
> +#include <linux/freezer.h>
>  
>  #include <asm/system.h>
>  #include <asm/uaccess.h>
> @@ -77,7 +78,7 @@ int nfs_wait_bit_killable(void *word)
>  {
>  	if (fatal_signal_pending(current))
>  		return -ERESTARTSYS;
> -	schedule();
> +	freezable_schedule();
>  	return 0;
>  }
>  
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index d4bc9ed9..9194395 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -17,6 +17,7 @@
>  #include <linux/nfs_page.h>
>  #include <linux/lockd/bind.h>
>  #include <linux/nfs_mount.h>
> +#include <linux/freezer.h>
>  
>  #include "iostat.h"
>  #include "internal.h"
> @@ -32,7 +33,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
>  		res = rpc_call_sync(clnt, msg, flags);
>  		if (res != -EJUKEBOX && res != -EKEYEXPIRED)
>  			break;
> -		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
> +		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
>  		res = -ERESTARTSYS;
>  	} while (!fatal_signal_pending(current));
>  	return res;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index be2bbac..b28bb19 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -53,6 +53,7 @@
>  #include <linux/sunrpc/bc_xprt.h>
>  #include <linux/xattr.h>
>  #include <linux/utsname.h>
> +#include <linux/freezer.h>
>  
>  #include "nfs4_fs.h"
>  #include "delegation.h"
> @@ -241,7 +242,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
>  		*timeout = NFS4_POLL_RETRY_MIN;
>  	if (*timeout > NFS4_POLL_RETRY_MAX)
>  		*timeout = NFS4_POLL_RETRY_MAX;
> -	schedule_timeout_killable(*timeout);
> +	freezable_schedule_timeout_killable(*timeout);
>  	if (fatal_signal_pending(current))
>  		res = -ERESTARTSYS;
>  	*timeout <<= 1;
> @@ -3950,7 +3951,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
>  static unsigned long
>  nfs4_set_lock_task_retry(unsigned long timeout)
>  {
> -	schedule_timeout_killable(timeout);
> +	freezable_schedule_timeout_killable(timeout);
>  	timeout <<= 1;
>  	if (timeout > NFS4_LOCK_MAXTIMEOUT)
>  		return NFS4_LOCK_MAXTIMEOUT;
> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index f48125d..0c672588 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -41,6 +41,7 @@
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
>  #include <linux/lockd/bind.h>
> +#include <linux/freezer.h>
>  #include "internal.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_PROC
> @@ -59,7 +60,7 @@ nfs_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
>  		res = rpc_call_sync(clnt, msg, flags);
>  		if (res != -EKEYEXPIRED)
>  			break;
> -		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
> +		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
>  		res = -ERESTARTSYS;
>  	} while (!fatal_signal_pending(current));
>  	return res;
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index c1ee283..30f06c2 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -105,6 +105,29 @@ static inline int freezer_should_skip(struct task_struct *p)
>  }
>  
>  /*
> + * These macros are intended to be used whenever you want allow a task that's
> + * sleeping in TASK_UNINTERRUPTIBLE or TASK_KILLABLE state to be frozen. Note
> + * that neither return any clear indication of whether a freeze event happened
> + * while in this function.
> + */
> +
> +/* Like schedule(), but should not block the freezer. */
> +#define freezable_schedule()						\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule();							\
> +	freezer_count();						\
> +})
> +
> +/* Like schedule_timeout_killable(), but should not block the freezer. */
> +#define freezable_schedule_timeout_killable(timeout)			\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule_timeout_killable(timeout);				\
> +	freezer_count();						\
> +})
> +
> +/*
>   * Freezer-friendly wrappers around wait_event_interruptible(),
>   * wait_event_killable() and wait_event_interruptible_timeout(), originally
>   * defined in <linux/wait.h>
> @@ -163,6 +186,11 @@ static inline void freezer_count(void) {}
>  static inline int freezer_should_skip(struct task_struct *p) { return 0; }
>  static inline void set_freezable(void) {}
>  
> +#define freezable_schedule()  schedule()
> +
> +#define freezable_schedule_timeout_killable(timeout)			\
> +	schedule_timeout_killable(timeout)
> +
>  #define wait_event_freezable(wq, condition)				\
>  		wait_event_interruptible(wq, condition)
>  
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index d12ffa5..5317b93 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -18,6 +18,7 @@
>  #include <linux/smp.h>
>  #include <linux/spinlock.h>
>  #include <linux/mutex.h>
> +#include <linux/freezer.h>
>  
>  #include <linux/sunrpc/clnt.h>
>  
> @@ -231,7 +232,7 @@ static int rpc_wait_bit_killable(void *word)
>  {
>  	if (fatal_signal_pending(current))
>  		return -ERESTARTSYS;
> -	schedule();
> +	freezable_schedule();
>  	return 0;
>  }
>  
> 

