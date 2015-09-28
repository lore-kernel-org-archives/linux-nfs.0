Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50495 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbbI1TcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 15:32:21 -0400
Subject: Re: [PATCH v2 00/26] New fast registration API
To: Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <560995C6.3040909@opengridcomputing.com>
Date: Mon, 28 Sep 2015 14:32:22 -0500
MIME-Version: 1.0
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/24/2015 12:34 PM, Sagi Grimberg wrote:
> I don't have access to other HW devices (qib, nes) nor iwarp devices so RDS is
> compile tested only. Santosh reports
>
> I'm targeting this to 4.4 so I'll appreciate more feedback and a bigger testing
> coverage.
>
> The code is available at: https://github.com/sagigrimberg/linux/tree/reg_api.4

With these NFSRDMA fixes applied on top of reg_api.4:

https://patchwork.kernel.org/patch/7233211/
https://patchwork.kernel.org/patch/7233231/
https://patchwork.kernel.org/patch/7233251/

I tested NFSRDMA client and server over iw_cxgb4 with NFSv3 and NFSv4.

Looks good.

Tested-by: Steve Wise <swise@opengridcomputing.com>

