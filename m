Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2317C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:23:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92B262080A
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:23:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vIHrRQnk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92B262080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725941AbeLAIdt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:33:49 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:57938 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAIdt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:33:49 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAULIvHN118327;
        Fri, 30 Nov 2018 21:23:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=KMUIBmSAnlACPDRiXAzViMjCiU4fwUQefP2sn57kEjo=;
 b=vIHrRQnkO73ASrlcWWb3CKUMA3zigWFoqCTtARngGCksZnfUT+qrEFKhENDgJXcEfQbJ
 ILUpvfLgJVkaRYtb9qFa0qgW7iaMqiFjXkRNrwoqkrj+Gez+c9uqhEohSacbktiTHgIi
 iUZy36vXrfTUAJXiJgHgJfzVlRhuHe+vvzy/qCNt3oUz1M+gXoOQdGGH27V0GhqYdoPd
 JWuIUaXBMt7YVwfIS55f14gZxEnxN9jzWbrrTOJe1boZmXZGidsGXJixj/WLVh3BuDlI
 VzzFf1spHcVhmuxtwQEyH87CHoJzs1mqJ+h5x0J11hfV6TwRV/By4ggvUJbq+07LkPXB 8g== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2nxxkr0fbp-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:23:10 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAULNA4v010367
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:23:10 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAULN9AN031000;
        Fri, 30 Nov 2018 21:23:10 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 13:23:09 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181130211846.89000-3-trond.myklebust@hammerspace.com>
Date:   Fri, 30 Nov 2018 16:23:08 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <9D04832A-FC88-409C-8742-CBF742B6CB4A@oracle.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
 <20181130211846.89000-2-trond.myklebust@hammerspace.com>
 <20181130211846.89000-3-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=745
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300181
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 4:18 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> A call to gss_wrap_req_priv() will end up replacing the original array
> in rqstp->rq_snd_buf.pages with a new one containing the encrypted
> data. In order to avoid having the rqstp->rq_snd_buf.bvec point to the
> wrong page data, we need to refresh that too.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/xprtsock.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ae77c71c1f64..615ef2397fc5 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -843,6 +843,7 @@ static int xs_nospace(struct rpc_rqst *req)
> static void
> xs_stream_prepare_request(struct rpc_rqst *req)
> {
> +	xdr_free_bvec(&req->rq_rcv_buf);

I've added a pr_warn that fires whenever rq_rcv_buf.bvec != NULL,
and it never made a peep. Am I missing something?


> 	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_NOIO);
> }
> 
> -- 
> 2.19.2
> 

--
Chuck Lever



