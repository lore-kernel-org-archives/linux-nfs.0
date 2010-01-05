From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: fix peername failed on closed listener
Date: Tue, 5 Jan 2010 18:01:31 -0500
Message-ID: <20100105230131.GA22850@fieldses.org>
References: <1262227956-21470-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1262227956-21470-1-git-send-email-dfeng@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 31, 2009 at 10:52:36AM +0800, Xiaotian Feng wrote:
> There're some warnings of "nfsd: peername failed (err 107)!"
> socket error -107 means Transport endpoint is not connected.
> This warning message was outputed by svc_tcp_accept() [net/sunrpc/svcsock.c],
> when kernel_getpeername returns -107. This means socket might be CLOSED.
> 
> And svc_tcp_accept was called by svc_recv() [net/sunrpc/svc_xprt.c]
> 
>         if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
>         <snip>
>                 newxpt = xprt->xpt_ops->xpo_accept(xprt);
>         <snip>
> 
> So this might happen when xprt->xpt_flags has both XPT_LISTENER and XPT_CLOSE.
> 
> Let's take a look at commit b0401d72, this commit has moved the close
> processing after do recvfrom method, but this commit also introduces this
> warnings, if the xpt_flags has both XPT_LISTENER and XPT_CLOSED, we should
> close it, not accpet then close.

The logic here seems unnecessarily complicated now, but as a minimal
fix, this seems fine.

Is the *only* justification for this to silence this warning, or is
there some more serious problem I'm missing?

--b.

> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 1c924ee..187f0f4 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -699,7 +699,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  	spin_unlock_bh(&pool->sp_lock);
>  
>  	len = 0;
> -	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
> +	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
> +	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
>  		struct svc_xprt *newxpt;
>  		newxpt = xprt->xpt_ops->xpo_accept(xprt);
>  		if (newxpt) {
