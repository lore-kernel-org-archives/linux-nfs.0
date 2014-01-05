Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35891 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbaAETyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 14:54:09 -0500
Date: Sun, 5 Jan 2014 14:54:07 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: Re: [PATCH 4/4] SUNRPC: Add tracepoint for socket errors
Message-ID: <20140105195407.GA22918@fieldses.org>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-3-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-4-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388518781-33571-4-git-send-email-trond.myklebust@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 31, 2013 at 02:39:41PM -0500, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  include/trace/events/sunrpc.h | 1 +
>  net/sunrpc/xprtsock.c         | 1 +
>  2 files changed, 2 insertions(+)

ACK to all these from me.  I'm assuming they'll go in through your tree
for 3.14.

--b.

> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index d51d16c7afd8..ddc179b7a105 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -301,6 +301,7 @@ DECLARE_EVENT_CLASS(xs_socket_event_done,
>  
>  DEFINE_RPC_SOCKET_EVENT(rpc_socket_state_change);
>  DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_connect);
> +DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_error);
>  DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
>  DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
>  DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ab006b7b7ab8..25dbfa971948 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -837,6 +837,7 @@ static void xs_error_report(struct sock *sk)
>  		goto out;
>  	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
>  			xprt, -err);
> +	trace_rpc_socket_error(xprt, sk->sk_socket, err);
>  	xprt_wake_pending_tasks(xprt, err);
>   out:
>  	read_unlock_bh(&sk->sk_callback_lock);
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
