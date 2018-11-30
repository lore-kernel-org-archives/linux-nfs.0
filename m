Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE15DC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:15:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8CD012082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Fo8xblrO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CD012082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726454AbeLAJ0I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:26:08 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:60468 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725867AbeLAJ0I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:26:08 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAUME8Oe151435;
        Fri, 30 Nov 2018 22:15:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=hXM3A8HFic0jOnysNlu81TMdQb+p6ERDER54J9Zjb6w=;
 b=Fo8xblrOMIY/z7L2erPfJKrQZPpL8FZU3kypzQMX9XSCHpg57tKUWc0NPLwJYTy1Lr0Z
 JXDnBHgijMoMgyavYVMECm57x7LVvHgsinzqLHBk7PHrCnO31Aur26s8HD9QUXgdF9LJ
 hY1tuZgIpQVmWMVgpi7KwoDaY0a6jZ7k5k6YWNgRNAHcXa5F2lJVubosGQaNFqE8h0Mf
 7RfBQGwMxryZeEo5V6C7wBD5LmrO3igv/kwyYP64JEGMXb4DJmywzWIYD8bN2Xicu9nI
 a+Gp1s8TzNxOIky4LWbZesGKQ95UEGHJEokgMzVlc0XJq+mlQc9RziZJf5r2SYmAay/9 uw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2nxy9rrkh3-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 22:15:21 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAUMFKiQ002882
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 22:15:20 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wAUMFKd3004646;
        Fri, 30 Nov 2018 22:15:20 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 14:15:20 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181130215555.91107-3-trond.myklebust@hammerspace.com>
Date:   Fri, 30 Nov 2018 17:15:18 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
 <20181130215555.91107-2-trond.myklebust@hammerspace.com>
 <20181130215555.91107-3-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=656
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300188
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 4:55 PM, Trond Myklebust <trondmy@gmail.com> =
wrote:
>=20
> A call to gss_wrap_req_priv() will end up replacing the original array
> in rqstp->rq_snd_buf.pages with a new one containing the encrypted
> data. In order to avoid having the rqstp->rq_snd_buf.bvec point to the
> wrong page data, we need to refresh that too.

I would add a note here that this patch fixes a memory leak. And
you might want to add a Fixes: tag.

I'm trying it out now.


> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> include/linux/sunrpc/xdr.h | 1 -
> net/sunrpc/xprt.c          | 2 ++
> net/sunrpc/xprtsock.c      | 1 +
> 3 files changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 43106ffa6788..2ec128060239 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -72,7 +72,6 @@ xdr_buf_init(struct xdr_buf *buf, void *start, =
size_t len)
> 	buf->head[0].iov_base =3D start;
> 	buf->head[0].iov_len =3D len;
> 	buf->tail[0].iov_len =3D 0;
> -	buf->bvec =3D NULL;
> 	buf->pages =3D NULL;
> 	buf->page_len =3D 0;
> 	buf->flags =3D 0;
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 86bea4520c4d..122c91c28e7c 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1623,6 +1623,8 @@ xprt_request_init(struct rpc_task *task)
> 	req->rq_snd_buf.buflen =3D 0;
> 	req->rq_rcv_buf.len =3D 0;
> 	req->rq_rcv_buf.buflen =3D 0;
> +	req->rq_snd_buf.bvec =3D NULL;
> +	req->rq_rcv_buf.bvec =3D NULL;
> 	req->rq_release_snd_buf =3D NULL;
> 	xprt_reset_majortimeo(req);
> 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ae77c71c1f64..615ef2397fc5 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -843,6 +843,7 @@ static int xs_nospace(struct rpc_rqst *req)
> static void
> xs_stream_prepare_request(struct rpc_rqst *req)
> {
> +	xdr_free_bvec(&req->rq_rcv_buf);
> 	req->rq_task->tk_status =3D xdr_alloc_bvec(&req->rq_rcv_buf, =
GFP_NOIO);
> }
>=20
> --=20
> 2.19.2
>=20

--
Chuck Lever



