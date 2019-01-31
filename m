Return-Path: <SRS0=SG1H=QH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A4BCC169C4
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 14:11:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 309A420869
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 14:11:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5GcbCBFP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727452AbfAaOLv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Jan 2019 09:11:51 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:40624 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726977AbfAaOLv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2019 09:11:51 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0VDwuPu014744;
        Thu, 31 Jan 2019 14:11:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=N5VR5x4CDRyax5gYEKWdfiG1SVVfqYpLpX5VzlWJST0=;
 b=5GcbCBFPGrHXiJ6Kn7Sk9G9JzKJ0mvqIHiX9wwFJ4oDQhdei7TdO+mDfcR+gS+CmFSU9
 +JA4FbfXFOCx1y6YaaUASbip8E2vCEbzHDIzSC1lvuo5ojKk/ig4bzhfCNTxEQEcWDNO
 RdGXPG8nGW6QUUuXs7AgSBKwNrvxVyQ52iW+QCYFucB44kTIij6TodfVI3hGwPVvc5or
 EnJ0RE/9l1936XecH8W7ksfpi+KXFf+7nb6cE78p+8q66tIdKs/unPQWQYzHLepSel5t
 s3uYb7rCpBbGTc+8CBAsvG9BpbMZ4/v7hGE91BWvsT6UpDinYMiXnAu+Eo92y0QoN4aX wg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2q8eyurxf5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 31 Jan 2019 14:11:30 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0VEBT6P002279
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 31 Jan 2019 14:11:29 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0VEBQ0U019026;
        Thu, 31 Jan 2019 14:11:26 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 31 Jan 2019 06:11:26 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH net-next] xprtrdma: Use struct_size() in kzalloc()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190131004622.GA30261@embeddedor>
Date:   Thu, 31 Jan 2019 09:11:24 -0500
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <07CB966E-A946-4956-8480-C0FC13E13E4E@oracle.com>
References: <20190131004622.GA30261@embeddedor>
To:     "Gustavo A. R. Silva" <gustavo@embeddedor.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310110
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 30, 2019, at 7:46 PM, Gustavo A. R. Silva =
<gustavo@embeddedor.com> wrote:
>=20
> One of the more common cases of allocation size calculations is =
finding
> the size of a structure that has a zero-sized array at the end, along
> with memory for some number of elements for that array. For example:
>=20
> struct foo {
>    int stuff;
>    struct boo entry[];
> };
>=20
> instance =3D kzalloc(sizeof(struct foo) + count * sizeof(struct boo), =
GFP_KERNEL);
>=20
> Instead of leaving these open-coded and prone to type mistakes, we can
> now use the new struct_size() helper:
>=20
> instance =3D kzalloc(struct_size(instance, entry, count), GFP_KERNEL);
>=20
> This code was detected with the help of Coccinelle.
>=20
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/xprtrdma/verbs.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 4994e75945b8..9e8cf7456840 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -811,8 +811,7 @@ static struct rpcrdma_sendctx =
*rpcrdma_sendctx_create(struct rpcrdma_ia *ia)
> {
> 	struct rpcrdma_sendctx *sc;
>=20
> -	sc =3D kzalloc(sizeof(*sc) +
> -		     ia->ri_max_send_sges * sizeof(struct ib_sge),
> +	sc =3D kzalloc(struct_size(sc, sc_sges, ia->ri_max_send_sges),
> 		     GFP_KERNEL);
> 	if (!sc)
> 		return NULL;
> --=20
> 2.20.1
>=20

--
Chuck Lever



