Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0079.outbound.protection.outlook.com ([65.55.169.79]:8669
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752976AbbJASKP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 14:10:15 -0400
Subject: Re: [PATCH v2 16/26] IB/srp: Convert to new registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-17-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <560D7702.1050806@sandisk.com>
Date: Thu, 1 Oct 2015 11:10:10 -0700
MIME-Version: 1.0
In-Reply-To: <1443116118-10730-17-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/24/2015 10:35 AM, Sagi Grimberg wrote:
> +	if (dev->use_fast_reg) {
> +		state.sg = idb_sg;
> +		state.sg_nents = 1;
> +		sg_set_buf(idb_sg, req->indirect_desc, idb_len);
> +		idb_sg->dma_address = req->indirect_dma_addr; /* hack! */
> +		ret = srp_map_finish_fr(&state, ch);
> +		if (ret < 0)
> +			return ret;
> +	} else if (dev->use_fmr) {

Hello Sagi,

Had you considered to use sg_init_one() instead of using sg_set_buf() 
and setting sg_nents to one ? The former function sets the end marker in 
the idb_sg scatterlist and also sets sg_magic if CONFIG_DEBUG_SG has 
been enabled.

Thanks,

Bart.
