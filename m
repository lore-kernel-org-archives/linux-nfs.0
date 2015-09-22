Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2on0056.outbound.protection.outlook.com ([207.46.100.56]:36581
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934121AbbIVVmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 17:42:35 -0400
Subject: Re: [PATCH v1 03/24] IB/mlx5: Support the new memory registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-4-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5601C7A4.5030302@sandisk.com>
Date: Tue, 22 Sep 2015 14:27:00 -0700
MIME-Version: 1.0
In-Reply-To: <1442482947-27785-4-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
> +static int
> +mlx5_alloc_priv_descs(struct ib_device *device,
> +		      struct mlx5_ib_mr *mr,
> +		      int ndescs,
> +		      int desc_size)
> +{
> +	int size = ndescs * desc_size;
> +
> +	mr->descs = dma_alloc_coherent(device->dma_device, size,
> +				       &mr->desc_map, GFP_KERNEL);
> +	if (!mr->descs)
> +		return -ENOMEM;
> +
> +	return 0;
> +}

Would it be possible to clarify the choice for coherent memory ? Would 
performance be better if non-coherent memory would be used and if 
memory would be synced after initialization of desc_map has finished ?

Bart.
