Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37274 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933255AbeAITTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 14:19:38 -0500
Date: Tue, 9 Jan 2018 14:19:37 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: remove dead code in svc_sock_setbufsize
Message-ID: <20180109191937.GA18087@fieldses.org>
References: <20180108112104.3006-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180108112104.3006-1-hch@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.16.--b.

On Mon, Jan 08, 2018 at 12:21:04PM +0100, Christoph Hellwig wrote:
> Setting values in struct sock directly is the usual method.  Remove
> the long dead code using set_fs() and the related comment.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  net/sunrpc/svcsock.c | 14 --------------
>  1 file changed, 14 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index ff8e06cd067e..5884583f93a4 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -384,25 +384,11 @@ static int svc_partial_recvfrom(struct svc_rqst *rqstp,
>  static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
>  				unsigned int rcv)
>  {
> -#if 0
> -	mm_segment_t	oldfs;
> -	oldfs = get_fs(); set_fs(KERNEL_DS);
> -	sock_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
> -			(char*)&snd, sizeof(snd));
> -	sock_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
> -			(char*)&rcv, sizeof(rcv));
> -#else
> -	/* sock_setsockopt limits use to sysctl_?mem_max,
> -	 * which isn't acceptable.  Until that is made conditional
> -	 * on not having CAP_SYS_RESOURCE or similar, we go direct...
> -	 * DaveM said I could!
> -	 */
>  	lock_sock(sock->sk);
>  	sock->sk->sk_sndbuf = snd * 2;
>  	sock->sk->sk_rcvbuf = rcv * 2;
>  	sock->sk->sk_write_space(sock->sk);
>  	release_sock(sock->sk);
> -#endif
>  }
>  
>  static int svc_sock_secure_port(struct svc_rqst *rqstp)
> -- 
> 2.14.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
