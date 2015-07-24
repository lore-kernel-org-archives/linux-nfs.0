Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:49835 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbbGXQ51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jul 2015 12:57:27 -0400
Date: Fri, 24 Jul 2015 10:57:21 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
Message-ID: <20150724165721.GC25480@obsidianresearch.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161904.25617.85015.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150724161904.25617.85015.stgit@build2.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 24, 2015 at 11:19:05AM -0500, Steve Wise wrote:
> Add new register and unregister functions to be used with devices that
> support FRMRs, provide a local dma lkey, yet do not support DIF/PI.
> 
> isert_reg_frmr() only needs to use FRMRs for RDMA READ since RDMA WRITE
> can be handled entirely with the local dma lkey.  So for RDMA READ,
> it calls isert_reg_read_frmr().  Otherwise is uses the lkey map service
> isert_map_lkey() for RDMA WRITEs.
> 
> isert_reg_read_frmr() will create a linked list of WR triplets of the
> form: INV->FRWR->READ.  The number of these triplets is dependent on
> the devices fast reg page list length limit.

That ordering seems strange, surely it should be

FRWR->READ->INV

And use IB_WR_RDMA_READ_WITH_INV if possible?

ACCESS_REMOTE rkey's should not be left open across the FROM_DEVICE
DMA flush.

>  	/* assign function handlers */
> -	if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS &&
> -	    dev_attr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY &&
> -	    dev_attr->device_cap_flags & IB_DEVICE_SIGNATURE_HANDOVER) {
> -		device->use_fastreg = 1;
> -		device->reg_rdma_mem = isert_reg_frmr_pi;
> -		device->unreg_rdma_mem = isert_unreg_frmr_pi;
> +	cap_flags = dev_attr->device_cap_flags;
> +	if (cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS &&
> +	    cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
> +		if (cap_flags & IB_DEVICE_SIGNATURE_HANDOVER) {
> +			device->use_fastreg = 1;
> +			device->reg_rdma_mem = isert_reg_frmr_pi;
> +			device->unreg_rdma_mem = isert_unreg_frmr_pi;
> +		} else {
> +			device->use_fastreg = 1;
> +			device->reg_rdma_mem = isert_reg_frmr;
> +			device->unreg_rdma_mem = isert_unreg_frmr;
> +		}

The use of FRWR for RDMA READ should be iWarp specific, IB shouldn't
pay that overhead. I am expecting to see a cap_rdma_read_rkey or
something in here ?

Jason
