Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52997 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbcADWjc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 17:39:32 -0500
Date: Mon, 4 Jan 2016 17:39:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>,
        skinsbursky@parallels.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfsd: Fix nfsd leaks sunrpc module references
Message-ID: <20160104223930.GE30315@fieldses.org>
References: <20150911104517.GA4947@stefanha-thinkpad.home>
 <5689E3C9.1010708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5689E3C9.1010708@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 04, 2016 at 11:15:21AM +0800, Kinglong Mee wrote:
> Stefan Hajnoczi reports,
> nfsd leaks 3 references to the sunrpc module here:
> 
>   # echo -n "asdf 1234" >/proc/fs/nfsd/portlist
>   bash: echo: write error: Protocol not supported
> 
> Now stop nfsd and try unloading the kernel modules:
> 
>   # systemctl stop nfs-server
>   # systemctl stop nfs
>   # systemctl stop proc-fs-nfsd.mount
>   # systemctl stop var-lib-nfs-rpc_pipefs.mount
>   # rmmod nfsd
>   # rmmod nfs_acl
>   # rmmod lockd
>   # rmmod auth_rpcgss
>   # rmmod sunrpc
>   rmmod: ERROR: Module sunrpc is in use
>   # lsmod | grep rpc
>   sunrpc                315392  3
> 
> It is caused by nfsd don't cleanup rpcb program for nfsd
> when destroying svc service after creating xprt fail.
> 
> Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfssvc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index ad4e237..543de5f 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -314,14 +314,13 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
>  	 * write_ports can create the server without actually starting
>  	 * any threads--if we get shut down before any threads are
>  	 * started, then nfsd_last_thread will be run before any of this
> -	 * other initialization has been done.
> +	 * other initialization has been done except the rpcb information.
>  	 */
> +	svc_rpcb_cleanup(serv, net);

Are you sure this is right?

For example, nfsd_create_serv calls svc_destroy on svc_bind failure, is
it OK to call svc_rpcb_cleanup in that case?

--b.

>  	if (!nn->nfsd_net_up)
>  		return;
> -	nfsd_shutdown_net(net);
> -
> -	svc_rpcb_cleanup(serv, net);
>  
> +	nfsd_shutdown_net(net);
>  	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
>  			    "cache\n");
>  	nfsd_export_flush(net);
> -- 
> 2.5.0
