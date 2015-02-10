Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:21708 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbbBJJor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 04:44:47 -0500
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t1A9ikLk016244
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 09:44:47 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by ucsinet22.oracle.com (8.14.5+Sun/8.14.5) with ESMTP id t1A9ijaO021519
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 09:44:46 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t1A9ijpO027194
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 09:44:45 GMT
Date: Tue, 10 Feb 2015 12:45:43 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: re: xprtrdma: Move credit update to RPC reply handler
Message-ID: <20150210094543.GA16665@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck Lever,

The patch eba8ff660b2d: "xprtrdma: Move credit update to RPC reply
handler" from Jan 21, 2015, leads to the following static checker
warning:

	net/sunrpc/xprtrdma/rpc_rdma.c:879 rpcrdma_reply_handler()
	warn: can 'credits' be negative?

net/sunrpc/xprtrdma/rpc_rdma.c
   875  
   876          credits = be32_to_cpu(headerp->rm_credit);
   877          if (credits == 0)
   878                  credits = 1;    /* don't deadlock */
   879          else if (credits > r_xprt->rx_buf.rb_max_requests)
   880                  credits = r_xprt->rx_buf.rb_max_requests;


"credits" and "r_xprt->rx_buf.rb_max_requests" are both type int so this
test can underflow.  If "credits" is less than zero then "xprt->cwnd"
could be zero, leading to a deadlock (based on the comment), or
something else out of bounds.

   881  
   882          cwnd = xprt->cwnd;
   883          xprt->cwnd = credits << RPC_CWNDSHIFT;
   884          if (xprt->cwnd > cwnd)
   885                  xprt_release_rqst_cong(rqst->rq_task);
   886  
   887          dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
   888                          __func__, xprt, rqst, status);
   889          xprt_complete_rqst(rqst->rq_task, status);
   890          spin_unlock(&xprt->transport_lock);
   891  }

regards,
dan carpenter
