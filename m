From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrdma: fix error handling of rdma_alloc_frmr()
Date: Mon, 29 Jun 2009 10:55:23 -0400
Message-ID: <20090629145523.GD4945@fieldses.org>
References: <4A4336E0.4020202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A4336E0.4020202@cn.fujitsu.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, queued up for 2.6.31.  Looks obvious correct, but runtime
testing from anyone would always be appreciated.

--b.

On Thu, Jun 25, 2009 at 04:35:44PM +0800, Wei Yongjun wrote:
> ib_alloc_fast_reg_mr() and ib_alloc_fast_reg_page_list() returns
> ERR_PTR() and not NULL. Compile tested only.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 5151f9f..0cf5e8c 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -730,12 +730,12 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>  		goto err;
>  
>  	mr = ib_alloc_fast_reg_mr(xprt->sc_pd, RPCSVC_MAXPAGES);
> -	if (!mr)
> +	if (IS_ERR(mr))
>  		goto err_free_frmr;
>  
>  	pl = ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
>  					 RPCSVC_MAXPAGES);
> -	if (!pl)
> +	if (IS_ERR(pl))
>  		goto err_free_mr;
>  
>  	frmr->mr = mr;
> -- 
> 1.6.2.2
> 
> 
> 
> 
