Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4594C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:05:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A2C6F206B6
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:05:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jddSrTOx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726590AbfCDQFY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:05:24 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:60912 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726430AbfCDQFX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2019 11:05:23 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x24G3bHB135915;
        Mon, 4 Mar 2019 16:05:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=fmwkQxBzSCSbpI2vAfI46QM05+26YKmsil9Vr/XJ7KI=;
 b=jddSrTOx90zFTMBaB0yQhqaw9L2goCglftgOyD2yKvJE6+75tZnDifY38wA6Oousbmeo
 vtMo4I1HBna4orP7J008yUcLv37tlN9UVPm4sY6bAwwXwavLQzZmMkW3Q4ORcGIOb3WY
 MoYbr//ylK7KE4/6jQK8NiZ7cBWtxE9Ef0ZoHYksPq8btN0etHk10DFm6wUz84T03Z5S
 8iTb99uKGtr7AqUxgit5UK17amYeBGcQ+JdTK+DpMl03aoXFaWefAEqyiCDAax7GkTLd
 4V/eZ0xDM2RJu3p5VBNMrOKXLoYR5psfyoWAY60KorVAIGyPo3cDW+b3P/PMhTqgnnp/ PQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2qyjfr7m9n-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Mar 2019 16:05:20 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x24G5JrW007377
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Mar 2019 16:05:19 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x24G5JK2028352;
        Mon, 4 Mar 2019 16:05:19 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Mar 2019 08:05:18 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ddaf320c5c7a4e90f7a1b034fbbabf9bba899fea.camel@hammerspace.com>
Date:   Mon, 4 Mar 2019 11:05:17 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E8DA13E4-5164-4092-A695-B9F11E6D28F9@oracle.com>
References: <20190304153222.27638.90558.stgit@manet.1015granger.net>
 <ddaf320c5c7a4e90f7a1b034fbbabf9bba899fea.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9184 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903040117
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 4, 2019, at 11:02 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2019-03-04 at 10:32 -0500, Chuck Lever wrote:
>> Page allocation requests made when the SPARSE_PAGES flag is set are
>> allowed to fail, and are not critical. No need to spend a rare
>> resource.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/socklib.c           |    2 +-
>> net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
>> 2 files changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
>> index 7e55cfc..9faea12 100644
>> --- a/net/sunrpc/socklib.c
>> +++ b/net/sunrpc/socklib.c
>> @@ -106,7 +106,7 @@ static size_t xdr_skb_read_and_csum_bits(struct
>> xdr_skb_reader *desc, void *to,
>> 		/* ACL likes to be lazy in allocating pages - ACLs
>> 		 * are small by default but can get huge. */
>> 		if ((xdr->flags & XDRBUF_SPARSE_PAGES) && *ppage =3D=3D
>> NULL) {
>> -			*ppage =3D alloc_page(GFP_ATOMIC);
>> +			*ppage =3D alloc_page(GFP_NOWAIT | =
__GFP_NOWARN);
>> 			if (unlikely(*ppage =3D=3D NULL)) {
>> 				if (copied =3D=3D 0)
>> 					copied =3D -ENOMEM;
>=20
> Hmm... Can't we make this GFP_KERNEL? I can't see that we're holding
> any locks here.

We're holding the transport send lock. Since this is an order 0 =
allocation
it's unlikely to fail even with a less aggressive request like NOWAIT.


> It does look like svc_udp_recvfrom() is wrapping the
> call to csum_partial_copy_to_xdr() in a local_bh_disable()/enable()
> pair, but is that actually needed? If so, for what?
>=20
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c
>> b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index 6c1fb27..b759b16 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -238,7 +238,7 @@ static bool rpcrdma_results_inline(struct
>> rpcrdma_xprt *r_xprt,
>> 		 */
>> 		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
>> 			if (!*ppages)
>> -				*ppages =3D alloc_page(GFP_ATOMIC);
>> +				*ppages =3D alloc_page(GFP_NOWAIT |
>> __GFP_NOWARN);
>> 			if (!*ppages)
>> 				return -ENOBUFS;
>> 		}
>>=20
>=20
> Cheers
>  Trond
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



