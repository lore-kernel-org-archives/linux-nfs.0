Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96EDFC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 22:24:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44C952086B
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 22:24:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="X33qdYoI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44C952086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726327AbeK1JXa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 04:23:30 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:39878 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726286AbeK1JX3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 04:23:29 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wARME5mb160079;
        Tue, 27 Nov 2018 22:24:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=b8A4EHKGCDpDNTpzOTo4pd6/zTSSDo5PX/nIF1gMK50=;
 b=X33qdYoIJHWE+8JrvfdrnYMo/b01gwDAaXPPtcrv1S5L5phQSPZJxzwSzt6DT6M56OUa
 Gw2zr+7I/YeyjBhA2PcCieKdLfneZH1xPbDwci6ttX8zGFzd/klKFueYShWKf/alZR5u
 TyzuHPMDFG/K8OfzjGzdQUdfmhhM/wMtv7OzEMjJZT9JROFpVBaUZBnL+Foe0FKmSRkK
 KTLLajbGWgHvlCFau6ZESlShg9JSeO52n2R/rtUtxTUnr/dcemdH+VShlSbxdov8EVII
 WuRC4NXUASHcddTnMOOklc4xpsdBYx1eVP8fOAwrbQuaxJx5s8x4BOH0fT1EReaPdZ6w Aw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2nxy9r6vnj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 27 Nov 2018 22:24:06 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wARMO0Ga027049
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 27 Nov 2018 22:24:00 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wARMO0m5015215;
        Tue, 27 Nov 2018 22:24:00 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 27 Nov 2018 14:24:00 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1] svcrdma: Optimize the logic that selects the R_key to
 invalidate
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <45f70f31-997b-ab1e-9430-57f2e0d78318@talpey.com>
Date:   Tue, 27 Nov 2018 17:23:58 -0500
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <79BDA67D-4B6E-423F-BAF3-ADE5E703B5BC@oracle.com>
References: <20181127161016.6997.69002.stgit@klimt.1015granger.net>
 <14c5a1e8-115b-a58b-7c65-4e207caf3d33@talpey.com>
 <0E1C5F18-C0E8-43D2-AF21-B6DCC84E302C@oracle.com>
 <45f70f31-997b-ab1e-9430-57f2e0d78318@talpey.com>
To:     Tom Talpey <tom@talpey.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9090 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811270186
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 27, 2018, at 4:30 PM, Tom Talpey <tom@talpey.com> wrote:
>=20
> On 11/27/2018 4:21 PM, Chuck Lever wrote:
>>> On Nov 27, 2018, at 4:16 PM, Tom Talpey <tom@talpey.com> wrote:
>>>=20
>>> On 11/27/2018 11:11 AM, Chuck Lever wrote:
>>>> o Select the R_key to invalidate while the CPU cache still contains
>>>>   the received RPC Call transport header, rather than waiting until
>>>>   we're about to send the RPC Reply.
>>>> o Choose Send With Invalidate if there is exactly one distinct =
R_key
>>>>   in the received transport header. If there's more than one, the
>>>>   client will have to perform local invalidation after it has
>>>>   already waited for remote invalidation.
>>>=20
>>> What's the reason for remote-invalidating only if exactly one
>>> region is targeted? It seems valuable to save the client the work,
>>> no matter how many regions are used.
>> Because remote invalidation delays the Receive completion.
>=20
> Well yes, but the invalidations have to happen before the reply is
> processed, and remote invalidation saves a local work request plus
> its completion.

That is true only if remote invalidation can knock down all the
R_keys for that RPC. If there's more than one R_key for that RPC,
a local invalidation is needed anyway, and there's no savings but
rather there is a cost of the extra latency of waiting twice.

A couple of details to note:
- remote invalidation is only available with FRWR, which
  invalidates asynchronously
- a smart FRWR client implementation will post a chain of LOCAL
  INV WRs, then wait for the last one to signal completion. That's
  just one doorbell, one interrupt, and one context switch no
  matter how many LOCAL INV WRs are needed.

So if the client still has to do even one local invalidation, it's
not worth the trouble to remotely invalidate.


>> If the client has to do local invalidation as well, that
>> means two delays, and the client already has to do a context
>> switch for the local invalidation.
>=20
> Have you measured the difference?

Yes, as reported in the patch description. Perhaps I can include
some interesting iozone results.


>> Also, some cards are not especially efficient at remote
>> invalidation. If the server requests it less frequently (for
>> example, when it's not actually going to be beneficial),
>> that's good for those cards.
>=20
> Hmm. I'd say get a better card and don't hobble the rpcrdma
> protocol design. Maybe that's just me.

This behavior seems to be a typical feature of most recent hardware.
I suspect there's some locking of the hardware Send queue to handle
RI that contends with actual posted WRs from the host.

With cards that have a shallow FR depth, multiple MRs/R_keys are
required to register a single 1MB NFS READ or WRITE. Here's where
squelching remote invalidation really pays off.


This is an implementation change, not a protocol change, btw. The
current RPC-over-RDMA v1 protocol extension is Responder's Choice,
which means the server gets to pick an R_key or decide not to
invalidate remotely at all. I'm simply optimizing that choice.


> I think it would be best to capture some or all of this
> explanation in the commit message, in any case.

You mean you want my patch description to explain _why_ ? ;-)


> Tom.
>=20
>=20
>>> Put another way, why the change?
>>>=20
>>> Tom.
>>>=20
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> Hi-
>>>> Please consider this NFS server-side patch for v4.21.
>>>>  include/linux/sunrpc/svc_rdma.h         |    1
>>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   63 =
+++++++++++++++++++++++++++++++
>>>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   53 =
++++++--------------------
>>>>  3 files changed, 77 insertions(+), 40 deletions(-)
>>>> diff --git a/include/linux/sunrpc/svc_rdma.h =
b/include/linux/sunrpc/svc_rdma.h
>>>> index e6e2691..7e22681 100644
>>>> --- a/include/linux/sunrpc/svc_rdma.h
>>>> +++ b/include/linux/sunrpc/svc_rdma.h
>>>> @@ -135,6 +135,7 @@ struct svc_rdma_recv_ctxt {
>>>>  	u32			rc_byte_len;
>>>>  	unsigned int		rc_page_count;
>>>>  	unsigned int		rc_hdr_count;
>>>> +	u32			rc_inv_rkey;
>>>>  	struct page		*rc_pages[RPCSVC_MAXPAGES];
>>>>  };
>>>>  diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c =
b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> index b24d5b8..828b149 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> @@ -485,6 +485,68 @@ static __be32 *xdr_check_reply_chunk(__be32 =
*p, const __be32 *end)
>>>>  	return p;
>>>>  }
>>>>  +/* RPC-over-RDMA Version One private extension: Remote =
Invalidation.
>>>> + * Responder's choice: requester signals it can handle Send With
>>>> + * Invalidate, and responder chooses one R_key to invalidate.
>>>> + *
>>>> + * If there is exactly one distinct R_key in the received =
transport
>>>> + * header, set rc_inv_rkey to that R_key. Otherwise, set it to =
zero.
>>>> + *
>>>> + * Perform this operation while the received transport header is
>>>> + * still in the CPU cache.
>>>> + */
>>>> +static void svc_rdma_get_inv_rkey(struct svcxprt_rdma *rdma,
>>>> +				  struct svc_rdma_recv_ctxt *ctxt)
>>>> +{
>>>> +	__be32 inv_rkey, *p;
>>>> +	u32 i, segcount;
>>>> +
>>>> +	ctxt->rc_inv_rkey =3D 0;
>>>> +
>>>> +	if (!rdma->sc_snd_w_inv)
>>>> +		return;
>>>> +
>>>> +	inv_rkey =3D xdr_zero;
>>>> +	p =3D ctxt->rc_recv_buf;
>>>> +	p +=3D rpcrdma_fixed_maxsz;
>>>> +
>>>> +	/* Read list */
>>>> +	while (*p++ !=3D xdr_zero) {
>>>> +		p++;	/* position */
>>>> +		if (inv_rkey =3D=3D xdr_zero)
>>>> +			inv_rkey =3D *p;
>>>> +		else if (inv_rkey !=3D *p)
>>>> +			return;
>>>> +		p +=3D 4;
>>>> +	}
>>>> +
>>>> +	/* Write list */
>>>> +	while (*p++ !=3D xdr_zero) {
>>>> +		segcount =3D be32_to_cpup(p++);
>>>> +		for (i =3D 0; i < segcount; i++) {
>>>> +			if (inv_rkey =3D=3D xdr_zero)
>>>> +				inv_rkey =3D *p;
>>>> +			else if (inv_rkey !=3D *p)
>>>> +				return;
>>>> +			p +=3D 4;
>>>> +		}
>>>> +	}
>>>> +
>>>> +	/* Reply chunk */
>>>> +	if (*p++ !=3D xdr_zero) {
>>>> +		segcount =3D be32_to_cpup(p++);
>>>> +		for (i =3D 0; i < segcount; i++) {
>>>> +			if (inv_rkey =3D=3D xdr_zero)
>>>> +				inv_rkey =3D *p;
>>>> +			else if (inv_rkey !=3D *p)
>>>> +				return;
>>>> +			p +=3D 4;
>>>> +		}
>>>> +	}
>>>> +
>>>> +	ctxt->rc_inv_rkey =3D be32_to_cpu(inv_rkey);
>>>> +}
>>>> +
>>>>  /* On entry, xdr->head[0].iov_base points to first byte in the
>>>>   * RPC-over-RDMA header.
>>>>   *
>>>> @@ -746,6 +808,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>>>>  		svc_rdma_recv_ctxt_put(rdma_xprt, ctxt);
>>>>  		return ret;
>>>>  	}
>>>> +	svc_rdma_get_inv_rkey(rdma_xprt, ctxt);
>>>>    	p +=3D rpcrdma_fixed_maxsz;
>>>>  	if (*p !=3D xdr_zero)
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c =
b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> index 8602a5f..d48bc6d 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> @@ -484,32 +484,6 @@ static void svc_rdma_get_write_arrays(__be32 =
*rdma_argp,
>>>>  		*reply =3D NULL;
>>>>  }
>>>>  -/* RPC-over-RDMA Version One private extension: Remote =
Invalidation.
>>>> - * Responder's choice: requester signals it can handle Send With
>>>> - * Invalidate, and responder chooses one rkey to invalidate.
>>>> - *
>>>> - * Find a candidate rkey to invalidate when sending a reply.  =
Picks the
>>>> - * first R_key it finds in the chunk lists.
>>>> - *
>>>> - * Returns zero if RPC's chunk lists are empty.
>>>> - */
>>>> -static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
>>>> -				 __be32 *wr_lst, __be32 *rp_ch)
>>>> -{
>>>> -	__be32 *p;
>>>> -
>>>> -	p =3D rdma_argp + rpcrdma_fixed_maxsz;
>>>> -	if (*p !=3D xdr_zero)
>>>> -		p +=3D 2;
>>>> -	else if (wr_lst && be32_to_cpup(wr_lst + 1))
>>>> -		p =3D wr_lst + 2;
>>>> -	else if (rp_ch && be32_to_cpup(rp_ch + 1))
>>>> -		p =3D rp_ch + 2;
>>>> -	else
>>>> -		return 0;
>>>> -	return be32_to_cpup(p);
>>>> -}
>>>> -
>>>>  static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
>>>>  				 struct svc_rdma_send_ctxt *ctxt,
>>>>  				 struct page *page,
>>>> @@ -672,7 +646,7 @@ static void svc_rdma_save_io_pages(struct =
svc_rqst *rqstp,
>>>>   *
>>>>   * RDMA Send is the last step of transmitting an RPC reply. Pages
>>>>   * involved in the earlier RDMA Writes are here transferred out
>>>> - * of the rqstp and into the ctxt's page array. These pages are
>>>> + * of the rqstp and into the sctxt's page array. These pages are
>>>>   * DMA unmapped by each Write completion, but the subsequent Send
>>>>   * completion finally releases these pages.
>>>>   *
>>>> @@ -680,32 +654,31 @@ static void svc_rdma_save_io_pages(struct =
svc_rqst *rqstp,
>>>>   * - The Reply's transport header will never be larger than a =
page.
>>>>   */
>>>>  static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
>>>> -				   struct svc_rdma_send_ctxt *ctxt,
>>>> -				   __be32 *rdma_argp,
>>>> +				   struct svc_rdma_send_ctxt *sctxt,
>>>> +				   struct svc_rdma_recv_ctxt *rctxt,
>>>>  				   struct svc_rqst *rqstp,
>>>>  				   __be32 *wr_lst, __be32 *rp_ch)
>>>>  {
>>>>  	int ret;
>>>>    	if (!rp_ch) {
>>>> -		ret =3D svc_rdma_map_reply_msg(rdma, ctxt,
>>>> +		ret =3D svc_rdma_map_reply_msg(rdma, sctxt,
>>>>  					     &rqstp->rq_res, wr_lst);
>>>>  		if (ret < 0)
>>>>  			return ret;
>>>>  	}
>>>>  -	svc_rdma_save_io_pages(rqstp, ctxt);
>>>> +	svc_rdma_save_io_pages(rqstp, sctxt);
>>>>  -	ctxt->sc_send_wr.opcode =3D IB_WR_SEND;
>>>> -	if (rdma->sc_snd_w_inv) {
>>>> -		ctxt->sc_send_wr.ex.invalidate_rkey =3D
>>>> -			svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
>>>> -		if (ctxt->sc_send_wr.ex.invalidate_rkey)
>>>> -			ctxt->sc_send_wr.opcode =3D IB_WR_SEND_WITH_INV;
>>>> +	if (rctxt->rc_inv_rkey) {
>>>> +		sctxt->sc_send_wr.opcode =3D IB_WR_SEND_WITH_INV;
>>>> +		sctxt->sc_send_wr.ex.invalidate_rkey =3D =
rctxt->rc_inv_rkey;
>>>> +	} else {
>>>> +		sctxt->sc_send_wr.opcode =3D IB_WR_SEND;
>>>>  	}
>>>>  	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
>>>> -		ctxt->sc_send_wr.num_sge);
>>>> -	return svc_rdma_send(rdma, &ctxt->sc_send_wr);
>>>> +		sctxt->sc_send_wr.num_sge);
>>>> +	return svc_rdma_send(rdma, &sctxt->sc_send_wr);
>>>>  }
>>>>    /* Given the client-provided Write and Reply chunks, the server =
was not
>>>> @@ -809,7 +782,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>>>>  	}
>>>>    	svc_rdma_sync_reply_hdr(rdma, sctxt, =
svc_rdma_reply_hdr_len(rdma_resp));
>>>> -	ret =3D svc_rdma_send_reply_msg(rdma, sctxt, rdma_argp, rqstp,
>>>> +	ret =3D svc_rdma_send_reply_msg(rdma, sctxt, rctxt, rqstp,
>>>>  				      wr_lst, rp_ch);
>>>>  	if (ret < 0)
>>>>  		goto err1;
>> --
>> Chuck Lever

--
Chuck Lever



