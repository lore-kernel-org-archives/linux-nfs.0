Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15735 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932527Ab2CFRoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 12:44:12 -0500
Message-ID: <4F564CCD.9040708@parallels.com>
Date: Tue, 06 Mar 2012 21:43:41 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v9 3/6] nfsd: add a per-net-namespace struct for nfsd
References: <1331047733-1641-1-git-send-email-jlayton@redhat.com> <1331047733-1641-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1331047733-1641-4-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.03.2012 19:28, Jeff Layton пишет:
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 64c24af..141197e 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -19,6 +19,7 @@
>   #include "nfsd.h"
>   #include "cache.h"
>   #include "fault_inject.h"
> +#include "netns.h"
>
>   /*
>    *	We have a single directory with several nodes in it.
> @@ -1124,14 +1125,23 @@ static int create_proc_exports_entry(void)
>   }
>   #endif
>
> +int nfsd_net_id;
> +static struct pernet_operations nfsd_net_ops = {
> +	.id   =&nfsd_net_id,
> +	.size = sizeof(struct nfsd_net),
> +};
> +
>   static int __init init_nfsd(void)
>   {
>   	int retval;
>   	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
>
> +	retval = register_pernet_subsys(&nfsd_net_ops);

Hi, Jeff.
You've created per-net structure and operations and that's cool.
But why don't you move nfsd client tracking control into per-net operations?
I.e. add init-exit callbacks in struct pernet_operations and call 
nfsd4_client_tracking_init() and nfsd4_client_tracking_exit() respectively in there?
And since we don't support any other networks namesapce except init_net, then 
just skip all others in these callbacks.


> +	if (retval<  0)
> +		return retval;
>   	retval = nfsd4_init_slabs();
>   	if (retval)
> -		return retval;
> +		goto out_unregister_pernet;
>   	nfs4_state_init();
>   	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>   	if (retval)
> @@ -1169,6 +1179,8 @@ out_free_stat:
>   	nfsd_fault_inject_cleanup();
>   out_free_slabs:
>   	nfsd4_free_slabs();
> +out_unregister_pernet:
> +	unregister_pernet_subsys(&nfsd_net_ops);
>   	return retval;
>   }
>
> @@ -1184,6 +1196,7 @@ static void __exit exit_nfsd(void)
>   	nfsd4_free_slabs();
>   	nfsd_fault_inject_cleanup();
>   	unregister_filesystem(&nfsd_fs_type);
> +	unregister_pernet_subsys(&nfsd_net_ops);
>   }
>
>   MODULE_AUTHOR("Olaf Kirch<okir@monad.swb.de>");


-- 
Best regards,
Stanislav Kinsbursky
