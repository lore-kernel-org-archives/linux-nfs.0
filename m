Return-Path: <SRS0=9vja=PN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA505C43387
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 16:25:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 748292070C
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 16:25:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lWGztGrl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726243AbfAEQZB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 5 Jan 2019 11:25:01 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:47366 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726236AbfAEQZB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jan 2019 11:25:01 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x05GK0hY135758;
        Sat, 5 Jan 2019 16:24:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=p2xwPGNuFCfbCOdtUh88jiALY/RC/eQjGDuj9ZNYgUY=;
 b=lWGztGrlQznhr4y5Je3MjfIMx/zgXWcFg3uZgubAG/BzQ4hAW4gSdodUeo9yxsQ0vF9A
 Vvh8mpTjdFA5svDOFM1WM79aVRyPSzy0A4sJnPZRtrqPUj01xUq6xcP/355aU4ibPUSA
 zpOTjpBpy/t7e8Cea6yebI2heo3SZDnkG5CBkVKfLiMpy+U8iE/y5sOUL6U5c+iZ4pwK
 gz70fKhN0p3ESQ8VlaaEYebH+nu63yPd/cHpBDahAw/LP+ChSfBmKxrf8DbM7JlKgLjz
 kVMgPx5/+Lh92SG8FCVNzWJM303ZeBJSd+q2M5att0xAlCB+D1psv0/0J2wQrs7W4MGF 3w== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2ptn7qgy58-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Jan 2019 16:24:55 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x05GOmOb027928
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 5 Jan 2019 16:24:48 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x05GOl83027343;
        Sat, 5 Jan 2019 16:24:48 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 05 Jan 2019 08:24:47 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190105130648.GC3288@kadam>
Date:   Sat, 5 Jan 2019 11:24:45 -0500
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
References: <20190105130648.GC3288@kadam>
To:     Dan Carpenter <dan.carpenter@oracle.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9127 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901050145
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Jan 5, 2019, at 8:06 AM, Dan Carpenter <dan.carpenter@oracle.com> =
wrote:
>=20
> The clean up is handled by the caller, rpcrdma_buffer_create(), so =
this
> call to rpcrdma_sendctxs_destroy() leads to a double free.

True. This fix is adequate, but I'm wondering if =
rpcrdma_sendctxs_destroy
should be made more careful about being called twice. Hm.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Fixes: ae72950abf99 ("xprtrdma: Add data structure to manage RDMA Send =
arguments")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> net/sunrpc/xprtrdma/verbs.c | 6 +-----
> 1 file changed, 1 insertion(+), 5 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 3dde05892c8e..4994e75945b8 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -845,17 +845,13 @@ static int rpcrdma_sendctxs_create(struct =
rpcrdma_xprt *r_xprt)
> 	for (i =3D 0; i <=3D buf->rb_sc_last; i++) {
> 		sc =3D rpcrdma_sendctx_create(&r_xprt->rx_ia);
> 		if (!sc)
> -			goto out_destroy;
> +			return -ENOMEM;
>=20
> 		sc->sc_xprt =3D r_xprt;
> 		buf->rb_sc_ctxs[i] =3D sc;
> 	}
>=20
> 	return 0;
> -
> -out_destroy:
> -	rpcrdma_sendctxs_destroy(buf);
> -	return -ENOMEM;
> }
>=20
> /* The sendctx queue is not guaranteed to have a size that is a
> --=20
> 2.17.1
>=20

--
Chuck Lever



