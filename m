Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:47164 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756159AbbGVN6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 09:58:01 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Tom Talpey'" <tom@talpey.com>, "'Chuck Lever'" <chuck.lever@oracle.com>,
        <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com> <015101d0c331$69e31d10$3da95730$@opengridcomputing.com> <55AD7065.8040809@talpey.com> <015701d0c33d$36b53110$a41f9330$@opengridcomputing.com> <20150720224244.GB12278@obsidianresearch.com> <55AECA92.3040105@opengridcomputing.com> <20150721225433.GA25724@obsidianresearch.com>
In-Reply-To: <20150721225433.GA25724@obsidianresearch.com>
Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Date: Wed, 22 Jul 2015 08:58:04 -0500
Message-ID: <000001d0c486$6e2c8ea0$4a85abe0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jason Gunthorpe
> Sent: Tuesday, July 21, 2015 5:55 PM
> To: Steve Wise
> Cc: 'Tom Talpey'; 'Chuck Lever'; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
> 
> On Tue, Jul 21, 2015 at 05:41:22PM -0500, Steve Wise wrote:
> > On 7/20/2015 5:42 PM, Jason Gunthorpe wrote:
> > >On Mon, Jul 20, 2015 at 05:41:27PM -0500, Steve Wise wrote:
> > >>>B) why bother to check? Are machines with <4GB interesting, and worth
> > >>>supporting a special optimization?
> > >>No, but cxgb3 is still interesting to user applications, and perhaps NFSRDMA using FRMRs.
> > >Doesn't look like the NFS client will work. It requires an all
> > >physical memory lkey for SEND and RECV buffers..
> > >
> > >Jason
> >
> > Looks like cxgb3 supports LOCAL_DMA_LKEY and MEM_MGT_EXTENSIONS so dma mrs
> > aren't required for NFSRDMA:
> >
> > t4:~/linux-2.6/drivers/infiniband/hw/cxgb3 # grep IB_DEVICE_ iwch_provider.c
> >         strlcpy(dev->ibdev.name, "cxgb3_%d", IB_DEVICE_NAME_MAX);
> >         dev->device_cap_flags = IB_DEVICE_LOCAL_DMA_LKEY |
> >                                 IB_DEVICE_MEM_WINDOW |
> >                                 IB_DEVICE_MEM_MGT_EXTENSIONS;
> 
> Neat. Is the dma_mask set properly (I don't see any set at all)?
> 

iw_cxgb3 isn't a PCI driver.  It sits on top of cxgb3 which is the pci device driver and calls pci_set_dma_mask().

> > So cxgb3 can still support NFSRDMA and user verbs w/o get_dma_mr(). I'll
> > submit a patch soon to only support get_dma_mr() if unsigned long is 4
> > bytes...
> 
> So, NFS and RDS seem to be the only iWarp compatible ULPs?
> 
> NFS has worked, and will continue to work with the global lkey.
> 
> RDS looks like it relies on an insecure all physical rkey, so it won't
> work until that is fixed.
> 
> So, I'd just use sizeof(physaddr_t) > 4 as the test. The only people
> that could be impacted are RDS users using distro kernels on machines
> with less than 4G of ram. I somehow doubt there are any of those...
> 
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

