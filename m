Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:41774 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752133AbeENJM7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 05:12:59 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4E9B7jM173988
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 09:12:59 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2hx29w31rc-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 09:12:59 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4E9CwHK021338
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 09:12:58 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w4E9CwnX008245
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 09:12:58 GMT
Date: Mon, 14 May 2018 12:12:52 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] svcrdma: Allocate recv_ctxt's on CPU handling Receives
Message-ID: <20180514091251.GA25443@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck Lever,

The patch 0b2613c5883f: "svcrdma: Allocate recv_ctxt's on CPU
handling Receives" from May 7, 2018, leads to the following static
checker warning:

	net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:273 svc_rdma_post_recvs()
	warn: signedness bug returning '(-12)'

net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
   258  /**
   259   * svc_rdma_post_recvs - Post initial set of Recv WRs
   260   * @rdma: fresh svcxprt_rdma
   261   *
   262   * Returns true if successful, otherwise false.
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   263   */
   264  bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma)
   265  {
   266          struct svc_rdma_recv_ctxt *ctxt;
   267          unsigned int i;
   268          int ret;
   269  
   270          for (i = 0; i < rdma->sc_max_requests; i++) {
   271                  ctxt = svc_rdma_recv_ctxt_get(rdma);
   272                  if (!ctxt)
   273                          return -ENOMEM;
                                ^^^^^^^^^^^^^^^
   274                  ctxt->rc_temp = true;
   275                  ret = __svc_rdma_post_recv(rdma, ctxt);
   276                  if (ret) {
   277                          pr_err("svcrdma: failure posting recv buffers: %d\n",
   278                                 ret);
   279                          return false;
   280                  }
   281          }
   282          return true;
   283  }

regards,
dan carpenter
