From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Thu, 27 Mar 2008 15:54:45 -0400
Message-ID: <20080327195445.GI32540@fieldses.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: Olga Kornievskaia <aglo@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757413AbYC0Tys (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 15:54:48 -0400
In-Reply-To: <1206643752-11132-1-git-send-email-aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 27, 2008 at 02:49:12PM -0400, Olga Kornievskaia wrote:
> When the client's callback server goes away, the server's callback client
> tries to contact the server and times out. For nfsd, it is beneficial to
> printout a message when the client is unable to contact the server. For
> the callback server, the same message is printed yet it is really not
> an error. Thus we need a way to silence the message for the callback 
> and yet print it for other cases.
> 
> Signed-off-by: Olga Kornievskaia <aglo@umich.edu>
> ---
>  fs/nfsd/nfs4callback.c      |    1 +
>  include/linux/sunrpc/clnt.h |    1 +
>  net/sunrpc/clnt.c           |    6 ++++--
>  3 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index aae2b29..bf7d57e 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -400,6 +400,7 @@ static int do_probe_callback(void *data)
>  		status = PTR_ERR(client);
>  		goto out_err;
>  	}
> +	client->cl_quiet = 1;
>  
>  	status = rpc_call_sync(client, &msg, RPC_TASK_SOFT);
>  
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 129a86e..0a1141e 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -57,6 +57,7 @@ struct rpc_clnt {
>  	struct rpc_timeout	cl_timeout_default;
>  	struct rpc_program *	cl_program;
>  	char			cl_inline_name[32];
> +	int                     cl_quiet; /* silences call_timeout printk */
>  };
>  
>  /*
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 8c6a7f1..5a2a718 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1160,8 +1160,10 @@ call_timeout(struct rpc_task *task)
>  	task->tk_timeouts++;
>  
>  	if (RPC_IS_SOFT(task)) {
> -		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
> -				clnt->cl_protname, clnt->cl_server);
> +		if (!clnt->cl_quiet)
> +			printk(KERN_NOTICE "%s: server %s not responding, "
> +				"timed out\n", clnt->cl_protname, 

Run linux/scripts/checkpath.pl on patches and it'll warn you about silly
stuff like the extra space at the end of that line.

Other than that--I'd like to do this.  Trond?

--b.

> +				clnt->cl_server);
>  		rpc_exit(task, -EIO);
>  		return;
>  	}
> -- 
> 1.5.3.3
> 
