From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 12/15] net: sunrpc: removed duplicated #include
Date: Thu, 5 Aug 2010 11:09:20 -0400
Message-ID: <20100805150920.GB27141@fieldses.org>
References: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
 <1281016299-23958-12-git-send-email-andrea.gelmini@gelma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gelma-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: Andrea Gelmini <andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426Ab0HEPKx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 11:10:53 -0400
In-Reply-To: <1281016299-23958-12-git-send-email-andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 05, 2010 at 03:51:36PM +0200, Andrea Gelmini wrote:
> Signed-off-by: Andrea Gelmini <andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>

Thanks, applied for 2.6.36.

--b.

> ---
>  net/sunrpc/cache.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 58de76c..b75879b 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -34,7 +34,6 @@
>  #include <linux/sunrpc/cache.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
> -#include <linux/smp_lock.h>
>  
>  #define	 RPCDBG_FACILITY RPCDBG_CACHE
>  
> -- 
> 1.7.2.1.85.g2d089
> 
