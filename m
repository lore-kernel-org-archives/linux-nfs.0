Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20542 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaGPR5l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 13:57:41 -0400
References: <59034BAD-306F-462F-A274-3EB06C0CBE47@oracle.com> <53C69EC3.1010208@oracle.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <53C69EC3.1010208@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <EB581A8B-097E-4C0F-97B3-D04B2B791A69@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 00/21] NFS/RDMA client patches for 3.17
Date: Wed, 16 Jul 2014 13:57:34 -0400
To: Shirley Ma <shirley.ma@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 16, 2014, at 11:48 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
> 
> These two patches have been significant reduced interrupt rate by around 4 times.
> 
>     xprtrdma: Disable completions for FAST_REG_MR Work Requests
>     xprtrdma: Disable completions for LOCAL_INV Work Requests 

Thanks Shirley!  This is result applies only to FRMR, correct? Also, i'd imagine the savings would be even greater for adapters that have short page list depth?


> 
> Same NFS read/write workload, here are interrupts rate irq/per sec report based upon /proc/interrupts:
> 
> w/o patches:
> -----------
> PCI-MSI-edge mlx4-ib (204):  105176
> PCI-MSI-edge mlx4-ib (204):  123650
> PCI-MSI-edge mlx4-ib (204):  123690
> PCI-MSI-edge mlx4-ib (204):  116554
> PCI-MSI-edge mlx4-ib (204):  122864
> 
> And perf stat irq report: 
> Performance counter stats for 'system wide':
> 
>         2,131,870      irq:irq_handler_entry                                        [100.00%]
>         2,131,870      irq:irq_handler_exit                                         [100.00%]
>           635,587      irq:softirq_entry                                            [100.00%]
>           635,597      irq:softirq_exit                                             [100.00%]
>           636,155      irq:softirq_raise
> 
>      25.422821792 seconds time elapsed
> 
> w/i patches:
> -----------
> PCI-MSI-edge mlx4-ib (204):  31131
> PCI-MSI-edge mlx4-ib (204):  32958
> PCI-MSI-edge mlx4-ib (204):  31068
> PCI-MSI-edge mlx4-ib (204):  30236
> PCI-MSI-edge mlx4-ib (204):  33041
> 
> And perf stat irq report:
> 
> Performance counter stats for 'system wide':
> 
>           653,548      irq:irq_handler_entry                                        [100.00%]
>           653,548      irq:irq_handler_exit                                         [100.00%]
>           568,138      irq:softirq_entry                                            [100.00%]
>           568,148      irq:softirq_exit                                             [100.00%]
>           568,690      irq:softirq_raise                                           
> 
>      21.675597062 seconds time elapsed
> 
> Shirley
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
