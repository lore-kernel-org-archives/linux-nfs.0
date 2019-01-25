Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAE93C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 17:32:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 72A8A218A6
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 17:32:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nP2aRIIz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726611AbfAYRcH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 12:32:07 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:52588 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726252AbfAYRcH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 12:32:07 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0PHU0cT118787;
        Fri, 25 Jan 2019 17:32:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=NXE8vuLVrN4+LfmYxxTrEylzUDpCo6c2eNoPRn4g4+k=;
 b=nP2aRIIzToBVh5mCyHJQ1xeDkRcJPrFZ91RgYNIGNhMBkYB2k8zPsrTWqS7bXQE5Y9tR
 MPVDUxuKDEBowjMQYySY+EVLYBbhj26HkhdQ9FMPNiRC60eayODeMJcHN/U8Cbvb6Cab
 JbZe6H+0S6g9PYN3nNFClYanamQmEghN4ptY+nddOZ8Tt8YNtsm15BxKfIdxHu6Jm+6L
 tVxiLFeqmkWsHR7Hylb3mRacoTkNnQTGgOJOMcs+BOprYry3XeAgfc05Owun2SsO8SYy
 9ag4+I9tMWWZkbJcZRHxKLcLohuMhcze78CzSr4PhnhTLETUIbiF5Bxf3EasYfvm3xUL cg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2q3vhs6y09-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 17:32:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0PHW2Lu023204
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 17:32:03 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0PHW2Yw012461;
        Fri, 25 Jan 2019 17:32:02 GMT
Received: from [10.126.150.87] (/148.87.23.44)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 25 Jan 2019 09:32:02 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <164839c0-399e-d01b-dafc-5c873e650bdb@suse.com>
Date:   Fri, 25 Jan 2019 09:32:01 -0800
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F7BDA38C-7ACB-4A10-972B-628E59EE64EA@oracle.com>
References: <164839c0-399e-d01b-dafc-5c873e650bdb@suse.com>
To:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9147 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901250140
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 23, 2019, at 11:02 PM, Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com> wrote:
>=20
> Make sure the device has at least 2 completion vectors before =
allocating to compvec#1
>=20
> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
> Signed-off-by: Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com>
> ---
> Fixes since v1:
> - Use num_comp_vector instead online_cpus
>=20
> net/sunrpc/xprtrdma/verbs.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b725911c0f3f..db913bcef984 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -546,7 +546,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct =
rpcrdma_ia *ia,
>=20
> 	sendcq =3D ib_alloc_cq(ia->ri_device, NULL,
> 			     ep->rep_attr.cap.max_send_wr + 1,
> -			     1, IB_POLL_WORKQUEUE);
> +			     ia->ri_device->num_comp_vectors > 1 ? 1 : =
0, IB_POLL_WORKQUEUE);

Nit: You should split this line. Otherwise:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

And I'll look into smarter compvec allocation again.


> 	if (IS_ERR(sendcq)) {
> 		rc =3D PTR_ERR(sendcq);
> 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
> --=20
> 2.18.0
>=20

--
Chuck Lever



