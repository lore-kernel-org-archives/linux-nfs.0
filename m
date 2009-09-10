Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbZIJQLu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 12:11:50 -0400
Date: Thu, 10 Sep 2009 12:11:52 -0400
To: Benny Halevy <bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 01/12] nfsd41: sunrpc: move struct rpc_buffer def
	into sunrpc.h
Message-ID: <20090910161152.GC11858@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574704-30039-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1252574704-30039-1-git-send-email-bhalevy@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 10, 2009 at 12:25:04PM +0300, Benny Halevy wrote:
> Move struct rpc_buffer's definition into a sunrpc.h, a common, internal
> header file, in preparation for supporting the nfsv4.1 backchannel.

Applied, thanks.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfs41: sunrpc: #include <linux/net.h> from sunrpc.h]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/sched.c  |    7 ++-----
>  net/sunrpc/sunrpc.h |   10 ++++++++++
>  2 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 8f459ab..cef74ba 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -21,6 +21,8 @@
>  
>  #include <linux/sunrpc/clnt.h>
>  
> +#include "sunrpc.h"
> +
>  #ifdef RPC_DEBUG
>  #define RPCDBG_FACILITY		RPCDBG_SCHED
>  #define RPC_TASK_MAGIC_ID	0xf00baa
> @@ -711,11 +713,6 @@ static void rpc_async_schedule(struct work_struct *work)
>  	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
>  }
>  
> -struct rpc_buffer {
> -	size_t	len;
> -	char	data[];
> -};
> -
>  /**
>   * rpc_malloc - allocate an RPC buffer
>   * @task: RPC task that will use this buffer
> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
> index 5d9dd74..13171e6 100644
> --- a/net/sunrpc/sunrpc.h
> +++ b/net/sunrpc/sunrpc.h
> @@ -27,6 +27,16 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>  #ifndef _NET_SUNRPC_SUNRPC_H
>  #define _NET_SUNRPC_SUNRPC_H
>  
> +#include <linux/net.h>
> +
> +/*
> + * Header for dynamically allocated rpc buffers.
> + */
> +struct rpc_buffer {
> +	size_t	len;
> +	char	data[];
> +};
> +
>  static inline int rpc_reply_expected(struct rpc_task *task)
>  {
>  	return (task->tk_msg.rpc_proc != NULL) &&
> -- 
> 1.6.4
> 
