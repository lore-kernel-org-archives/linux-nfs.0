Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bollo.wholemeal.co.nz ([120.138.17.108]:53785 "EHLO
	bollo.wholemeal.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab1HVXGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 19:06:54 -0400
Date: Tue, 23 Aug 2011 11:06:41 +1200
From: Malcolm Locke <malc@wholemeal.co.nz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Message-ID: <20110822230640.GB3069@rudy>
References: <20110808125114.GB5217@rudy>
 <20110815132130.GC28629@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110815132130.GC28629@fieldses.org>
Subject: Re: Problems with locking, permanent 'lockd: server in grace
 period'
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 09:21:30AM -0400, J. Bruce Fields wrote:
> On Tue, Aug 09, 2011 at 12:51:14AM +1200, Malcolm Locke wrote:
> > First off, apologies for bringing such mundane matters to the list, but
> > we're at the end of our tethers and way out of our depth on this.  We
> > have a problem on our production machine that we are unable to replicate
> > on a test machine, and would greatly appreciate any pointers of where to
> > look next.
> > 
> > We're in the process of upgrading a DRBD pair running Ubuntu hardy to
> > Debian squeeze.  The first of the pair has been upgraded, and NFS works
> > correctly except for locking.  Calls to flock() from any client on an
> > NFS mount hang indefinitely.
> > 
> > We've installed a fresh Debian squeeze machine to test, but are
> > completely unable to reproduce the issue.

OK, I've finally managed to reproduce this on our test machine.  Given
the package list below:

> > Pertinent details about the
> > set up:
> > 
> > Kernel on both machines:
> >   Linux debian 2.6.32-5-openvz-amd64 #1 SMP Tue Jun 14 10:46:15 UTC 2011
> >   x86_64 GNU/Linux
> > 
> >   Debian package versions:
> >   nfs-common 1.2.2-4
> >   nfs-kernel-server 1.2.2-4
> >   rpcbind 0.2.0-4.1

And the following /etc/exports:

  /home        192.168.200.0/24(rw,no_root_squash,async,no_subtree_check)
  /nfs4        192.168.200.0/24(rw,sync,fsid=0,crossmnt)
  /nfs4/flum   192.168.200.0/24(rw,sync)
  
After a fresh boot:

  # Just mount and unmount a v4 mount (192.168.200.187 == localhost)
  $ mount -t nfs4 192.168.200.187:/flum /mnt
  $ umount /mnt
  
  $ /etc/init.d/nfs-kernel-server stop
  # Comment out the v4 entries from /etc/exports, so only /home remains,
  # and restart the server so v4 is disabled.
  $ /etc/init.d/nfs-kernel-server start

  # Mount with v3
  $ mount 192.168.200.187:/home /mnt

  # Now trying to flock() will fail, with server staying in grace period
  # ad infinitum
  $ flock /mnt/foo ls

I'm not sure if this is the exact sequence of events we had to get
things stuck on our production machine (it's possible), but this
sequence will always get the server into indefinite grace period for me.

> 
> It might be worth trying this in addition to the recoverydir fixes
> previously posted.

Thanks, I haven't had the opportunity to try this yet but will do so on
the test machine and report back if I get time.

> commit c52560f10794b9fb8c050532d27ff999d8f5c23c
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Aug 12 11:59:44 2011 -0400
> 
>     some grace period fixes and debugging
> 
> diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
> index 183cc1f..61272f7 100644
> --- a/fs/lockd/grace.c
> +++ b/fs/lockd/grace.c
> @@ -22,6 +22,7 @@ static DEFINE_SPINLOCK(grace_lock);
>  void locks_start_grace(struct lock_manager *lm)
>  {
>  	spin_lock(&grace_lock);
> +	printk("lm->name starting grace period\n");
>  	list_add(&lm->list, &grace_list);
>  	spin_unlock(&grace_lock);
>  }
> @@ -40,6 +41,7 @@ EXPORT_SYMBOL_GPL(locks_start_grace);
>  void locks_end_grace(struct lock_manager *lm)
>  {
>  	spin_lock(&grace_lock);
> +	printk("%s ending grace period\n", lm->name);
>  	list_del_init(&lm->list);
>  	spin_unlock(&grace_lock);
>  }
> @@ -54,6 +56,15 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
>   */
>  int locks_in_grace(void)
>  {
> -	return !list_empty(&grace_list);
> +	if (!list_empty(&grace_list)) {
> +		struct lock_manager *lm;
> +
> +		printk("in grace period due to: ");
> +		list_for_each_entry(lm, &grace_list, list)
> +			printk("%s ",lm->name);
> +		printk("\n");
> +		return 1;
> +	}
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(locks_in_grace);
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index c061b9a..1638929 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -84,6 +84,7 @@ static unsigned long get_lockd_grace_period(void)
>  }
>  
>  static struct lock_manager lockd_manager = {
> +	.name = "lockd"
>  };
>  
>  static void grace_ender(struct work_struct *not_used)
> @@ -97,8 +98,8 @@ static void set_grace_period(void)
>  {
>  	unsigned long grace_period = get_lockd_grace_period();
>  
> -	locks_start_grace(&lockd_manager);
>  	cancel_delayed_work_sync(&grace_period_end);
> +	locks_start_grace(&lockd_manager);
>  	schedule_delayed_work(&grace_period_end, grace_period);
>  }
>  
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3787ec1..b83ffdf 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2942,6 +2942,7 @@ out:
>  }
>  
>  static struct lock_manager nfsd4_manager = {
> +	.name = "nfsd4",
>  };
>  
>  static void
> @@ -4563,7 +4564,6 @@ __nfs4_state_start(void)
>  	int ret;
>  
>  	boot_time = get_seconds();
> -	locks_start_grace(&nfsd4_manager);
>  	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
>  	       nfsd4_grace);
>  	ret = set_callback_cred();
> @@ -4575,6 +4575,7 @@ __nfs4_state_start(void)
>  	ret = nfsd4_create_callback_queue();
>  	if (ret)
>  		goto out_free_laundry;
> +	locks_start_grace(&nfsd4_manager);
>  	queue_delayed_work(laundry_wq, &laundromat_work, nfsd4_grace * HZ);
>  	set_max_delegations();
>  	return 0;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index ad35091..9501aa7 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1098,6 +1098,7 @@ struct lock_manager_operations {
>  };
>  
>  struct lock_manager {
> +	char *name;
>  	struct list_head list;
>  };
>  
