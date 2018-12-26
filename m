Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B2C5C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 17:44:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A0D3218EA
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 17:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WR1YTXZl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727423AbeLZRoW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Dec 2018 12:44:22 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:57564 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727285AbeLZRoV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Dec 2018 12:44:21 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBQHiC7r070530;
        Wed, 26 Dec 2018 17:44:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=b4f97dyP03PYE3j0dippliGp3beCkGWO/6teR4/z+/s=;
 b=WR1YTXZlROFtTwkzgQpnJbgx/yks78RYPHjoWCNO8+PljVk0eOAcDLkwAk2dedEd8khE
 KsljaPYj0Nm/axTVSnKrAYJ5hrKtCTReczRdgMki7ZjD6nOOLhljf97CRXgR7mttco9X
 QbXngtqBpyQxHmtVGXs+JNWPBs1z67jTBCG8un5hOG1KNqoi3uSrSOpOaKCK2135qMou
 ZyEmuqWc8TAbubeV9d7rFPQ5wuY3FVGSIQLVkYA0MDm16AE9FMVmSG1xC7aX7P2Auew0
 FuuLHkRoTHWkQkLui2nA4uJkO8pZBHKR3jV6V5/fdD6IeE4cwZAD21i0JZlHQHkktDQG MA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2phcpttatt-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 26 Dec 2018 17:44:11 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBQHiB4U020753
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 26 Dec 2018 17:44:11 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBQHiACK013169;
        Wed, 26 Dec 2018 17:44:10 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 26 Dec 2018 09:44:10 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] sunrpc: remove redundant code
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181226032415.73064-1-kjlu@umn.edu>
Date:   Wed, 26 Dec 2018 12:44:08 -0500
Cc:     pakki001@umn.edu, Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <432FED98-2410-4760-8E7C-20675051FE96@oracle.com>
References: <20181226032415.73064-1-kjlu@umn.edu>
To:     Kangjie Lu <kjlu@umn.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9118 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812260160
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 25, 2018, at 10:24 PM, Kangjie Lu <kjlu@umn.edu> wrote:
>=20
> If no bytes to decode, just use "xdr->p" instead of calling
> xdr_inline_decode to get it. The fix cleans up the code.
>=20
> Signed-off-by: Kangjie Lu <kjlu@umn.edu>
> ---
> net/sunrpc/xprtrdma/rpc_rdma.c | 4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c =
b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 9f53e0240035..2ef86be49bd8 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -1123,7 +1123,6 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, =
struct rpcrdma_rep *rep,
> {
> 	struct xdr_stream *xdr =3D &rep->rr_stream;
> 	u32 writelist, replychunk, rpclen;
> -	char *base;
>=20
> 	/* Decode the chunk lists */
> 	if (decode_read_list(xdr))
> @@ -1138,10 +1137,9 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, =
struct rpcrdma_rep *rep,
> 		return -EIO;
>=20
> 	/* Build the RPC reply's Payload stream in rqst->rq_rcv_buf */
> -	base =3D (char *)xdr_inline_decode(xdr, 0);
> 	rpclen =3D xdr_stream_remaining(xdr);
> 	r_xprt->rx_stats.fixup_copy_count +=3D
> -		rpcrdma_inline_fixup(rqst, base, rpclen, writelist & 3);
> +		rpcrdma_inline_fixup(rqst, xdr->p, rpclen, writelist & =
3);

I used xdr_inline_decode(xdr, 0) here because I didn't want to
embed specific knowledge about struct xdr_stream into
rpcrdma_decode_msg. IOW, adhere to the API contract.

Given the need for adding a type cast to this function call, as
reported by the kbuild robot, I don't see that this patch improves
things significantly.


> 	r_xprt->rx_stats.total_rdma_reply +=3D writelist;
> 	return rpclen + xdr_align_size(writelist);
> --=20
> 2.17.2 (Apple Git-113)
>=20

--
Chuck Lever



