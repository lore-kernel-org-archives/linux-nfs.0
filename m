Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 213CAC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:20:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EE517217D7
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:20:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726880AbeLROU5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:20:57 -0500
Received: from mx1.redhat.com ([209.132.183.28]:3161 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726469AbeLROU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:20:57 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A532F81DE1;
        Tue, 18 Dec 2018 14:20:56 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5EC1127C20;
        Tue, 18 Dec 2018 14:20:56 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id F135E207AD; Tue, 18 Dec 2018 09:20:55 -0500 (EST)
Date:   Tue, 18 Dec 2018 09:20:55 -0500
From:   Scott Mayhew <smayhew@redhat.com>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     Dave Wysochanski <dwysocha@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Message-ID: <20181218142055.GK27213@coeurl.usersys.redhat.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 18 Dec 2018 14:20:56 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I ran Dave's test in a loop over night with these 3 patches on top of
v4.20-rc7 and didn't see any more of the XPRT_WRITE_SPACE hangs.

-Scott

On Mon, 17 Dec 2018, Trond Myklebust wrote:

> When the socket is closed, we need to call xprt_disconnect_done() in order
> to clean up the XPRT_WRITE_SPACE flag, and wake up the sleeping tasks.
> 
> However, we also want to ensure that we don't wake them up before the socket
> is closed, since that would cause thundering herd issues with everyone
> piling up to retransmit before the TCP shutdown dance has completed.
> Only the task that holds XPRT_LOCKED needs to wake up early in order to
> allow the close to complete.
> 
> Reported-by: Dave Wysochanski <dwysocha@redhat.com>
> Reported-by: Scott Mayhew <smayhew@redhat.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  net/sunrpc/clnt.c     | 1 +
>  net/sunrpc/xprt.c     | 5 ++++-
>  net/sunrpc/xprtsock.c | 6 ++----
>  3 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index c6782aa47525..24cbddc44c88 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1952,6 +1952,7 @@ call_connect_status(struct rpc_task *task)
>  		/* retry with existing socket, after a delay */
>  		rpc_delay(task, 3*HZ);
>  		/* fall through */
> +	case -ENOTCONN:
>  	case -EAGAIN:
>  		/* Check for timeouts before looping back to call_bind */
>  	case -ETIMEDOUT:
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ce927002862a..3fb001dff670 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -680,7 +680,9 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
>  	/* Try to schedule an autoclose RPC call */
>  	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
>  		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
> -	xprt_wake_pending_tasks(xprt, -EAGAIN);
> +	else if (xprt->snd_task)
> +		rpc_wake_up_queued_task_set_status(&xprt->pending,
> +				xprt->snd_task, -ENOTCONN);
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
>  EXPORT_SYMBOL_GPL(xprt_force_disconnect);
> @@ -852,6 +854,7 @@ static void xprt_connect_status(struct rpc_task *task)
>  	case -ENETUNREACH:
>  	case -EHOSTUNREACH:
>  	case -EPIPE:
> +	case -ENOTCONN:
>  	case -EAGAIN:
>  		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
>  		break;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8a5e823e0b33..4c471b4235ba 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1217,6 +1217,8 @@ static void xs_reset_transport(struct sock_xprt *transport)
>  
>  	trace_rpc_socket_close(xprt, sock);
>  	sock_release(sock);
> +
> +	xprt_disconnect_done(xprt);
>  }
>  
>  /**
> @@ -1237,8 +1239,6 @@ static void xs_close(struct rpc_xprt *xprt)
>  
>  	xs_reset_transport(transport);
>  	xprt->reestablish_timeout = 0;
> -
> -	xprt_disconnect_done(xprt);
>  }
>  
>  static void xs_inject_disconnect(struct rpc_xprt *xprt)
> @@ -1489,8 +1489,6 @@ static void xs_tcp_state_change(struct sock *sk)
>  					&transport->sock_state))
>  			xprt_clear_connecting(xprt);
>  		clear_bit(XPRT_CLOSING, &xprt->state);
> -		if (sk->sk_err)
> -			xprt_wake_pending_tasks(xprt, -sk->sk_err);
>  		/* Trigger the socket release */
>  		xs_tcp_force_close(xprt);
>  	}
> -- 
> 2.19.2
> 
