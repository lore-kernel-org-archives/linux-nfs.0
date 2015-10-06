Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35406 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbbJFIhq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 04:37:46 -0400
Received: by wicge5 with SMTP id ge5so155659340wic.0
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 01:37:45 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com> <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com> <560C42CE.6090000@sandisk.com>
 <560CDDBC.8000400@dev.mellanox.co.il> <560D730C.9000302@sandisk.com>
 <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com>
Cc: Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56138854.4040209@dev.mellanox.co.il>
Date: Tue, 6 Oct 2015 11:37:40 +0300
MIME-Version: 1.0
In-Reply-To: <560EA4A1.3080709@sandisk.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/2/2015 6:37 PM, Bart Van Assche wrote:
> On 10/01/2015 11:14 PM, Sagi Grimberg wrote:
>> Would you mind sending me your .config?
>
> Hello Sagi,

Hi Bart,

>
> I just sent this .config file to you off-list.

I see now the error you are referring to.

The issue is that the device requires the MR page array to have
an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
page array allocation to be non-coherent I didn't take care of
alignment.

Taking care of this alignment may result in a higher order allocation
as we'd need to add (alignment - 1) to the allocation size.

e.g. a 512 pages on mlx4 will become:
512 * 8 + 0x40 - 1 = 4159

I'm leaning towards this approach. Any preference?

I think this patch should take care of mlx4:
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h 
b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index de6eab3..4c69247 100644 

--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -129,6 +129,8 @@ struct mlx4_ib_cq {
         struct list_head                recv_qp_list;
  };

+#define MLX4_MR_PAGES_ALIGN 0x40
+
  struct mlx4_ib_mr {
         struct ib_mr            ibmr;
         __be64                  *pages;
@@ -137,6 +139,7 @@ struct mlx4_ib_mr {
         u32                     max_pages;
         struct mlx4_mr          mmr;
         struct ib_umem         *umem;
+       void                    *pages_alloc;
  };

  struct mlx4_ib_mw {
diff --git a/drivers/infiniband/hw/mlx4/mr.c 
b/drivers/infiniband/hw/mlx4/mr.c
index fa01f75..d3f8175 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -279,10 +279,14 @@ mlx4_alloc_priv_pages(struct ib_device *device,
         int size = max_pages * sizeof(u64);
         int ret;

-       mr->pages = kzalloc(size, GFP_KERNEL);
-       if (!mr->pages)
+       size += max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
+
+       mr->pages_alloc = kzalloc(size, GFP_KERNEL);
+       if (!mr->pages_alloc)
                 return -ENOMEM;

+       mr->pages = PTR_ALIGN(mr->pages_alloc, MLX4_MR_PAGES_ALIGN);
+
         mr->page_map = dma_map_single(device->dma_device, mr->pages,
                                       size, DMA_TO_DEVICE);

@@ -293,20 +297,22 @@ mlx4_alloc_priv_pages(struct ib_device *device,

         return 0;
  err:
-       kfree(mr->pages);
+       kfree(mr->pages_alloc);
         return ret;
  }

  static void
  mlx4_free_priv_pages(struct mlx4_ib_mr *mr)
  {
-       struct ib_device *device = mr->ibmr.device;
-       int size = mr->max_pages * sizeof(u64);
-
         if (mr->pages) {
+               struct ib_device *device = mr->ibmr.device;
+               int size = mr->max_pages * sizeof(u64);
+
+               size += max_t(int, MLX4_MR_PAGES_ALIGN - 
ARCH_KMALLOC_MINALIGN, 0);
+
                 dma_unmap_single(device->dma_device, mr->page_map,
                                  size, DMA_TO_DEVICE);
-               kfree(mr->pages);
+               kfree(mr->pages_alloc);
                 mr->pages = NULL;
         }
  }
--

Sagi.
