Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41960 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506AbbIXRnQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 13:43:16 -0400
Subject: Re: [PATCH v2 14/26] RDS/IW: Convert to new memory registration API
To: Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-15-git-send-email-sagig@mellanox.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Message-ID: <5604362F.6020009@oracle.com>
Date: Thu, 24 Sep 2015 10:43:11 -0700
MIME-Version: 1.0
In-Reply-To: <1443116118-10730-15-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/24/15 10:35 AM, Sagi Grimberg wrote:
> Get rid of fast_reg page list and its construction.
> Instead, just pass the RDS sg list to ib_map_mr_sg
> and post the new ib_reg_wr.
>
> This is done both for server IW RDMA_READ registration
> and the client remote key registration.
>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> Acked-by: Christoph Hellwig <hch@lst.de>
> ---
>   net/rds/iw.h      |   5 +--
>   net/rds/iw_rdma.c | 128 +++++++++++++++++++-----------------------------------
>   net/rds/iw_send.c |  57 ++++++++++++------------
>   3 files changed, 75 insertions(+), 115 deletions(-)
>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
