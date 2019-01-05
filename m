Return-Path: <SRS0=9vja=PN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB5EC43387
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 16:17:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 388F72070C
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 16:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0NiijQIR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726251AbfAEQRV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 5 Jan 2019 11:17:21 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:59992 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726234AbfAEQRV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jan 2019 11:17:21 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x05GEIxG172445;
        Sat, 5 Jan 2019 16:17:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=uhz0yXsplBq923/XbtaWg+wIVAskGf7n3AKRLCsGS5s=;
 b=0NiijQIR13cvgt37odILhoCpG9WIzj2zwRQw5QsDoODbV8kvc7nZtuQiAjjkubo/iWUA
 fodHm+SpEFlM9iw7E5TKRmSLke2SCKfby1l1ZXjfkoMW5AVCMYnhNQCQBmoQj5E/4tfP
 sFtS7XSIXNr32foK17DecbHD5yirEyOkrPwZ+4FEw7/wEy8JnX8FpJCsHtxDYdMncEQB
 obKLxBCUvpCpsvWIb+fwzecWBvBpNn5p7xoU8oTpKN/+YZRVVRMDZwN9i3SYqsZADAl4
 stYqPs59ZD4xssDskz91spylKijriN15putvfvsrMbCQO+k0EV//S0fo7RwwY/TSb1+E RA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2ptm0ts37p-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Jan 2019 16:17:15 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x05GHE8p014005
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 5 Jan 2019 16:17:14 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x05GHAeb031001;
        Sat, 5 Jan 2019 16:17:10 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 05 Jan 2019 08:17:10 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 1/2] xprtrdma: Fix error code in rpcrdma_buffer_create()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190105130607.GB3288@kadam>
Date:   Sat, 5 Jan 2019 11:17:09 -0500
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <D028449F-114A-4014-9B97-A124740F3D70@oracle.com>
References: <20190105130607.GB3288@kadam>
To:     Dan Carpenter <dan.carpenter@oracle.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9127 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=990
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901050144
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Jan 5, 2019, at 8:06 AM, Dan Carpenter <dan.carpenter@oracle.com> =
wrote:
>=20
> This should return -ENOMEM if __alloc_workqueue_key() fails, but it
> returns success.
>=20
> Fixes: 6d2d0ee27c7a ("xprtrdma: Replace rpcrdma_receive_wq with a =
per-xprt workqueue")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Indeed.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/xprtrdma/verbs.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 7749a2bf6887..3dde05892c8e 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1113,8 +1113,10 @@ rpcrdma_buffer_create(struct rpcrdma_xprt =
*r_xprt)
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
> --=20
> 2.17.1
>=20

--
Chuck Lever



