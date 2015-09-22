Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0053.outbound.protection.outlook.com ([157.56.112.53]:42240
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932186AbbIVHcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 03:32:36 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "Sagi Grimberg" <sagig@dev.mellanox.co.il>,
        <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <55FDEDD5.1090105@oracle.com> <55FE7E24.20300@dev.mellanox.co.il>
 <5600928A.7070202@oracle.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@mellanox.com>
Message-ID: <560100EA.8080302@mellanox.com>
Date: Tue, 22 Sep 2015 10:19:06 +0300
MIME-Version: 1.0
In-Reply-To: <5600928A.7070202@oracle.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
> As mentioned earlier, I have a WIP RDS fastreg branch [3]
> which is functional (at least I can RDMA messages across
> nodes ;-)).

Nice!

> So merging [2] and [3], I created [4] and applied
> a delta change based on your other patches. I saw ib_post_send
> failure with my HCA driver returning '-EINVAL'. I didn't
> debug it further but at least opcode and num_sge were set
> correctly so I shouldn't have seen it. So I did memset()
> on reg_wr which seems to have helped to fix the ib_post_send()
> failure.

Yep - that was my fault. When converting the ULPs I optimized by 
removing the memset but I forgot to set reg_wr.wr.next = NULL when
the ULP needed. This caused the driver to read a second bogus work 
request. Steve just reported this as well so I'll fix that in v2.

>
> But I got into remote access errors which tells me that I
> have messed up setup(rkey, sge setup or access flags)

One thing that pops is that in the old API the MR was registered
with iova_start = 0 (which is probably what was sent to the peer),
but the new API the iova is implicitly sg_dma_address(&sg[0]).

The registered MR holds these attributes in:
mr->rkey
mr->iova
mr->length

These should be passed to a peer to perform rdma.

Hope this helps,
Sagi.
