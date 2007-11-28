From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] sunrpc: don't xprt_complete_rqst on truncated tcp replies
Date: Wed, 28 Nov 2007 14:04:09 -0500
Message-ID: <7324CF92-34F2-4CC3-B4D6-168C07499F22@oracle.com>
References: <1196274435-30152-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1196274435-30152-1-git-send-email-bhalevy@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny-

On Nov 28, 2007, at 1:27 PM, Benny Halevy wrote:
> processing a truncated reply can cause havoc and it is
> probably better to drop it instead.

Actually, wouldn't a truncated reply be a sign that the server or  
client RPC stream has become out of sync?  Perhaps it would be better  
to drop the connection in this case?

> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/xprtsock.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 2f630a5..92e94d3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -937,8 +937,7 @@ static inline void xs_tcp_read_request(struct  
> rpc_xprt *xprt, struct xdr_skb_rea
>  		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
>  		dprintk("RPC:       XID %08x request not found!\n",
>  				ntohl(transport->tcp_xid));
> -		spin_unlock(&xprt->transport_lock);
> -		return;
> +		goto error;
>  	}
>
>  	rcvbuf = &req->rq_private_buf;
> @@ -978,7 +977,7 @@ static inline void xs_tcp_read_request(struct  
> rpc_xprt *xprt, struct xdr_skb_rea
>  				"tcp_offset = %u, tcp_reclen = %u\n",
>  				xprt, transport->tcp_copied,
>  				transport->tcp_offset, transport->tcp_reclen);
> -		goto out;
> +		goto error;
>  	}
>
>  	dprintk("RPC:       XID %08x read %Zd bytes\n",
> @@ -994,11 +993,14 @@ static inline void xs_tcp_read_request(struct  
> rpc_xprt *xprt, struct xdr_skb_rea
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
>  static inline void xs_tcp_read_discard(struct sock_xprt  
> *transport, struct xdr_skb_reader *desc)
> -- 
> 1.5.3.3
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
