Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:42924 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbBJQuF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 11:50:05 -0500
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t1AGo4SV011256
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 16:50:05 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t1AGo4MY026396
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 16:50:04 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t1AGo4aJ021919
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 16:50:04 GMT
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: xprtrdma: Move credit update to RPC reply handler
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150210094543.GA16665@mwanda>
Date: Tue, 10 Feb 2015 11:50:02 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8F7A1FF4-D9AD-4042-BC10-6755666A6A15@oracle.com>
References: <20150210094543.GA16665@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 10, 2015, at 4:45 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:

> Hello Chuck Lever,
> 
> The patch eba8ff660b2d: "xprtrdma: Move credit update to RPC reply
> handler" from Jan 21, 2015, leads to the following static checker
> warning:
> 
> 	net/sunrpc/xprtrdma/rpc_rdma.c:879 rpcrdma_reply_handler()
> 	warn: can 'credits' be negative?

“credits” cannot be negative unless there’s a bug.

I can send an additional patch once this is committed (so the correct
commit ID is available for the Fixes: tag).


> net/sunrpc/xprtrdma/rpc_rdma.c
>   875  
>   876          credits = be32_to_cpu(headerp->rm_credit);
>   877          if (credits == 0)
>   878                  credits = 1;    /* don't deadlock */
>   879          else if (credits > r_xprt->rx_buf.rb_max_requests)
>   880                  credits = r_xprt->rx_buf.rb_max_requests;
> 
> 
> "credits" and "r_xprt->rx_buf.rb_max_requests" are both type int so this
> test can underflow.  If "credits" is less than zero then "xprt->cwnd"
> could be zero, leading to a deadlock (based on the comment), or
> something else out of bounds.
> 
>   881  
>   882          cwnd = xprt->cwnd;
>   883          xprt->cwnd = credits << RPC_CWNDSHIFT;
>   884          if (xprt->cwnd > cwnd)
>   885                  xprt_release_rqst_cong(rqst->rq_task);
>   886  
>   887          dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
>   888                          __func__, xprt, rqst, status);
>   889          xprt_complete_rqst(rqst->rq_task, status);
>   890          spin_unlock(&xprt->transport_lock);
>   891  }
> 
> regards,
> dan carpenter

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



