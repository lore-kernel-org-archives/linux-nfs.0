Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:55078 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728303AbeICVwN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 17:52:13 -0400
Received: by mail-it0-f43.google.com with SMTP id f14-v6so1910864ita.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 10:31:04 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 23/27] SUNRPC: Move RPC retransmission stat counter to
 xprt_transmit()
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20180903152936.24325-24-trond.myklebust@hammerspace.com>
Date: Mon, 3 Sep 2018 13:31:02 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <04E670C0-FEEA-4D9D-8EAE-CD67F1BAD1BE@gmail.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
 <20180903152936.24325-14-trond.myklebust@hammerspace.com>
 <20180903152936.24325-15-trond.myklebust@hammerspace.com>
 <20180903152936.24325-16-trond.myklebust@hammerspace.com>
 <20180903152936.24325-17-trond.myklebust@hammerspace.com>
 <20180903152936.24325-18-trond.myklebust@hammerspace.com>
 <20180903152936.24325-19-trond.myklebust@hammerspace.com>
 <20180903152936.24325-20-trond.myklebust@hammerspace.com>
 <20180903152936.24325-21-trond.myklebust@hammerspace.com>
 <20180903152936.24325-22-trond.myklebust@hammerspace.com>
 <20180903152936.24325-23-trond.myklebust@hammerspace.com>
 <20180903152936.24325-24-trond.myklebust@hammerspace.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do you also need to move req->rq_ntrans++ ?


> On Sep 3, 2018, at 11:29 AM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 6 ------
> net/sunrpc/xprt.c | 4 ++++
> 2 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 585a82dfaf4d..fb40d1e9f636 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1967,8 +1967,6 @@ call_connect_status(struct rpc_task *task)
> static void
> call_transmit(struct rpc_task *task)
> {
> -	int is_retrans = RPC_WAS_SENT(task);
> -
> 	dprint_status(task);
> 
> 	task->tk_action = call_transmit_status;
> @@ -1979,10 +1977,6 @@ call_transmit(struct rpc_task *task)
> 	if (!xprt_prepare_transmit(task))
> 		return;
> 	xprt_transmit(task);
> -	if (task->tk_status < 0)
> -		return;
> -	if (is_retrans)
> -		task->tk_client->cl_stats->rpcretrans++;
> }
> 
> /*
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 95d15d4017f7..b85e2c4fa115 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1126,6 +1126,7 @@ void xprt_transmit(struct rpc_task *task)
> 	struct rpc_rqst	*req = task->tk_rqstp;
> 	struct rpc_xprt	*xprt = req->rq_xprt;
> 	unsigned int connect_cookie;
> +	int is_retrans = RPC_WAS_SENT(task);
> 	int status;
> 
> 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
> @@ -1148,6 +1149,9 @@ void xprt_transmit(struct rpc_task *task)
> 		return;
> 	}
> 
> +	if (is_retrans)
> +		task->tk_client->cl_stats->rpcretrans++;
> +
> 	xprt_inject_disconnect(xprt);
> 
> 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
> -- 
> 2.17.1
> 

--
Chuck Lever
chucklever@gmail.com
