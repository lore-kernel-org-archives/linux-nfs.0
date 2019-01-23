Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC9EC282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 16:51:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44C972085A
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 16:51:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Z8OaPQeK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726040AbfAWQvg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 11:51:36 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:46750 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725871AbfAWQvg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2019 11:51:36 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0NGml0w051738;
        Wed, 23 Jan 2019 16:51:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=TKrl/dD6yvrs+1tkTcJsVlGAxz+Z4WMllXHXBX3B2BQ=;
 b=Z8OaPQeKctll4Ouu3ChvVNnQSLqza7nspXmTypNeOIvG1j+2LBO44fXFgrxd7bibHi8F
 mYyF6+GAv9ZtXnqCdlmMQLxGsgxuk8QG8ogvKXpAwkrigEmhP8pkNFccgTz/RtjsKX/E
 HA6NNUWHOuF60n143/mjn2IXHYyuTl4tEMB+7VJK2IkOckeIEtrxPVEbXKEzmcSpKhsp
 HZLNwLyRp1AgMX/OCSN2Ryfld4x+Ieo1llmdKhqnGgAZNq0OSXz2Xp7lBgKsDZs4tVLy
 nKMZpHMOSKYiGW1WSfZcYFhiyA9TbkyaPpkpB7vc7vdwPf+tuXoEeFtag6HmS+gl+Zzl PQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2q3uauu3ux-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 23 Jan 2019 16:51:31 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0NGpU0S025087
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 23 Jan 2019 16:51:31 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0NGpURM003945;
        Wed, 23 Jan 2019 16:51:30 GMT
Received: from dhcp-10-211-47-54.usdhcp.oraclecorp.com (/10.211.47.54)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 23 Jan 2019 08:51:30 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] xprtrdma: Make sure Send CQ is allocated on an existing
 CPU
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3f5da1e4-99f1-8376-a291-e50a7d52c303@suse.com>
Date:   Wed, 23 Jan 2019 11:51:49 -0500
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>
References: <3f5da1e4-99f1-8376-a291-e50a7d52c303@suse.com>
To:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9145 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901230123
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Nicolas-

> On Jan 23, 2019, at 8:12 AM, Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com> wrote:
>=20
> Make sure host has at least 2 CPU before allocating to CPU#1

The fourth parameter of ib_alloc_cq() is not a CPU number,
it's a completion vector number. What failure did you see
that prompted this patch?


> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
> Signed-off-by: Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com>
> ---
> net/sunrpc/xprtrdma/verbs.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b725911c0f3f..36aa7b2648e4 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -546,7 +546,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct =
rpcrdma_ia *ia,
>=20
> 	sendcq =3D ib_alloc_cq(ia->ri_device, NULL,
> 			     ep->rep_attr.cap.max_send_wr + 1,
> -			     1, IB_POLL_WORKQUEUE);
> +			     num_online_cpus() > 1 ? 1 : 0, =
IB_POLL_WORKQUEUE);
> 	if (IS_ERR(sendcq)) {
> 		rc =3D PTR_ERR(sendcq);
> 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
> --=20
> 2.18.0
>=20

--
Chuck Lever



