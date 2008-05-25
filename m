From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrdma: Add flush_scheduled_work to module exit
	function
Date: Sun, 25 May 2008 15:01:37 -0400
Message-ID: <20080525190137.GD8094@fieldses.org>
References: <1211556685.4114.14.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102AbYEYTBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 May 2008 15:01:38 -0400
In-Reply-To: <1211556685.4114.14.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2008 at 10:31:25AM -0500, Tom Tucker wrote:
>     
> Make certain all transports pending free are flushed from the wq
> before unloading the module.

OK, makes sense.

--b.

>     
>     Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
> Thanks to Andrew for pointing this out.
> 
>  net/sunrpc/xprtrdma/svc_rdma.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> index 88c0ca2..b370e5c 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> @@ -236,6 +236,7 @@ static ctl_table svcrdma_root_table[] = {
>  void svc_rdma_cleanup(void)
>  {
>  	dprintk("SVCRDMA Module Removed, deregister RPC RDMA transport\n");
> +	flush_scheduled_work();
>  	if (svcrdma_table_header) {
>  		unregister_sysctl_table(svcrdma_table_header);
>  		svcrdma_table_header = NULL;
> 
