Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32325 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171AbaFXP67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2014 11:58:59 -0400
Message-ID: <53A9A03F.9050103@netapp.com>
Date: Tue, 24 Jun 2014 11:58:55 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 13/13] xprtrdma: Handle additional connection events
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <20140623224048.1634.23972.stgit@manet.1015granger.net>
In-Reply-To: <20140623224048.1634.23972.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/23/2014 06:40 PM, Chuck Lever wrote:
> Commit 38ca83a5 added RDMA_CM_EVENT_TIMEWAIT_EXIT. But that status
> is relevant only for consumers that re-use their QPs on new
> connections. xprtrdma creates a fresh QP on reconnection, so that
> event should be explicitly ignored.
>
> Squelch the alarming "unexpected CM event" message.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |   27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index ec98e48..dbd5f22 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -334,8 +334,16 @@ static const char * const conn[] = {
>  	"rejected",
>  	"established",
>  	"disconnected",
> -	"device removal"
> +	"device removal",
> +	"multicast join",
> +	"multicast error",
> +	"address change",
> +	"timewait exit",
>  };
> +
> +#define CONNECTION_MSG(status)						\
> +	((status) < ARRAY_SIZE(conn) ?					\
> +		conn[(status)] : "unrecognized connection error")
>  #endif
>  
>  static int
> @@ -393,13 +401,10 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
>  	case RDMA_CM_EVENT_DEVICE_REMOVAL:
>  		connstate = -ENODEV;
>  connected:
> -		dprintk("RPC:       %s: %s: %pI4:%u (ep 0x%p event 0x%x)\n",
> -			__func__,
> -			(event->event <= 11) ? conn[event->event] :
> -						"unknown connection error",
> -			&addr->sin_addr.s_addr,
> -			ntohs(addr->sin_port),
> -			ep, event->event);
> +		dprintk("RPC:       %s: %pI4:%u (ep 0x%p): %s\n",
> +			__func__, &addr->sin_addr.s_addr,
> +			ntohs(addr->sin_port), ep,
> +			CONNECTION_MSG(event->event));
>  		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
>  		dprintk("RPC:       %s: %sconnected\n",
>  					__func__, connstate > 0 ? "" : "dis");
> @@ -408,8 +413,10 @@ connected:
>  		wake_up_all(&ep->rep_connect_wait);
>  		break;
>  	default:
> -		dprintk("RPC:       %s: unexpected CM event %d\n",
> -			__func__, event->event);
> +		dprintk("RPC:       %s: %pI4:%u (ep 0x%p): %s\n",
> +			__func__, &addr->sin_addr.s_addr,
> +			ntohs(addr->sin_port), ep,
> +			CONNECTION_MSG(event->event));

These two dprintk()s are exactly the same, and only a few lines apart.  Is there some way to combine them? (I'm just curious, not saying that you need to!)

Anna
>  		break;
>  	}
>  
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

