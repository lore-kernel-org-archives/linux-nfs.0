Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43213 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdGMOpd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jul 2017 10:45:33 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v6DEjV4F028300
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:45:32 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v6DEjV8M014597
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:45:31 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v6DEjUbm027785
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jul 2017 14:45:31 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [bug report] svcrdma: Avoid Send Queue overflow
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170713140514.rejoe4wpaeheumqr@mwanda>
Date: Thu, 13 Jul 2017 10:45:30 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BAF535B6-3C3A-46FA-80B6-68A5730435DB@oracle.com>
References: <20170713140514.rejoe4wpaeheumqr@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 13, 2017, at 10:05 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> Hello Chuck Lever,
> 
> The patch 107c1d0a991a: "svcrdma: Avoid Send Queue overflow" from Jun
> 23, 2017, leads to the following static checker warning:
> 
> 	net/sunrpc/xprtrdma/svc_rdma_sendto.c:687 svc_rdma_sendto()
> 	warn: was && intended here instead of ||?
> 
> net/sunrpc/xprtrdma/svc_rdma_sendto.c
>   682          if (ret < 0)
>   683                  goto err0;
>   684          return 0;
>   685  
>   686   err2:
>   687          if (ret != -E2BIG || ret != -EINVAL)
>                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Yeah...  This should be &&.

OK.


> But honestly, I'd be so nervous about
> assigning such a specific meaning to -EINVAL.  I saw that it's
> documented but I feel like people are always randomly adding -EINVAL
> returns without reading the documentation.  I could see myself making
> that mistake.

EINVAL means "the caller provided bad arguments". The documenting
comment you refer to describes a specific case where the function
is catching a "bad argument value". I believe EINVAL is being used
correctly, not narrowly, here.

If you think of a better errno code to use, I'm open to changing
it.


>   688                  goto err1;
>   689  
>   690          ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
>   691          if (ret)
>   692                  goto err1;
>   693          ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
>   694          if (ret < 0)
>   695                  goto err0;
>   696          return 0;
>   697  
>   698   err1:
>   699          put_page(res_page);
>   700   err0:
>   701          pr_err("svcrdma: Could not send reply, err=%d. Closing transport.\n",
>   702                 ret);
>   703          set_bit(XPT_CLOSE, &xprt->xpt_flags);
>   704          return -ENOTCONN;
>   705  }
> 
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



