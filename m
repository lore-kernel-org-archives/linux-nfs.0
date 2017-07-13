Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30767 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdGMOFX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jul 2017 10:05:23 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v6DE5LJR028607
        (version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:05:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.13.8/8.14.4) with ESMTP id v6DE5KXR018278
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:05:21 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v6DE5Kn3003494
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:05:20 GMT
Date: Thu, 13 Jul 2017 17:05:14 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] svcrdma: Avoid Send Queue overflow
Message-ID: <20170713140514.rejoe4wpaeheumqr@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck Lever,

The patch 107c1d0a991a: "svcrdma: Avoid Send Queue overflow" from Jun
23, 2017, leads to the following static checker warning:

	net/sunrpc/xprtrdma/svc_rdma_sendto.c:687 svc_rdma_sendto()
	warn: was && intended here instead of ||?

net/sunrpc/xprtrdma/svc_rdma_sendto.c
   682          if (ret < 0)
   683                  goto err0;
   684          return 0;
   685  
   686   err2:
   687          if (ret != -E2BIG || ret != -EINVAL)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Yeah...  This should be &&.  But honestly, I'd be so nervous about
assigning such a specific meaning to -EINVAL.  I saw that it's
documented but I feel like people are always randomly adding -EINVAL
returns without reading the documentation.  I could see myself making
that mistake.

   688                  goto err1;
   689  
   690          ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
   691          if (ret)
   692                  goto err1;
   693          ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
   694          if (ret < 0)
   695                  goto err0;
   696          return 0;
   697  
   698   err1:
   699          put_page(res_page);
   700   err0:
   701          pr_err("svcrdma: Could not send reply, err=%d. Closing transport.\n",
   702                 ret);
   703          set_bit(XPT_CLOSE, &xprt->xpt_flags);
   704          return -ENOTCONN;
   705  }

regards,
dan carpenter
