From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: don't xprt_complete_rqst on truncated tcp
	replies
Date: Wed, 28 Nov 2007 14:02:27 -0500
Message-ID: <1196276547.7100.23.camel@heimdal.trondhjem.org>
References: <1196274435-30152-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	nfsv4@linux-nfs.org, ricardo.labiaga@netapp.com
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:47127 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbXK1TCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2007 14:02:32 -0500
In-Reply-To: <1196274435-30152-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2007-11-28 at 20:27 +0200, Benny Halevy wrote:
> processing a truncated reply can cause havoc and it is
> probably better to drop it instead.

Actually, no... Reading the comment in the code, and looking more
closely at xdr_partial_copy_from_skb(), I now remember why we did this.

The only user of this code is normally the nfsacl stuff, which has the
usual problem that the reply can in theory be unlimited. If you just
drop the reply, then you get the unintended consequence that the request
will eventually time out, and just get resent (with possibly the same
result).
Normally, the XDR decoders should be able to deal with this sort of
problem. If the message is truncated for some reason, be it due to a
server bug or due to a resource issue in the RPC layer on the client, we
should still be able to detect that and recover. In this particular
case, we could set a flag in the xdr_buf in order to indicate that the
message was truncated by the client, but I'm not sure that is useful
since, as I said, we still have to deal with the case of a server that
sends a truncated RPC message.

Cheers
  Trond

> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/xprtsock.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 2f630a5..92e94d3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -937,8 +937,7 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
>  		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
>  		dprintk("RPC:       XID %08x request not found!\n",
>  				ntohl(transport->tcp_xid));
> -		spin_unlock(&xprt->transport_lock);
> -		return;
> +		goto error;
>  	}
>  
>  	rcvbuf = &req->rq_private_buf;
> @@ -978,7 +977,7 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
>  				"tcp_offset = %u, tcp_reclen = %u\n",
>  				xprt, transport->tcp_copied,
>  				transport->tcp_offset, transport->tcp_reclen);
> -		goto out;
> +		goto error;
>  	}
>  
>  	dprintk("RPC:       XID %08x read %Zd bytes\n",
> @@ -994,11 +993,14 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
>  			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
>  	}
>  
> -out:
>  	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>  		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
>  	spin_unlock(&xprt->transport_lock);
>  	xs_tcp_check_fraghdr(transport);
> +	return;
> +
> +error:
> +	spin_unlock(&xprt->transport_lock);
>  }
>  
>  static inline void xs_tcp_read_discard(struct sock_xprt *transport, struct xdr_skb_reader *desc)

