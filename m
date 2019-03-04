Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59936C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:26:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 233B320657
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:26:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W9fKGMoZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726111AbfCDP0Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 10:26:24 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:46178 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726098AbfCDP0Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2019 10:26:24 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x24FOJuX097397;
        Mon, 4 Mar 2019 15:26:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=c2KU5i5YNlI27DNqMv4PNnhIiV8Qbn4abp7fp2/EHb0=;
 b=W9fKGMoZvcdTYoMJj2yMnj1kNgjxLmluj4A1ZAERjP4RJG1zzZH35YZi7Ee4pDHxWgDl
 C6kXFyNr7f7UIxYQKqWUbTWMj1cYQ2m6AUMNqXNet0+m1Jy4qI7vcO55EZB7ESMJQimR
 OMKQpb2NQmRHwARlwoKE+O+4CGB5y7bBx08iABPcSTdMEvXVmUIyJDVmY7tjnctvFX9k
 IGczMIfumUin0veBvvjBvvv9jaXwcUY6cAkdmu9AbgNbXENYOYbnZUmOUmdveEVBW5Gz
 J3kI/H41qX8NqaPERZfl+xNjbRRrlt4nvgmOKIi9FMDVEfiNdp8j3Mw6eVbcf85LjEXa dg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2qyh8tyg0d-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Mar 2019 15:26:21 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x24FQL0t011327
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Mar 2019 15:26:21 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x24FQLoC029928;
        Mon, 4 Mar 2019 15:26:21 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Mar 2019 07:26:21 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 3/3] SUNRPC: Allow dynamic allocation of back channel
 slots
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190304001928.4397-3-trond.myklebust@hammerspace.com>
Date:   Mon, 4 Mar 2019 10:26:20 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D12A8479-F573-4B7C-84D0-EC0FE0F87520@oracle.com>
References: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
 <20190304001928.4397-2-trond.myklebust@hammerspace.com>
 <20190304001928.4397-3-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9184 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903040112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond-


> On Mar 3, 2019, at 7:19 PM, Trond Myklebust <trondmy@gmail.com> wrote:
>=20
> Now that the reads happen in a process context rather than a softirq,
> it is safe to allocate back channel slots using a reclaiming
> allocation.

Is this a required change for transports, or simply an optimization?
Wondering if a similar change is needed for RPC-over-RDMA.


> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/backchannel_rqst.c | 41 +++++++++++++++++++++--------------
> 1 file changed, 25 insertions(+), 16 deletions(-)
>=20
> diff --git a/net/sunrpc/backchannel_rqst.c =
b/net/sunrpc/backchannel_rqst.c
> index b9313c15ee3a..c47d82622fd1 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -235,7 +235,8 @@ void xprt_destroy_bc(struct rpc_xprt *xprt, =
unsigned int max_reqs)
> 		list_empty(&xprt->bc_pa_list) ? "true" : "false");
> }
>=20
> -static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, =
__be32 xid)
> +static struct rpc_rqst *xprt_get_bc_request(struct rpc_xprt *xprt, =
__be32 xid,
> +		struct rpc_rqst *new)
> {
> 	struct rpc_rqst *req =3D NULL;
>=20
> @@ -243,10 +244,9 @@ static struct rpc_rqst =
*xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
> 	if (atomic_read(&xprt->bc_free_slots) <=3D 0)
> 		goto not_found;
> 	if (list_empty(&xprt->bc_pa_list)) {
> -		req =3D xprt_alloc_bc_req(xprt, GFP_ATOMIC);
> -		if (!req)
> +		if (!new)
> 			goto not_found;
> -		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
> +		list_add_tail(&new->rq_bc_pa_list, &xprt->bc_pa_list);
> 		xprt->bc_alloc_count++;
> 	}
> 	req =3D list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
> @@ -256,8 +256,8 @@ static struct rpc_rqst =
*xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
> 			sizeof(req->rq_private_buf));
> 	req->rq_xid =3D xid;
> 	req->rq_connect_cookie =3D xprt->connect_cookie;
> -not_found:
> 	dprintk("RPC:       backchannel req=3D%p\n", req);
> +not_found:
> 	return req;
> }
>=20
> @@ -320,18 +320,27 @@ void xprt_free_bc_rqst(struct rpc_rqst *req)
>  */
> struct rpc_rqst *xprt_lookup_bc_request(struct rpc_xprt *xprt, __be32 =
xid)
> {
> -	struct rpc_rqst *req;
> -
> -	spin_lock(&xprt->bc_pa_lock);
> -	list_for_each_entry(req, &xprt->bc_pa_list, rq_bc_pa_list) {
> -		if (req->rq_connect_cookie !=3D xprt->connect_cookie)
> -			continue;
> -		if (req->rq_xid =3D=3D xid)
> -			goto found;
> -	}
> -	req =3D xprt_alloc_bc_request(xprt, xid);
> +	struct rpc_rqst *req, *new =3D NULL;
> +
> +	do {
> +		spin_lock(&xprt->bc_pa_lock);
> +		list_for_each_entry(req, &xprt->bc_pa_list, =
rq_bc_pa_list) {
> +			if (req->rq_connect_cookie !=3D =
xprt->connect_cookie)
> +				continue;
> +			if (req->rq_xid =3D=3D xid)
> +				goto found;
> +		}
> +		req =3D xprt_get_bc_request(xprt, xid, new);
> found:
> -	spin_unlock(&xprt->bc_pa_lock);
> +		spin_unlock(&xprt->bc_pa_lock);
> +		if (new) {
> +			if (req !=3D new)
> +				xprt_free_bc_rqst(new);
> +			break;
> +		} else if (req)
> +			break;
> +		new =3D xprt_alloc_bc_req(xprt, GFP_KERNEL);
> +	} while (new);
> 	return req;
> }
>=20
> --=20
> 2.20.1
>=20

--
Chuck Lever



