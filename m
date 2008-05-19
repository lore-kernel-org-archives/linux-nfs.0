From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/8] SUNRPC: Add second output line for each RPC task
	in rpc_show_tasks
Date: Mon, 19 May 2008 12:21:18 -0400
Message-ID: <20080519162118.GJ7622@fieldses.org>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021650.8366.96474.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43859 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbYESQVg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 12:21:36 -0400
In-Reply-To: <20080518021650.8366.96474.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 17, 2008 at 10:16:50PM -0400, Chuck Lever wrote:
> Add a second output line displayed for each RPC task shown via
> rpc_show_tasks.  This second line is for non-columnar variable-length
> data (like the name of the RPC wait queue the task is waiting on, or
> the procedure name).

Maybe sample before and after output would help?

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/clnt.c |   20 ++++++++++----------
>  1 files changed, 10 insertions(+), 10 deletions(-)
> 
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 15c0f5b..1b2c766 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1519,29 +1519,29 @@ EXPORT_SYMBOL_GPL(rpc_call_null);
>  #ifdef RPC_DEBUG
>  static void rpc_show_header(void)
>  {
> -	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
> -		"-timeout -rpcwait -action- ---ops--\n");
> +	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
> +		"-timeout -action- ---ops--\n");
>  }
>  
>  static void rpc_show_task(const struct rpc_clnt *clnt,
>  			  const struct rpc_task *task)
>  {
>  	const char *rpc_waitq = "none";
> -	int proc = -1;
> +	const char *proc = "unspecified";
>  
>  	if (task->tk_msg.rpc_proc)
> -		proc = task->tk_msg.rpc_proc->p_proc;
> +		proc = task->tk_msg.rpc_proc->p_name;
>  
>  	if (RPC_IS_QUEUED(task))
>  		rpc_waitq = rpc_qname(task->tk_waitqueue);
>  
> -	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
> -		task->tk_pid, proc,
> -		task->tk_flags, task->tk_status,
> -		clnt, clnt->cl_prog,
> -		task->tk_rqstp, task->tk_timeout,
> -		rpc_waitq,
> +	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %8p\n",
> +		task->tk_pid, task->tk_flags, task->tk_status,
> +		clnt, task->tk_rqstp, task->tk_timeout,
>  		task->tk_action, task->tk_ops);
> +
> +	printk(KERN_INFO " prog: %s%u  proc: %s  waitq: %s\n",
> +		clnt->cl_protname, clnt->cl_vers, proc, rpc_waitq);
>  }
>  
>  void rpc_show_tasks(void)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
