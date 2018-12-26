Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD61DC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 17:35:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E40321741
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 17:35:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ez5PvD3i"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727274AbeLZRfg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Dec 2018 12:35:36 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:50342 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727146AbeLZRfg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Dec 2018 12:35:36 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBQHXuuM062120;
        Wed, 26 Dec 2018 17:35:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=+Yh/1c4+gimEdGqDbkeMOUpmpBP4XGH97cPlMvlqIuM=;
 b=ez5PvD3iQxjzU47pfeSDprwc9cYEVQUmrQXbiE/5zvu6W2mJvfEz30okAvXZSvqoZK7g
 LQJNoTwzb0ryNDQ2xXYvSHNU2QYhXtyWZVayQja3t8bk4XX7hZjehs2jptfyETf87W6R
 Oridm2AE4MT2rSyctRO/BNup+J2RCweUuku3A+eK0GwpCtSyoioRKI3alYSq27T8I2uD
 keIZKFF6aj07iLTwvasvVkMTe0VmkQvsM0EDrqLBCC9m9msa9nMOWJ/MjrI2/zu5g6N4
 x7ooQXbEKsG5GRlznm2i2NXeuSMlMzB3+58J7sSSoFT5eOahURYOg5KjNwIJ61/CXS73 JQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2phcptta84-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 26 Dec 2018 17:35:27 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBQHZOGq004004
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 26 Dec 2018 17:35:25 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBQHZML2025289;
        Wed, 26 Dec 2018 17:35:22 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 26 Dec 2018 09:35:21 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] sunrpc: fix a missing check of xdr_inline_decode
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181226031823.72962-1-kjlu@umn.edu>
Date:   Wed, 26 Dec 2018 12:35:20 -0500
Cc:     pakki001@umn.edu, Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <1C2E97C7-AA91-40E8-B42E-DA6A81CE4CAC@oracle.com>
References: <20181226031823.72962-1-kjlu@umn.edu>
To:     Kangjie Lu <kjlu@umn.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9118 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=932
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812260158
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 25, 2018, at 10:18 PM, Kangjie Lu <kjlu@umn.edu> wrote:
>=20
> xdr_inline_decode() could fail.

NAK: xdr_inline_decode cannot fail if its second argument is zero.


> When it fails, the return value is NULL
> and should not be dereferenced.
> The fix checks if xdr_inline_decode fails, and if so, returns.
>=20
> Signed-off-by: Kangjie Lu <kjlu@umn.edu>
> ---
> net/sunrpc/xprtrdma/backchannel.c | 2 ++
> 1 file changed, 2 insertions(+)
>=20
> diff --git a/net/sunrpc/xprtrdma/backchannel.c =
b/net/sunrpc/xprtrdma/backchannel.c
> index e5b367a3e517..bd9be5272ef4 100644
> --- a/net/sunrpc/xprtrdma/backchannel.c
> +++ b/net/sunrpc/xprtrdma/backchannel.c
> @@ -285,6 +285,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt =
*r_xprt,
> 	__be32 *p;
>=20
> 	p =3D xdr_inline_decode(&rep->rr_stream, 0);
> +	if (unlikely(!p))
> +		goto out_overflow;
> 	size =3D xdr_stream_remaining(&rep->rr_stream);
>=20
> #ifdef RPCRDMA_BACKCHANNEL_DEBUG
> --=20
> 2.17.2 (Apple Git-113)
>=20

--
Chuck Lever



