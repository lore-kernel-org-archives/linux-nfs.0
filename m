Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56008 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab3LDVZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 16:25:34 -0500
Date: Wed, 4 Dec 2013 16:25:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weng Meiling <wengmeiling.weng@huawei.com>
Cc: stable@vger.kernel.org, skinsbursky@parallels.com,
        linux-nfs@vger.kernel.org, lizefan@huawei.com, h.huangqiang@huawei.com
Subject: Re: [PATCH 3.4 9/9] nfsd: use the current net ns in write_threads()
 and write_ports()
Message-ID: <20131204212532.GB19452@fieldses.org>
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
 <1386136415-30976-10-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386136415-30976-10-git-send-email-wengmeiling.weng@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:53:35PM +0800, Weng Meiling wrote:
> Upstream commit f7fb86c6e639360ad9c253cec534819ef928a674 (nfsd: use
> "init_net" for portmapper) introduced a bug.
> 
> Starting NFSd in a non init_net network namespace will lead to
> NULL pointer deference. Because RPCBIND client will be NULL when register
> RPC service with the local portmapper in svc_addsock().
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000060
> IP: [<ffffffffa0439150>] call_start+0x10/0x30 [sunrpc]
> ...
> Pid: 27770, comm: rpc.nfsd ...
> RIP: 0010:[<ffffffffa0439150>]  [<ffffffffa0439150>] call_start+0x10/0x30 [sunrpc]
> ...
>   [<ffffffffa0442841>] __rpc_execute+0x91/0x160 [sunrpc]
>   [<ffffffffa0442981>] rpc_execute+0x71/0x80 [sunrpc]
>   [<ffffffffa043ab49>] rpc_run_task+0x89/0xa0 [sunrpc]
>   [<ffffffffa043ac5d>] rpc_call_sync+0x3d/0x70 [sunrpc]
>   [<ffffffffa044b316>] rpcb_register+0xa6/0xd0 [sunrpc]
>   [<ffffffffa0444ede>] __svc_register+0x1ae/0x1c0 [sunrpc]
>   [<ffffffff8114f975>] ? cache_alloc_refill+0x85/0x290
>   [<ffffffffa0444f7f>] svc_register+0x8f/0xc0 [sunrpc]
>   [<ffffffff811504f3>] ? kmem_cache_alloc_trace+0xc3/0x1d0
>   [<ffffffffa04472f8>] svc_setup_socket+0x1a8/0x2c0 [sunrpc]
>   [<ffffffff81009546>] ? read_tsc+0x16/0x40
>   [<ffffffffa0448078>] svc_addsock+0x118/0x1c0 [sunrpc]
>   [<ffffffff81090ee5>] ? do_gettimeofday+0x15/0x50
>   [<ffffffffa049e69c>] ? nfsd_create_serv+0xdc/0x150 [nfsd]
>   [<ffffffff8125605c>] ? simple_strtoull+0x2c/0x50
>   [<ffffffffa049fdce>] __write_ports+0x1fe/0x230 [nfsd]
>   [<ffffffffa049fe37>] write_ports+0x37/0x60 [nfsd]
>   [<ffffffffa049fe00>] ? __write_ports+0x230/0x230 [nfsd]
>   [<ffffffffa049edd2>] nfsctl_transaction_write+0x72/0x90 [nfsd]
>   [<ffffffff8116573b>] vfs_write+0xcb/0x130
>   [<ffffffff81165890>] sys_write+0x50/0x90
> 
> Fix it by using the current's network namespace so NFSd uses the
> consistent net ns all the time.

Everything else looks like a straightforward backport, but doing this
differently from upstream makes me nervous.  Don't we also want to take
11f779421a39b86da8a523d97e5fd3477878d44f "nfsd: containerize NFSd
filesystem" ?  (Stanislav?)

--b.

> 
> Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
> ---
>  fs/nfsd/nfsctl.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 1d74af2..4ff0db9 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -15,6 +15,7 @@
>  #include <linux/sunrpc/gss_krb5_enctypes.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
>  #include <linux/module.h>
> +#include <linux/nsproxy.h>
>  
>  #include "idmap.h"
>  #include "nfsd.h"
> @@ -389,7 +390,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
>  {
>  	char *mesg = buf;
>  	int rv;
> -	struct net *net = &init_net;
> +	struct net *net = current->nsproxy->net_ns;
>  
>  	if (size > 0) {
>  		int newthreads;
> @@ -857,7 +858,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
>  static ssize_t write_ports(struct file *file, char *buf, size_t size)
>  {
>  	ssize_t rv;
> -	struct net *net = &init_net;
> +	struct net *net = current->nsproxy->net_ns;
>  
>  	mutex_lock(&nfsd_mutex);
>  	rv = __write_ports(file, buf, size, net);
> -- 
> 1.8.2.2
> 
> 
