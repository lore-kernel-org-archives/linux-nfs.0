From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/8] SUNRPC: Don't display the rpc_show_tasks header if
	there are no tasks
Date: Mon, 19 May 2008 12:19:43 -0400
Message-ID: <20080519161943.GI7622@fieldses.org>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021636.8366.81782.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43855 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbYESQUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 12:20:01 -0400
In-Reply-To: <20080518021636.8366.81782.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 17, 2008 at 10:16:36PM -0400, Chuck Lever wrote:
> Clean up: don't display the rpc_show_tasks column header unless there is at
> least one task to display.  As far as I can tell, it is safe to let the
> list_for_each_entry macro decide that each list is empty.

That second list_empty() check is just before a spin_lock(); I wonder if
it was intended to avoid having to acquire a lot of spinlocks on
inactive clients?  Wouldn't have thought that was a worthwhile
optimization, but I don't know.

--b.

> 
> scripts/checkpatch.pl also wants a KERN_FOO at the start of any newly added
> printk() calls, so this and subsequent patches will also add KERN_INFO.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/clnt.c |   19 ++++++++++++-------
>  1 files changed, 12 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 5aa32fa..1a12236 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1517,24 +1517,30 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
>  EXPORT_SYMBOL_GPL(rpc_call_null);
>  
>  #ifdef RPC_DEBUG
> +static void rpc_show_header(void)
> +{
> +	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
> +		"-timeout -rpcwait -action- ---ops--\n");
> +}
> +
>  void rpc_show_tasks(void)
>  {
>  	struct rpc_clnt *clnt;
>  	struct rpc_task *t;
> +	int header = 0;
>  
>  	spin_lock(&rpc_client_lock);
> -	if (list_empty(&all_clients))
> -		goto out;
> -	printk("-pid- proc flgs status -client- -prog- --rqstp- -timeout "
> -		"-rpcwait -action- ---ops--\n");
>  	list_for_each_entry(clnt, &all_clients, cl_clients) {
> -		if (list_empty(&clnt->cl_tasks))
> -			continue;
>  		spin_lock(&clnt->cl_lock);
>  		list_for_each_entry(t, &clnt->cl_tasks, tk_task) {
>  			const char *rpc_waitq = "none";
>  			int proc;
>  
> +			if (!header) {
> +				rpc_show_header();
> +				header++;
> +			}
> +
>  			if (t->tk_msg.rpc_proc)
>  				proc = t->tk_msg.rpc_proc->p_proc;
>  			else
> @@ -1554,7 +1560,6 @@ void rpc_show_tasks(void)
>  		}
>  		spin_unlock(&clnt->cl_lock);
>  	}
> -out:
>  	spin_unlock(&rpc_client_lock);
>  }
>  #endif
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
