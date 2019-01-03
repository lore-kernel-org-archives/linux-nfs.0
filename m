Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74955C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 15:29:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3BFB7208E3
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 15:29:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="48i9jub0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730904AbfACP3i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 10:29:38 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:37858 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730901AbfACP3i (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 10:29:38 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03FSwoh124627;
        Thu, 3 Jan 2019 15:29:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=tu9iQ2ssqyI2eyLSTmWUg/cTEF6k73ErbsEzaQXsO10=;
 b=48i9jub0XrHbn3EfEc132E8I46YnYhYgwnC8/MBmr5ve/4K/Ksb5GLcdyEnXeG/WXx0n
 UlN+3Q5er8QWITqNmaWs32pQgAbcXbR4njKj9cJQXoyS/HkQ84ThdoaiaztilXdiJDaX
 dpcG4VQ9YR2EJPWT2fNim8iJYSMG4rLyRjGE+OJwDhZZ1EPq29yOoNfTiXSVP6VQR3zU
 8u5vc/X6GPshIyvhw7zjkDADLdUCWiNKFgANmJJjgo9QDwvC1CDDsHlAQanqsw7Z89me
 H7SlecbMf60kvVbYx+spYdzifHFZw5TEcwdBOx6hBG76FOajWs/w6VGxqWavQjo5+l/o HA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2pp0btypx5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 15:29:35 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x03FTYUD030626
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 15:29:35 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x03FTY67016384;
        Thu, 3 Jan 2019 15:29:34 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 07:29:34 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190102225313.2097-2-trond.myklebust@hammerspace.com>
Date:   Thu, 3 Jan 2019 10:29:33 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=813
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030137
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond-

I was curious about this one because yesterday I saw evidence (for
other reasons) that rq_bytes_sent wasn't always zeroed when it should
be.


> On Jan 2, 2019, at 5:53 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> When we resend a request, ensure that the 'rq_bytes_sent' is reset
> to zero.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 1 -
> net/sunrpc/xprt.c | 1 +
> 2 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 24cbddc44c88..2189fbc4c570 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
> 	xdr_buf_init(&req->rq_rcv_buf,
> 		     req->rq_rbuffer,
> 		     req->rq_rcvsize);
> -	req->rq_bytes_sent = 0;

I agree this line is not sufficient, and it should be moved.
Not every retransmission requires a re-encode. However, the
patch description should explain that, and it probably needs
a Fixes: tag.

Can you now also remove the same line from xprt_request_init
and xprt_init_bc_request ?

Also, I notice that UDP does not touch rq_bytes_sent. Since
RDMA also does not use rq_bytes_sent, maybe the same line
can be removed from xprtrdma/transport.c and
xprtrdma/backchannel.c ?


> 	p = rpc_encode_header(task);
> 	if (p == NULL) {
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 73547d17d3c6..9075ae150ae5 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
> 	struct rpc_xprt *xprt = req->rq_xprt;
> 
> 	if (xprt_request_need_enqueue_transmit(task, req)) {
> +		req->rq_bytes_sent = 0;
> 		spin_lock(&xprt->queue_lock);
> 		/*
> 		 * Requests that carry congestion control credits are added

So I'm not convinced this covers every case. I need some
time to investigate.


--
Chuck Lever



