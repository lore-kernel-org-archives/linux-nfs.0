Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52177 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752545AbeCWSyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 14:54:08 -0400
Subject: Re: [PATCH net-next nfs 4/6] net: Convert nfs4_dns_resolver_ops
To: Kirill Tkhai <ktkhai@virtuozzo.com>, <davem@davemloft.net>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <dhowells@redhat.com>,
        <keescook@chromium.org>, <dwindsor@gmail.com>,
        <ishkamiel@gmail.com>, <elena.reshetova@intel.com>,
        <linux-nfs@vger.kernel.org>, <linux-afs@lists.infradead.org>,
        <netdev@vger.kernel.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <152093818835.8636.5993458301872634002.stgit@localhost.localdomain>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <32c74ecc-a577-960b-523c-850068e56673@Netapp.com>
Date: Fri, 23 Mar 2018 14:53:57 -0400
MIME-Version: 1.0
In-Reply-To: <152093818835.8636.5993458301872634002.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/13/2018 06:49 AM, Kirill Tkhai wrote:
> These pernet_operations look similar to rpcsec_gss_net_ops,
> they just create and destroy another cache. Also they create
> and destroy directory. So, they also look safe to be async.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Anna Schumaker <Anna.Schumaker@netapp.com>

> ---
>  fs/nfs/dns_resolve.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 060c658eab66..e90bd69ab653 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -410,6 +410,7 @@ static void nfs4_dns_net_exit(struct net *net)
>  static struct pernet_operations nfs4_dns_resolver_ops = {
>  	.init = nfs4_dns_net_init,
>  	.exit = nfs4_dns_net_exit,
> +	.async = true,
>  };
>  
>  static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
> 
