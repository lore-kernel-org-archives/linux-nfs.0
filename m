From: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Subject: Re: [PATCH] sunrpc: fix peername failed on closed listener
Date: Mon, 4 Jan 2010 08:12:17 +0100
Message-ID: <20100104071216.GA14930@develbox.linuxbox.cz>
References: <1262227956-21470-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>,
	nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org, stable@kernel.org
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:41815 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab0ADHMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2010 02:12:30 -0500
In-Reply-To: <1262227956-21470-1-git-send-email-dfeng@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(CCing stable@kernel.org)
Greg, once this patch is ACKed, can You also queue it for 
2.6.32.x please?
thanks!
nik

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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
-------------------------------------
