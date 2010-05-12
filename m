From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/9] lockd: Add /sys/fs/lockd
Date: Wed, 12 May 2010 13:54:31 +1000
Message-ID: <20100512135431.1f26e421@notabene.brown>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
	<20100427185829.29074.77530.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56773 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753571Ab0ELDyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 23:54:43 -0400
In-Reply-To: <20100427185829.29074.77530.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Apr 2010 14:58:30 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Create the parent directory for all lockd-related sysfs entries.  The
> directory is created when lockd.ko is loaded, and removed when it is
> unloaded.

Can I argue about the colour of the bike shed please?

lockd is not a filesystem, so I would not put it in /sys/fs.

I think lockd has more in common with 'fscache' than with
'fuse' and 'ext4', so I think it should go in /sys/kernel
rather than /sys/fs.

Mind you, this comment is based on the assumption that /sys is different
to /proc in that it is better organised.  But I am beginning to wonder.


I know you would much rather a review of the rest of the series that this one
point and I apologise for not providing one.... maybe I'll motivate myself
sometime.

NeilBrown


> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/svc.c              |   16 +++++++++++++---
>  include/linux/lockd/lockd.h |    1 +
>  2 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index f1bacf1..c84a7d5 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -75,6 +75,8 @@ static const int		nlm_port_min = 0, nlm_port_max = 65535;
>  static struct ctl_table_header * nlm_sysctl_table;
>  #endif
>  
> +struct kobject			*nlm_kobj;
> +
>  static unsigned long get_lockd_grace_period(void)
>  {
>  	/* Note: nlm_timeout should always be nonzero */
> @@ -514,12 +516,19 @@ module_param(nlm_max_connections, uint, 0644);
>  
>  static int __init init_nlm(void)
>  {
> +	nlm_kobj = kobject_create_and_add("lockd", fs_kobj);
> +	if (!nlm_kobj)
> +		return -ENOMEM;
> +
>  #ifdef CONFIG_SYSCTL
>  	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
> -	return nlm_sysctl_table ? 0 : -ENOMEM;
> -#else
> -	return 0;
> +	if (!nlm_sysctl_table) {
> +		kobject_put(nlm_kobj);
> +		return -ENOMEM;
> +	}
>  #endif
> +
> +	return 0;
>  }
>  
>  static void __exit exit_nlm(void)
> @@ -529,6 +538,7 @@ static void __exit exit_nlm(void)
>  #ifdef CONFIG_SYSCTL
>  	unregister_sysctl_table(nlm_sysctl_table);
>  #endif
> +	kobject_put(nlm_kobj);
>  }
>  
>  module_init(init_nlm);
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index a34dea4..56c749e 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -196,6 +196,7 @@ extern int			nlmsvc_grace_period;
>  extern unsigned long		nlmsvc_timeout;
>  extern int			nsm_use_hostnames;
>  extern u32			nsm_local_state;
> +extern struct kobject		*nlm_kobj;
>  
>  /*
>   * Lockd client functions
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

