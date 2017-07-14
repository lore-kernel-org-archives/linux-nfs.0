Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47379 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdGNHeG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 03:34:06 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v6E7Y57D012484
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 07:34:05 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v6E7Y5ii027057
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 07:34:05 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v6E7Y4Qj017418
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 07:34:05 GMT
Date: Fri, 14 Jul 2017 10:33:57 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] svcrdma: Add recvfrom helpers to svc_rdma_rw.c
Message-ID: <20170714073357.zxzcej2qiwq3qu4j@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck Lever,

The patch 026d958b38c6: "svcrdma: Add recvfrom helpers to
svc_rdma_rw.c" from Jun 23, 2017, leads to the following static
checker warning:

	net/sunrpc/xprtrdma/svc_rdma_rw.c:689 svc_rdma_build_read_chunk()
	error: uninitialized symbol 'ret'.

net/sunrpc/xprtrdma/svc_rdma_rw.c
   663  static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
   664                                       struct svc_rdma_read_info *info,
   665                                       __be32 *p)
   666  {
   667          int ret;
   668  
   669          info->ri_chunklen = 0;
   670          while (*p++ != xdr_zero) {
                       ^^^^^^^^^^^^^^^^
Is this necessarily true for the first iteration through the loop?

   671                  u32 rs_handle, rs_length;
   672                  u64 rs_offset;
   673  
   674                  if (be32_to_cpup(p++) != info->ri_position)
   675                          break;
                                ^^^^^
It feels like this should be -EINVAL.

   676                  rs_handle = be32_to_cpup(p++);
   677                  rs_length = be32_to_cpup(p++);
   678                  p = xdr_decode_hyper(p, &rs_offset);
   679  
   680                  ret = svc_rdma_build_read_segment(info, rqstp,
   681                                                    rs_handle, rs_length,
   682                                                    rs_offset);
   683                  if (ret < 0)
   684                          break;
   685  
   686                  info->ri_chunklen += rs_length;
   687          }
   688  
   689          return ret;
   690  }

regards,
dan carpenter
