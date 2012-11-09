Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36127 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab2KIH7u convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 02:59:50 -0500
Message-ID: <509CB7EA.5000106@parallels.com>
Date: Fri, 9 Nov 2012 11:59:38 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] SUNRPC: Fix validity issues with rpc_pipefs sb->s_fs_info
References: <1352393506-39590-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1352393506-39590-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

08.11.2012 20:51, Trond Myklebust пишет:
> rpc_kill_sb() must defer calling put_net() until after the notifier
> has been called, since most (all?) of the notifier callbacks assume
> that sb->s_fs_info points to a valid net namespace. It also must not
> call put_net() if the call to rpc_fill_super was unsuccessful.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Cc: stable@vger.kernel.org [>= v3.4]
> ---
>   net/sunrpc/rpc_pipe.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 21fde99..2a419f1 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1152,14 +1152,19 @@ static void rpc_kill_sb(struct super_block *sb)
>   	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>
>   	mutex_lock(&sn->pipefs_sb_lock);
> +	if (sn->pipefs_sb != sb) {
> +		mutex_unlock(&sn->pipefs_sb_lock);
> +		goto out;
> +	}
>   	sn->pipefs_sb = NULL;
>   	mutex_unlock(&sn->pipefs_sb_lock);
> -	put_net(net);
>   	dprintk("RPC:	sending pipefs UMOUNT notification for net %p%s\n", net,
>   								NET_NAME(net));
>   	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
>   					   RPC_PIPEFS_UMOUNT,
>   					   sb);
> +	put_net(net);
> +out:
>   	kill_litter_super(sb);
>   }
>
>


-- 
Best regards,
Stanislav Kinsbursky
