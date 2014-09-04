Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.cs.uchicago.edu ([128.135.164.214]:58567 "EHLO
	mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaIDUwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 16:52:35 -0400
Message-ID: <5408CEB6.7040000@cs.uchicago.edu>
Date: Thu, 04 Sep 2014 15:42:30 -0500
From: Colin Hudler <chudler@cs.uchicago.edu>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: kernel not recovering from statd port change
References: <20140821213421.GA5474@fieldses.org>
In-Reply-To: <20140821213421.GA5474@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been debugging the same thing on an Ubuntu 12.04 server running 
3.8.0-44, and ended up in the same place you are.  Did you find out 
anything more? I have carefully inserted rpc_force_rebind() near 
nlm_client_get, but I don't think it is a good fix for others.

In production servers, I am starting rpc.statd with "--port #####", 
which does seem to solve the problem. NLM (vs NSM) apparently doesn't 
suffer from it.

One thing that puzzles me is that of several hundred NFS clients only a 
handful have a problem getting a lock. The problem clients are running 
3.2 and 2.6.26. The not-problem clients are 3.8 mostly. NFSv3.

On 08/21/2014 04:34 PM, J. Bruce Fields wrote:
> While testing server restart somebody noticed that knfsd can't recover
> from statd restarting with a new port.
>
>  From only a very quick skim of the code it looked like creating the nsm
> client with RPC_CLNT_CREATE_AUTOBIND should cause us to call rpcbind
> again on connection failures, but that doesn't seem to be working.
>
> Any ideas?  I'll keep looking....
>
> --b.
>
> commit 2c9fb5570fe2
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Aug 20 17:21:32 2014 -0400
>
>      lockd: allow rebinding to statd
>
>      During normal operation statd isn't restarted, but it may be if, for
>      example, the server is shut down and restarted to simulate a shutdown or
>      perform some kind of failover.  In that case the kernel may need to
>      query rpcbind again to get statd's new port number.
>
>      Symptoms were locking failures after a manual server restart (without
>      rebooting the machine), and loopback network traces showing the new
>      kernel nfsd attempting to contact statd at its old port number.
>
>      This was probably introduced by cb7323fffa85, which first allowed
>      reusing the statd rpc client, but it looks like a reference count may
>      typically have prevented any symptoms until e498daa81295 "LOCKD: Clear
>      ln->nsm_clnt only when ln->nsm_users is zero".
>
>      Fixes: cb7323fffa85 "lockd: create and use per-net NSM RPC clients on MON/UNMON requests"
>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 1812f026960c..3bce1d318435 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -80,7 +80,8 @@ static struct rpc_clnt *nsm_create(struct net *net)
>   		.program		= &nsm_program,
>   		.version		= NSM_VERSION,
>   		.authflavor		= RPC_AUTH_NULL,
> -		.flags			= RPC_CLNT_CREATE_NOPING,
> +		.flags			= RPC_CLNT_CREATE_NOPING|
> +			                  RPC_CLNT_CREATE_AUTOBIND,
>   	};
>
>   	return rpc_create(&args);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
