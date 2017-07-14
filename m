Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34443 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754031AbdGNPYY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 11:24:24 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v6EFOMPl022566
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 15:24:23 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v6EFOM8B019191
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 15:24:22 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v6EFOLOd019391
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 15:24:21 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [bug report] svcrdma: Add recvfrom helpers to svc_rdma_rw.c
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170714073357.zxzcej2qiwq3qu4j@mwanda>
Date: Fri, 14 Jul 2017 11:24:20 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <09A29CBF-98CB-46FB-8AB3-9C464955D7D6@oracle.com>
References: <20170714073357.zxzcej2qiwq3qu4j@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dan-


> On Jul 14, 2017, at 3:33 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> Hello Chuck Lever,
> 
> The patch 026d958b38c6: "svcrdma: Add recvfrom helpers to
> svc_rdma_rw.c" from Jun 23, 2017, leads to the following static
> checker warning:
> 
> 	net/sunrpc/xprtrdma/svc_rdma_rw.c:689 svc_rdma_build_read_chunk()
> 	error: uninitialized symbol 'ret'.

Interesting. I often build individual files with "make W=1"
as part of normal development. I have never seen this warning
in this function.


> net/sunrpc/xprtrdma/svc_rdma_rw.c
>   663  static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
>   664                                       struct svc_rdma_read_info *info,
>   665                                       __be32 *p)
>   666  {
>   667          int ret;
>   668  
>   669          info->ri_chunklen = 0;
>   670          while (*p++ != xdr_zero) {
>                       ^^^^^^^^^^^^^^^^
> Is this necessarily true for the first iteration through the loop?

Yes. This function is called only when there is a Read chunk
to process starting at @p. There will always be at least one
segment.

Constructing the loop this way eliminates some code duplication,
at the cost of confusing human readers and static checkers.


>   671                  u32 rs_handle, rs_length;
>   672                  u64 rs_offset;
>   673  
>   674                  if (be32_to_cpup(p++) != info->ri_position)
>   675                          break;
>                                ^^^^^
> It feels like this should be -EINVAL.

No. The loop terminates normally here if the Position value
changes. That signals the start of the next Read chunk. This
is not an error, but meeting the condition will be rather
rare.

In fact, xdr_check_read_list prevents there from ever being
a subsequent Read chunk, since this server can't handle more
than one, currently. I could safely remove this check for now.

But during the first loop iteration, this condition is never
met. The loop body will already have been executed at least
once, so "ret" is already set by svc_rdma_build_read_segment.


>   676                  rs_handle = be32_to_cpup(p++);
>   677                  rs_length = be32_to_cpup(p++);
>   678                  p = xdr_decode_hyper(p, &rs_offset);
>   679  
>   680                  ret = svc_rdma_build_read_segment(info, rqstp,
>   681                                                    rs_handle, rs_length,
>   682                                                    rs_offset);
>   683                  if (ret < 0)
>   684                          break;
>   685  
>   686                  info->ri_chunklen += rs_length;
>   687          }
>   688  
>   689          return ret;
>   690  }
> 
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



