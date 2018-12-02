Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD342C04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 17:07:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 681F52082F
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 17:07:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PrrfrLQr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 681F52082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725440AbeLBRHO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 12:07:14 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:58712 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725379AbeLBRHO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 12:07:14 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB2H4C9r089795;
        Sun, 2 Dec 2018 17:07:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=4ON1+jjvOywgOn1Pa9ew95hS6rUa2hStyjzwGgymJw0=;
 b=PrrfrLQrB0FyaHpB7AfcLv8Wk7wGw84e9p48QeL0NsgYBCfKSYLReHmMs0J11IDtnMw7
 mCcjGSVzOa/MWajg7hGgbAkyzgzlozSu5/2buvBPwRSJ0oQdBxmfEdCH7O0Ph11zAWLR
 fWTD2sbTcTNO4kmlcV/ezeLqyk33Y2rsJ7TG3AFPrEfs8LXCB/rhMDnj9FKDKI+eL9E4
 2Cepwvt/B8RDincpR8HHGDiSDaPkoawBJc7dF6jQIyPfUSba3Kyga8cWlIy2qFcPgt+S
 l6IqfjiFu2qvkhcmksvpGAF8mu+g7ZGUZbW8m1R/0oi2XfnrVZ3bvW7sZNoDJXqmW+RP qA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2p3jxr2yhm-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 02 Dec 2018 17:07:09 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB2H78jv022324
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 2 Dec 2018 17:07:08 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wB2H78K0030248;
        Sun, 2 Dec 2018 17:07:08 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 02 Dec 2018 09:07:08 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
Date:   Sun, 2 Dec 2018 12:07:06 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
References: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9095 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812020164
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Test report.

I applied this on top of the three v4 patches from Friday.

With TCP, I no longer see the soft IRQ warnings or bdev leaks.
However, at some point during my test (sec=krb5p,vers=3) the
mount stops responding and the client becomes idle. ^C leaves
the iozone processes in D state.


With RDMA, I can see a few issues:
 - A lot of -74 and server disconnects. I suspect this is due
   to GSS sequence window overruns
 - xprt_connect puts the calling task to sleep if the credit
   limit has been reached, and that can result in a deadlock
 - The reconnect logic appears to busy-wait until something
   else (eg, an RTO) forces a reconnect
 - A connect or disconnect wake-up that occurs while an RPC
   reply is being handled (ie, is still on xprt->pending)
   results in that RPC being retried unnecessarily.

I'm not sure how to address that last one. Sometimes RDMA has
to invalidate MRs, and that involves a wait/context swith which
opens the race window significantly.


> On Dec 2, 2018, at 9:42 AM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> If an asynchronous connection attempt completes while another task is
> in xprt_connect(), then the call to rpc_sleep_on() could end up
> racing with the call to xprt_wake_pending_tasks().
> So add a second test of the connection state after we've put the
> task to sleep and set the XPRT_CONNECTING flag, when we know that there
> can be no asynchronous connection attempts still in progress.
> 
> Fixes: 0b9e79431377d ("SUNRPC: Move the test for XPRT_CONNECTING into...")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/xprt.c | 11 +++++++++--
> 1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 122c91c28e7c..ce927002862a 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -826,8 +826,15 @@ void xprt_connect(struct rpc_task *task)
> 			return;
> 		if (xprt_test_and_set_connecting(xprt))
> 			return;
> -		xprt->stat.connect_start = jiffies;
> -		xprt->ops->connect(xprt, task);
> +		/* Race breaker */
> +		if (!xprt_connected(xprt)) {
> +			xprt->stat.connect_start = jiffies;
> +			xprt->ops->connect(xprt, task);
> +		} else {
> +			xprt_clear_connecting(xprt);
> +			task->tk_status = 0;
> +			rpc_wake_up_queued_task(&xprt->pending, task);
> +		}
> 	}
> 	xprt_release_write(xprt, task);
> }
> -- 
> 2.19.2
> 

--
Chuck Lever



