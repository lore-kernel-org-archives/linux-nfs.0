Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F1D9C43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 16:07:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6332120684
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 16:07:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BfzVNvPY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727424AbfCEQHo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 11:07:44 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:52834 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727186AbfCEQHo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2019 11:07:44 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x25G46sM130861;
        Tue, 5 Mar 2019 16:07:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=hRN3HC7gzB91EeDVJC6NcsQSXIFOpDr2zTM/GG1eVbw=;
 b=BfzVNvPYtHZEKbMoKwLoE2t2tWq8K2iv/sn6aOskBf3vvOB+PLY7UNim6jL1gd05dY50
 08Vu+boWk0hnpaQRehMHxDxBU6hRCgpv74Ro6xyDoukoBiBhJS3e11GodCHGEXSr6nkX
 pKvg0KB8T+Nr8osDURMmWq5e8k6tsglCE9uU/m0qqfzZm0FdMUKAjZLKooyVv5ZTMua4
 +NLYTIcsOuIVA5g0tomD+ZrzNhghPeYBPtZJgiPo03xqAG/Fn5LwQolq614gUAEyizaw
 UbWPV6iN9KJF//3N+EFRNt///qzKqW/pIvuiNri8k/b0fiCHSiMPSr+qKp3+9lTWEGXq rQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2qyjfre75s-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 05 Mar 2019 16:07:42 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x25G7ffX018690
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 5 Mar 2019 16:07:41 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x25G7fvU027685;
        Tue, 5 Mar 2019 16:07:41 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 05 Mar 2019 08:07:40 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 3/3] SUNRPC: Micro-optimisation to avoid
 call_bind+call_commit
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190305151722.45732-3-trond.myklebust@hammerspace.com>
Date:   Tue, 5 Mar 2019 11:07:39 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <1DAB8293-359F-4409-81CD-E3F1A7ECDB93@oracle.com>
References: <20190305151722.45732-1-trond.myklebust@hammerspace.com>
 <20190305151722.45732-2-trond.myklebust@hammerspace.com>
 <20190305151722.45732-3-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9185 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903050105
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 5, 2019, at 10:17 AM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> Most tasks should not have to deal with disconnected or unbound
> socket states, so let's move them out of the common state machine
> path.

Seems like a sensible idea. Were you able to measure any latency
improvement?


> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index c154684a35d4..b9251fd696ee 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1806,7 +1806,7 @@ call_encode(struct rpc_task *task)
> 		xprt_request_enqueue_receive(task);
> 	xprt_request_enqueue_transmit(task);
> out:
> -	task->tk_action = call_bind;
> +	task->tk_action = call_transmit;
> }
> 
> /*
> -- 
> 2.20.1
> 

--
Chuck Lever



