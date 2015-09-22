Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0066.outbound.protection.outlook.com ([65.55.169.66]:33504
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753382AbbIVV5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 17:57:48 -0400
Subject: Re: [PATCH v1 02/24] IB/mlx5: Remove dead fmr code
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-3-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5601C701.1040602@sandisk.com>
Date: Tue, 22 Sep 2015 14:24:17 -0700
MIME-Version: 1.0
In-Reply-To: <1442482947-27785-3-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
> Just function declarations - no need for those
> laying arround. If for some reason someone will want
> FMR support in mlx5, it should be easy enough to restore
> a few structs.
>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>

Reviewed-by: Bart Van Assche <bart.vanassche@sandisk.com>
