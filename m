Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D183C282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 17:23:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC50420818
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 17:23:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ERBI1+oN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727575AbfBERXM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 12:23:12 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:60430 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726276AbfBERXM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2019 12:23:12 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x15HJXOK180905;
        Tue, 5 Feb 2019 17:23:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=6OBnHj52QEpbe+P3tRnF6xj7BgA9AczrA4CgJisJT+U=;
 b=ERBI1+oNXRwdP5BuSUJGljLCU79GwVHABp17wr7EXq9em/SBPcdxGK5brgxrex348dRc
 5Uc9R9znItcASkKZwqCf53vJXuMppBnpYLptE4oJkjMYBLh80tQ/NI4wvMTyVhk0UPq1
 TxHJaootfbURltGeQfDAAzd5oT4VhDYkO7PkEVAet02xpO3HaBvL9Q+j/n+wuGC5Vlnj
 dweNvH7IXNO/PoA9jfaUKBQhBG2zw4y7JVpPO0zgt1evojZj4CHoAMPdoPLNYvIMyqoC
 O/vtBZ1sfXVzQAfRyb/Y9BoPTYmx/+nw+/g33Je6LgfsldIE+sdoUUmfo9Ce8/hZi6Db vw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2qd97evee5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 05 Feb 2019 17:23:06 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x15HN5Jl007861
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 5 Feb 2019 17:23:05 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x15HN3Fu009126;
        Tue, 5 Feb 2019 17:23:03 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 05 Feb 2019 17:23:03 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v3] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9d418664-1f67-c705-19a0-80fc9dc5a12b@suse.com>
Date:   Tue, 5 Feb 2019 12:23:01 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <91CC910C-48A1-4234-8347-39D1A710A87C@oracle.com>
References: <9d418664-1f67-c705-19a0-80fc9dc5a12b@suse.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9157 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902050133
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 5, 2019, at 12:21 PM, Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com> wrote:
>=20
> Make sure the device has at least 2 completion vectors
> before allocating to compvec#1
>=20
> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
> Signed-off-by: Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Anna, can you see that this fix gets into v5.0-rc ? Thanks!


> ---
> Changes since v2:
> - Split line for checkpatch to be happy
>=20
> net/sunrpc/xprtrdma/verbs.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b725911c0f3f..5fe727a7db82 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -546,7 +546,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct =
rpcrdma_ia *ia,
>=20
> 	sendcq =3D ib_alloc_cq(ia->ri_device, NULL,
> 			     ep->rep_attr.cap.max_send_wr + 1,
> -			     1, IB_POLL_WORKQUEUE);
> +			     ia->ri_device->num_comp_vectors > 1 ? 1 : =
0,
> +			     IB_POLL_WORKQUEUE);
> 	if (IS_ERR(sendcq)) {
> 		rc =3D PTR_ERR(sendcq);
> 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
> --=20
> 2.18.0

--
Chuck Lever



