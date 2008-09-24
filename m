From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/10] svcrdma: Query device for Fast Reg support
	during connection setup
Date: Wed, 24 Sep 2008 16:10:55 -0400
Message-ID: <20080924201055.GA10841@fieldses.org>
References: <1221564879-85046-1-git-send-email-tom@opengridcomputing.com> <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com> <1221564879-85046-4-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59463 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbYIXUK5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 16:10:57 -0400
In-Reply-To: <1221564879-85046-4-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2008 at 06:34:32AM -0500, Tom Tucker wrote:
> Query the device capabilities in the svc_rdma_accept function to determine
> what advanced memory management capabilities are supported by the device.
> Based on the query, select the most secure model available given the
> requirements of the transport and capabilities of the adapter.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   86 +++++++++++++++++++++++++++--
>  1 files changed, 80 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index f200345..8586c7d 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -816,6 +816,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  	struct rdma_conn_param conn_param;
>  	struct ib_qp_init_attr qp_attr;
>  	struct ib_device_attr devattr;
> +	int dma_mr_acc;
>  	int ret;
>  	int i;
>  
> @@ -931,15 +932,88 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  	}
>  	newxprt->sc_qp = newxprt->sc_cm_id->qp;
>  
> -	/* Register all of physical memory */
> -	newxprt->sc_phys_mr = ib_get_dma_mr(newxprt->sc_pd,
> -					    IB_ACCESS_LOCAL_WRITE |
> -					    IB_ACCESS_REMOTE_WRITE);
> -	if (IS_ERR(newxprt->sc_phys_mr)) {
> -		dprintk("svcrdma: Failed to create DMA MR ret=%d\n", ret);
> +	/*
> +	 * Use the most secure set of MR resources based on the
> +	 * transport type and available memory management features in
> +	 * the device. Here's the table implemented below:
> +	 *
> +	 *		Fast	Global	DMA	Remote WR
> +	 *		Reg	LKEY	MR	Access
> +	 *		Sup'd	Sup'd	Needed	Needed
> +	 *
> +	 * IWARP	N	N	Y	Y
> +	 *		N	Y	Y	Y
> +	 *		Y	N	Y	N
> +	 *		Y	Y	N	-
> +	 *
> +	 * IB		N	N	Y	N
> +	 *		N	Y	N	-
> +	 *		Y	N	Y	N
> +	 *		Y	Y	N	-
> +	 *
> +	 * NB:	iWARP requires remote write access for the data sink
> +	 *	of an RDMA_READ. IB does not.
> +	 */
> +	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
> +		newxprt->sc_frmr_pg_list_len =
> +			devattr.max_fast_reg_page_list_len;
> +		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
> +		BUG_ON(!newxprt->sc_frmr_pg_list_len);
> +	}
> +
> +	/*
> +	 * Determine if a DMA MR is required and if so, what privs are required
> +	 */
> +	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
> +	case RDMA_TRANSPORT_IWARP:
> +		if (0 == (newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
> +			dma_mr_acc =
> +				(IB_ACCESS_LOCAL_WRITE |
> +				 IB_ACCESS_REMOTE_WRITE);
> +		} else if (0 == (devattr.device_cap_flags &
> +			       IB_DEVICE_LOCAL_DMA_LKEY)) {
> +			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
> +			newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
> +		} else {
> +			dma_mr_acc = 0;
> +			newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
> +		}
> +		break;
> +	case RDMA_TRANSPORT_IB:
> +		if ((0 == (newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) &&
> +		    (0 == (devattr.device_cap_flags &
> +			   IB_DEVICE_LOCAL_DMA_LKEY)))
> +			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
> +		else
> +			dma_mr_acc = 0;

This doesn't seem to agree exactly with the table above, e.g. in the IB

	Y	N	Y	N

case?  Of course, I may be misreading the table....

> +		break;
> +	default:
>  		goto errout;
>  	}
>  
> +	/*
> +	 * If we have a global dma lkey, use it for local access
> +	 */
> +	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)
> +		newxprt->sc_dma_lkey =
> +			newxprt->sc_cm_id->device->local_dma_lkey;
> +
> +	/*
> +	 * If local write was required for local access, the lcl dma
> +	 * lkey can't be used.
> +	 */
> +	if (dma_mr_acc) {
> +		/* Register all of physical memory */
> +		newxprt->sc_phys_mr =
> +			ib_get_dma_mr(newxprt->sc_pd, dma_mr_acc);
> +		if (IS_ERR(newxprt->sc_phys_mr)) {
> +			dprintk("svcrdma: Failed to create DMA MR ret=%d\n",
> +				ret);
> +			goto errout;
> +		}
> +		newxprt->sc_dma_lkey = newxprt->sc_phys_mr->lkey;
> +	}

Is it possible for neither of the above conditions to be true, and if so
is it a problem if newxprt->sc_dma_lkey doesn't get initialized?

--b.

> +
>  	/* Post receive buffers */
>  	for (i = 0; i < newxprt->sc_max_requests; i++) {
>  		ret = svc_rdma_post_recv(newxprt);
