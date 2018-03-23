Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8707 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752101AbeCWSyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 14:54:38 -0400
Subject: Re: [PATCH net-next nfs 5/6] net: Convert nfs4blocklayout_net_ops
To: Kirill Tkhai <ktkhai@virtuozzo.com>, <davem@davemloft.net>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <dhowells@redhat.com>,
        <keescook@chromium.org>, <dwindsor@gmail.com>,
        <ishkamiel@gmail.com>, <elena.reshetova@intel.com>,
        <linux-nfs@vger.kernel.org>, <linux-afs@lists.infradead.org>,
        <netdev@vger.kernel.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <152093819834.8636.8992014016092587849.stgit@localhost.localdomain>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <719a8b9c-eb07-716c-c536-2956df08e2a7@Netapp.com>
Date: Fri, 23 Mar 2018 14:54:09 -0400
MIME-Version: 1.0
In-Reply-To: <152093819834.8636.8992014016092587849.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/13/2018 06:49 AM, Kirill Tkhai wrote:
> These pernet_operations create and destroy per-net pipe
> and dentry, and they seem safe to be marked as async.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Anna Schumaker <Anna.Schumaker@netapp.com>

> ---
>  fs/nfs/blocklayout/rpc_pipefs.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
> index 9fb067a6f7e0..ef9fa111b009 100644
> --- a/fs/nfs/blocklayout/rpc_pipefs.c
> +++ b/fs/nfs/blocklayout/rpc_pipefs.c
> @@ -261,6 +261,7 @@ static void nfs4blocklayout_net_exit(struct net *net)
>  static struct pernet_operations nfs4blocklayout_net_ops = {
>  	.init = nfs4blocklayout_net_init,
>  	.exit = nfs4blocklayout_net_exit,
> +	.async = true,
>  };
>  
>  int __init bl_init_pipefs(void)
> 
