Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48638C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 15:19:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 198A5205C9
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 15:19:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vCAUJp27"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2394006AbfAPPTF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 10:19:05 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:49854 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731337AbfAPPTE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 10:19:04 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0GFCoeX043118;
        Wed, 16 Jan 2019 15:18:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=0rGSWcNF6I1hPfIfeqvHiTb9CPWmI2MXzcrj/vH6X1Y=;
 b=vCAUJp27jNmVTKwfe8cCdK6m0Mpy5UJvi3UjqnhFilVcJwloUuqCp3w73Px0qCHBzT2B
 Rltq3NdJsgnlae4bVo7KkKQCiY8wGLSW21k1foCfEA/BUcE3r0UKzwbw9abdgO8jZBFP
 qvKWtFCsM6+Y3jyube+CV106GHH7cymUlZUbjSLhkDpvNTzTd/jb+Mjhl9p3WHIlUHFM
 nSW7IY1d0hUx/ItqoReoricjrYTjRWI2O313ftH3Otld0UW2lzpCMSQTqUN7WH5jOUq+
 AttVJ/Id+8hqwzQur4mPhVTZKM0mu67MYKhMmsPANaSsGikXPqFp60LE951jE+bzRAZj qQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2pybjntga7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 16 Jan 2019 15:18:43 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0GFIfnV016168
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 16 Jan 2019 15:18:42 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0GFIdb8012897;
        Wed, 16 Jan 2019 15:18:39 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 16 Jan 2019 07:18:39 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH net-next] xprtrdma: Fix error return code in
 rpcrdma_buffer_create()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1547635124-62243-1-git-send-email-weiyongjun1@huawei.com>
Date:   Wed, 16 Jan 2019 10:18:37 -0500
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <84778E0E-6A51-4348-94C6-57110599DAD3@oracle.com>
References: <1547635124-62243-1-git-send-email-weiyongjun1@huawei.com>
To:     Wei Yongjun <weiyongjun1@huawei.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9138 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901160125
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On Jan 16, 2019, at 5:38 AM, Wei Yongjun <weiyongjun1@huawei.com> wrote:

> Fix to return a negative error code -ENOMEM from the error handling
> case instead of 0, as done elsewhere in this function.
>=20
> Fixes: 6d2d0ee27c7a ("xprtrdma: Replace rpcrdma_receive_wq with a =
per-xprt workqueue")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

I thought we'd already fixed this one, but:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/xprtrdma/verbs.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 7749a2b..3dde058 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1113,8 +1113,10 @@ struct rpcrdma_req *
> 						WQ_MEM_RECLAIM | =
WQ_HIGHPRI,
> 						0,
> 			=
r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
> -	if (!buf->rb_completion_wq)
> +	if (!buf->rb_completion_wq) {
> +		rc =3D -ENOMEM;
> 		goto out;
> +	}
>=20
> 	return 0;
> out:


--
Chuck Lever



