Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755398AbbDUTYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 15:24:00 -0400
Date: Tue, 21 Apr 2015 15:23:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
Cc: linux-nfs@vger.kernel.org, alexander.sverdlin@nokia.com,
        stable@vger.kernel.org,
        Lorenzo Restelli <lorenzo.restelli.ext@nokia.com>
Subject: Re: [PATCH v2] nfsd: fix: prevent BUG_ON by registering
 rpc_pipefs_event only after nfsd_net_id is valid
Message-ID: <20150421192358.GB13782@fieldses.org>
References: <1429545608-9903-1-git-send-email-giuseppe.cantavenera.ext@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1429545608-9903-1-git-send-email-giuseppe.cantavenera.ext@nokia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 20, 2015 at 06:00:08PM +0200, Giuseppe Cantavenera wrote:
> nfsd triggered a BUG_ON in net_generic(...) when rpc_pipefs_event(...)
> in fs/nfsd/nfs4recover.c was called before assigning ntfsd_net_id.
> The following was observed on a MIPS 32-core processor:
> kernel: Call Trace:
> kernel: [<ffffffffc00bc5e4>] rpc_pipefs_event+0x7c/0x158 [nfsd]
> kernel: [<ffffffff8017a2a0>] notifier_call_chain+0x70/0xb8
> kernel: [<ffffffff8017a4e4>] __blocking_notifier_call_chain+0x4c/0x70
> kernel: [<ffffffff8053aff8>] rpc_fill_super+0xf8/0x1a0
> kernel: [<ffffffff8022204c>] mount_ns+0xb4/0xf0
> kernel: [<ffffffff80222b48>] mount_fs+0x50/0x1f8
> kernel: [<ffffffff8023dc00>] vfs_kern_mount+0x58/0xf0
> kernel: [<ffffffff802404ac>] do_mount+0x27c/0xa28
> kernel: [<ffffffff80240cf0>] SyS_mount+0x98/0xe8
> kernel: [<ffffffff80135d24>] handle_sys64+0x44/0x68
> kernel:
> kernel:
>         Code: 0040f809  00000000  2e020001 <00020336> 3c12c00d
>                 3c02801a  de100000 6442eb98  0040f809
> kernel: ---[ end trace 7471374335809536 ]---
> 
> Fixed this behaviour by calling register_pernet_subsys(&nfsd_net_ops) before
> registering rpc_pipefs_event(...) with the notifier chain.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
> Signed-off-by: Lorenzo Restelli <lorenzo.restelli.ext@nokia.com>
> ---
>  v2: Rebased, retested, added CC for the stable tree,
>      minor changes to the commit message

Got it, thanks.--b.

> 
>  The previous version was not from the mainline, 
>  sorry for that.
>  
>  Regards,
>  Giuseppe
> 
>  fs/nfsd/nfsctl.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index aa47d75..9690cb4 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1250,15 +1250,15 @@ static int __init init_nfsd(void)
>  	int retval;
>  	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
>  
> -	retval = register_cld_notifier();
> -	if (retval)
> -		return retval;
>  	retval = register_pernet_subsys(&nfsd_net_ops);
>  	if (retval < 0)
> -		goto out_unregister_notifier;
> -	retval = nfsd4_init_slabs();
> +		return retval;
> +	retval = register_cld_notifier();
>  	if (retval)
>  		goto out_unregister_pernet;
> +	retval = nfsd4_init_slabs();
> +	if (retval)
> +		goto out_unregister_notifier;
>  	retval = nfsd4_init_pnfs();
>  	if (retval)
>  		goto out_free_slabs;
> @@ -1290,10 +1290,10 @@ out_exit_pnfs:
>  	nfsd4_exit_pnfs();
>  out_free_slabs:
>  	nfsd4_free_slabs();
> -out_unregister_pernet:
> -	unregister_pernet_subsys(&nfsd_net_ops);
>  out_unregister_notifier:
>  	unregister_cld_notifier();
> +out_unregister_pernet:
> +	unregister_pernet_subsys(&nfsd_net_ops);
>  	return retval;
>  }
>  
> @@ -1308,8 +1308,8 @@ static void __exit exit_nfsd(void)
>  	nfsd4_exit_pnfs();
>  	nfsd_fault_inject_cleanup();
>  	unregister_filesystem(&nfsd_fs_type);
> -	unregister_pernet_subsys(&nfsd_net_ops);
>  	unregister_cld_notifier();
> +	unregister_pernet_subsys(&nfsd_net_ops);
>  }
>  
>  MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
> -- 
> 1.9.1
