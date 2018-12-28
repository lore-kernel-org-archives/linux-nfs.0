Return-Path: <SRS0=XDl6=PF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01A20C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Dec 2018 15:37:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C49E020869
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Dec 2018 15:37:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Qxr0IdMJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732040AbeL1PhM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 28 Dec 2018 10:37:12 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:39536 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732039AbeL1PhM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Dec 2018 10:37:12 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBSFaGO3131403;
        Fri, 28 Dec 2018 15:36:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=IbguowkOUMbRBebnyT9rbS0nUm184Vi3j/2FpQJZrmk=;
 b=Qxr0IdMJsYwvQg7dLabeAT/kZY7a+OcMRZiCAiULffuiIkJCGzc+KqQxtKFeVaPqPF0a
 WdATm7DRkqLQkS6ZxRNPq4RxPIYqeyG/Ah5efPqv6CDZVEr7LKHdCrgZTcKwor2Gdurq
 j6NsmghSzIJzLKfgExUkA8YODpekAqA6w0fw0PE0D0vt1WyhSp6bZ0f6UmcaZG6Egtxa
 4SXCqadAOBoa482b6oKwsfUgFGJf60aNYtjC/ploxYIZ6GqxR8upgWrWdIWnyTPOWhEN
 ff2MKY8gk/iByE/h2Ept3/fGqhGb+a/XPJ9F0aoLpR+hxbf5+Wlxk35MnhMWrBezqaeK Xw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2phdwr1ddu-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 28 Dec 2018 15:36:54 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBSFarAP010653
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 28 Dec 2018 15:36:53 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBSFapHH022876;
        Fri, 28 Dec 2018 15:36:51 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 28 Dec 2018 07:36:50 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH net-next] svcrdma: Fix an uninitialized variable false
 warning
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181220094921.3396-1-yuehaibing@huawei.com>
Date:   Fri, 28 Dec 2018 10:36:49 -0500
Cc:     "David S. Miller" <davem@davemloft.net>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        open list <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jason Gunthorpe <jgg@ziepe.ca>
Content-Transfer-Encoding: quoted-printable
Message-Id: <282B8BD1-FE2A-4FE4-9520-144ACF5CB74C@oracle.com>
References: <20181220094921.3396-1-yuehaibing@huawei.com>
To:     YueHaibing <yuehaibing@huawei.com>,
        Bart Van Assche <bvanassche@acm.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9120 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812280136
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Dec 20, 2018, at 4:49 AM, YueHaibing <yuehaibing@huawei.com> wrote:
>=20
> smatch warning this:
> net/sunrpc/xprtrdma/svc_rdma_rw.c:351 svc_rdma_post_chunk_ctxt() =
error: uninitialized symbol 'bad_wr'
> net/sunrpc/xprtrdma/verbs.c:1569 rpcrdma_post_recvs() error: =
uninitialized symbol 'bad_wr'
>=20
> 'bad_wr' is initialized in ib_post_send. But smatch
> doesn't know that and warns this.
>=20
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
> net/sunrpc/xprtrdma/svc_rdma_rw.c | 2 +-
> net/sunrpc/xprtrdma/verbs.c       | 2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c =
b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> index dc19517..0954b25 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> @@ -308,7 +308,7 @@ static int svc_rdma_post_chunk_ctxt(struct =
svc_rdma_chunk_ctxt *cc)
> 	struct svcxprt_rdma *rdma =3D cc->cc_rdma;
> 	struct svc_xprt *xprt =3D &rdma->sc_xprt;
> 	struct ib_send_wr *first_wr;
> -	const struct ib_send_wr *bad_wr;
> +	const struct ib_send_wr *bad_wr =3D NULL;
> 	struct list_head *tmp;
> 	struct ib_cqe *cqe;
> 	int ret;
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 3ddba94..37be70f 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1518,7 +1518,7 @@ void
> rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp)
> {
> 	struct rpcrdma_buffer *buf =3D &r_xprt->rx_buf;
> -	struct ib_recv_wr *wr, *bad_wr;
> +	struct ib_recv_wr *wr, *bad_wr =3D NULL;
> 	int needed, count, rc;
>=20
> 	rc =3D 0;
> --=20
> 2.7.0

Does this need

Fixes: d34ac5cd3a73 ("RDMA, core and ULPs: Declare ib_post_send() and =
ib_post_recv() arguments const")  ???

Bart, any comments?


--
Chuck Lever



