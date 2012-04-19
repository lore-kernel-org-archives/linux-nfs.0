Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:41249 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab2DSLhE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 07:37:04 -0400
Message-ID: <4F8FF8D9.5080503@parallels.com>
Date: Thu, 19 Apr 2012 15:36:57 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: skip dead but not buried clients on PipeFS events
References: <20120419105707.32131.79719.stgit@localhost6.localdomain6>
In-Reply-To: <20120419105707.32131.79719.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, but ignore this patch too.
It can't be that simple because of these cl_count tricks in rpc_release_client...

19.04.2012 14:57, Stanislav Kinsbursky пишет:
> These clients can't be safely dereferenced if their counter in 0.
>
> Signee-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> ---
>   net/sunrpc/clnt.c |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 6797246..591994d 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -218,7 +218,8 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
>   		if (((event == RPC_PIPEFS_MOUNT)&&  clnt->cl_dentry) ||
>   		    ((event == RPC_PIPEFS_UMOUNT)&&  !clnt->cl_dentry))
>   			continue;
> -		atomic_inc(&clnt->cl_count);
> +		if (atomic_inc_return(&clnt->cl_count) == 1)
> +			continue;
>   		spin_unlock(&sn->rpc_client_lock);
>   		return clnt;
>   	}
>


-- 
Best regards,
Stanislav Kinsbursky
