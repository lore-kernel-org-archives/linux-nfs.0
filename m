Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:33195
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752379AbbIVVzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 17:55:49 -0400
From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Message-ID: <5601C65F.8060403@sandisk.com>
Date: Tue, 22 Sep 2015 14:21:35 -0700
MIME-Version: 1.0
In-Reply-To: <1442482947-27785-2-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
> The new fast registration  verg ib_map_mr_sg receives a scatterlist

                              ^ verb ?

> +/**
> + * ib_map_mr_sg() - Map a memory region with the largest prefix of
> + *     a dma mapped SG list

This description could be made more clear. How about the following:

Register the largest possible prefix of a DMA-mapped SG-list

> +			} else if (last_page_off + dma_len < mr->page_size) {
> +				/* chunk this fragment with the last */
> +				last_end_dma_addr += dma_len;
> +				last_page_off += dma_len;
> +				mr->length += dma_len;
> +				continue;

Shouldn't this code update last_page_addr ?

