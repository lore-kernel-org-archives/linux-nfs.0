Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:8155 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708Ab3FYQNG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:13:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH v3 2/4] SUNRPC: fix races on PipeFS UMOUNT notifications
Date: Tue, 25 Jun 2013 16:13:05 +0000
Message-ID: <1372176778.5968.29.camel@leira.trondhjem.org>
References: <20130624075131.17104.55399.stgit@localhost.localdomain>
	 <20130624075245.17104.6279.stgit@localhost.localdomain>
In-Reply-To: <20130624075245.17104.6279.stgit@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-06-24 at 11:52 +0400, Stanislav Kinsbursky wrote:
> CPU#0                                   CPU#1
> -----------------------------           -----------------------------
> rpc_kill_sb
> sn->pipefs_sb = NULL                    rpc_release_client
> (UMOUNT_EVENT)                          rpc_free_auth
> rpc_pipefs_event
> rpc_get_client_for_event
> !atomic_inc_not_zero(cl_count)
> <skip the client>
>                                         atomic_inc(cl_count)
>                                         rpc_free_client
>                                         rpc_clnt_remove_pipedir
>                                         <skip client dir removing>
> 
> To fix this, this patch does the following:
> 
> 1) Calls RPC_PIPEFS_UMOUNT notification with sn->pipefs_sb_lock being held.
> 2) Removes SUNRPC client from the list AFTER pipes destroying.
> 3) Doesn't hold RPC client on notification: if client in the list, then it
> can't be destroyed while sn->pipefs_sb_lock in hold by notification caller.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Cc: stable@vger.kernel.org
> ---
>  net/sunrpc/clnt.c     |    5 +----
>  net/sunrpc/rpc_pipe.c |    2 +-
>  2 files changed, 2 insertions(+), 5 deletions(-)

<snip>

> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index c512448..efca2f7 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1165,7 +1165,6 @@ static void rpc_kill_sb(struct super_block *sb)
>  		goto out;
>  	}
>  	sn->pipefs_sb = NULL;
> -	mutex_unlock(&sn->pipefs_sb_lock);
>  	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
>  		net, NET_NAME(net));
>  	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
> @@ -1173,6 +1172,7 @@ static void rpc_kill_sb(struct super_block *sb)
>  					   sb);
>  	put_net(net);
>  out:
> +	mutex_unlock(&sn->pipefs_sb_lock);

Is this safe to do after the put_net()?

>  	kill_litter_super(sb);
>  }
>  
> 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
