Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39765 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdHROkr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 10:40:47 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/8] SUNRPC: ECONNREFUSED should cause a rebind.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <150304037184.30218.7244179303036576085.stgit@noble>
Date: Fri, 18 Aug 2017 10:40:36 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <EA245E4A-892D-4534-8402-DD62545CEF8E@oracle.com>
References: <150304014011.30218.1636255532744321171.stgit@noble> <150304037184.30218.7244179303036576085.stgit@noble>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 18, 2017, at 3:12 AM, NeilBrown <neilb@suse.com> wrote:
> 
> If you
> - mount and NFSv3 filesystem
> - do some file locking which requires the server
>   to make a GRANT call back
> - unmount
> - mount again and do the same locking
> 
> then the second attempt at locking suffers a 30 second delay.
> Unmounting and remounting causes lockd to stop and restart,
> which causes it to bind to a new port.
> The server still thinks the old port is valid and gets ECONNREFUSED
> when trying to contact it.
> ECONNREFUSED should be seen as a hard error that is not worth
> retrying.  Rebinding is the only reasonable response.
> 
> This patch forces a rebind if that makes sense.

I also reported this problem recently, and found a similar
(but rather lockd-centric) solution.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> net/sunrpc/clnt.c |    8 ++++++++
> 1 file changed, 8 insertions(+)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 2e49d1f892b7..69a9e5953744 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1903,6 +1903,14 @@ call_connect_status(struct rpc_task *task)
> 	task->tk_status = 0;
> 	switch (status) {
> 	case -ECONNREFUSED:
> +		/* A positive refusal suggests a rebind is needed. */
> +		if (RPC_IS_SOFTCONN(task))
> +			break;
> +		if (clnt->cl_autobind) {
> +			rpc_force_rebind(clnt);
> +			task->tk_action = call_bind;
> +			return;
> +		}
> 	case -ECONNRESET:
> 	case -ECONNABORTED:
> 	case -ENETUNREACH:
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



