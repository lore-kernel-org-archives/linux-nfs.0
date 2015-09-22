Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0076.outbound.protection.outlook.com ([157.56.112.76]:61024
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757478AbbIVHzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 03:55:37 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "Sagi Grimberg" <sagig@dev.mellanox.co.il>,
        <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <55FDEDD5.1090105@oracle.com> <55FE7E24.20300@dev.mellanox.co.il>
 <5600928A.7070202@oracle.com> <560100EA.8080302@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@mellanox.com>
Message-ID: <560109B7.8070005@mellanox.com>
Date: Tue, 22 Sep 2015 10:56:39 +0300
MIME-Version: 1.0
In-Reply-To: <560100EA.8080302@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/22/2015 10:19 AM, Sagi Grimberg wrote:
>>
>> As mentioned earlier, I have a WIP RDS fastreg branch [3]
>> which is functional (at least I can RDMA messages across
>> nodes ;-)).
>
> Nice!
>
>> So merging [2] and [3], I created [4] and applied
>> a delta change based on your other patches. I saw ib_post_send
>> failure with my HCA driver returning '-EINVAL'. I didn't
>> debug it further but at least opcode and num_sge were set
>> correctly so I shouldn't have seen it. So I did memset()
>> on reg_wr which seems to have helped to fix the ib_post_send()
>> failure.
>
> Yep - that was my fault. When converting the ULPs I optimized by
> removing the memset but I forgot to set reg_wr.wr.next = NULL when
> the ULP needed. This caused the driver to read a second bogus work
> request. Steve just reported this as well so I'll fix that in v2.
>
>>
>> But I got into remote access errors which tells me that I
>> have messed up setup(rkey, sge setup or access flags)
>
> One thing that pops is that in the old API the MR was registered
> with iova_start = 0 (which is probably what was sent to the peer),
> but the new API the iova is implicitly sg_dma_address(&sg[0]).
>
> The registered MR holds these attributes in:
> mr->rkey
> mr->iova
> mr->length
>
> These should be passed to a peer to perform rdma.
>
> Hope this helps,
> Sagi.

ohh, I just read the RDS 3.1 specification (for the first time..) and I
noticed that RDS 3.1 header extension contains only a 32bit offset
parameter. Why is that anyway? why not 64bit so it can be a valid mapped
address? Also the code doesn't use it at all and always passes 0 (which
is buggy if sg[0] has an offset from a page).

This won't work with the proposed API as the iova is 64bit (as all other
existing RDMA protocols use 64bit addresses).

In any event, I'd much rather to add ib_map_mr_sg_zbva() just for RDS
to use instead of polluting the API with an iova argument, but I think
that the RDS spec can be updated to use 64bit offsets and align to all
other RDMA protocols (it has enough space in h_exthdr which is 128bit).

I was thinking of:
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index e7e0251..61fcab4 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -3033,6 +3033,21 @@ int ib_map_mr_sg(struct ib_mr *mr,
                  unsigned int sg_nents,
                  unsigned int page_size);

+static inline int
+ib_map_mr_sg_zbva(struct ib_mr *mr,
+                 struct scatterlist *sg,
+                 unsigned int sg_nents,
+                 unsigned int page_size)
+{
+       int rc;
+
+       rc = ib_map_mr_sg(mr, sg, sg_nents, page_size);
+       if (likely(!rc))
+               mr->iova &= ((u64)page_size - 1);
+
+       return rc;
+}
+
  int ib_sg_to_pages(struct ib_mr *mr,
                    struct scatterlist *sgl,
                    unsigned int sg_nents,
--

Thoughts?

Santosh, can you use that one instead and let us know if
it resolves your issue?

I think you should make sure to correctly construct the
h_exthdr with: rds_rdma_make_cookie(mr->rkey, (32)mr->iova)
