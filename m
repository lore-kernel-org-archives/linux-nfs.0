Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D20FC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 19:39:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 509A021873
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 19:39:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ToNy6e3o"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726802AbeLRTj3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 14:39:29 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:55100 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726912AbeLRTj3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2018 14:39:29 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBIJSceL048973;
        Tue, 18 Dec 2018 19:39:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=cedCCF/lR41sn7quEERGr271bxUBs2UhYJnQQwdeBxY=;
 b=ToNy6e3owTzACWu4C/EFQF4Zxg5hA438AkND6nj6JH+EGbwBN9MOWQFymaR3/4G/sIjQ
 Str6Z53s3cGYELIvfPvJtXJBPwXqOS09xMZHe+pkkgs1ikVErfJyLgBmRnTOSrE7Ot/p
 AyGiSo8eLJgUp0GU8VHmW2mTT1el5w1Kb+zvRL+bKFTBGV8XXlkitX12DBgv60RDF28x
 74xR036HWzON0uYIjCDnRtBmIfR35z2AP8DlE47Wi8P8klCj9IxCUZ/C3iZpcZK2ovHP
 jOqO0byReTndRC9zOWq9mnUTtVGpauPUO4DwUnTifMOIvJYB9zOAhvDjkp0mPiRP7Dup sg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2pcq4dwnfp-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 19:39:27 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBIJdQWT030410
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 19:39:26 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBIJdPkp000920;
        Tue, 18 Dec 2018 19:39:26 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 18 Dec 2018 11:39:25 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v4 07/30] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ca236b957f74998d0104d9865b2d65943850d5b4.camel@gmail.com>
Date:   Tue, 18 Dec 2018 14:39:24 -0500
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <66C22632-967A-40C9-B30C-F407920E4DBA@oracle.com>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
 <20181217163958.24133.16923.stgit@manet.1015granger.net>
 <ca236b957f74998d0104d9865b2d65943850d5b4.camel@gmail.com>
To:     Anna Schumaker <schumaker.anna@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9111 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812180162
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 18, 2018, at 2:35 PM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> Hi Chuck,
>=20
> On Mon, 2018-12-17 at 11:39 -0500, Chuck Lever wrote:
>> With certain combinations of krb5i/p, MR size, and r/wsize, I/O can
>> fail with EMSGSIZE. This is because the calculated value of
>> ri_max_segs (the max number of MRs per RPC) exceeded
>> RPCRDMA_MAX_HDR_SEGS, which caused Read or Write list encoding to
>> walk off the end of the transport header.
>>=20
>> Once that was addressed, the ro_maxpages result has to be corrected
>> to account for the number of MRs needed for Reply chunks, which is
>> 2 MRs smaller than a normal Read or Write chunk.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/fmr_ops.c   |    7 +++++--
>> net/sunrpc/xprtrdma/frwr_ops.c  |    7 +++++--
>> net/sunrpc/xprtrdma/transport.c |    6 ++++--
>> 3 files changed, 14 insertions(+), 6 deletions(-)
>>=20
>> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c =
b/net/sunrpc/xprtrdma/fmr_ops.c
>> index 7f5632c..78a0224 100644
>> --- a/net/sunrpc/xprtrdma/fmr_ops.c
>> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
>> @@ -176,7 +176,10 @@ enum {
>>=20
>> 	ia->ri_max_segs =3D max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS =
/
>> 				RPCRDMA_MAX_FMR_SGES);
>> -	ia->ri_max_segs +=3D 2;	/* segments for head and tail buffers */
>> +	/* Reply chunks require segments for head and tail buffers */
>> +	ia->ri_max_segs +=3D 2;
>> +	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
>> +		ia->ri_max_segs =3D RPCRDMA_MAX_HDR_SEGS;
>> 	return 0;
>> }
>>=20
>> @@ -186,7 +189,7 @@ enum {
>> fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
>> {
>> 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
>> -		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
>> +		     (ia->ri_max_segs - 2) * RPCRDMA_MAX_FMR_SGES);
>=20
> ia isn't defined in this function.  Should that be =
r_xprt->rx_ia.ri_max_segs
> instead?

Yeah. I compile-tested the tip of the branch, and so missed
this.

I'm going to have to send you a v5, so I'll fix this up in
the next post of this series.


> Thanks,
> Anna
>=20
>> }
>>=20
>> /* Use the ib_map_phys_fmr() verb to register a memory region
>> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c =
b/net/sunrpc/xprtrdma/frwr_ops.c
>> index 27222c0..f587e44 100644
>> --- a/net/sunrpc/xprtrdma/frwr_ops.c
>> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
>> @@ -244,7 +244,10 @@
>>=20
>> 	ia->ri_max_segs =3D max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS =
/
>> 				ia->ri_max_frwr_depth);
>> -	ia->ri_max_segs +=3D 2;	/* segments for head and tail buffers */
>> +	/* Reply chunks require segments for head and tail buffers */
>> +	ia->ri_max_segs +=3D 2;
>> +	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
>> +		ia->ri_max_segs =3D RPCRDMA_MAX_HDR_SEGS;
>> 	return 0;
>> }
>>=20
>> @@ -257,7 +260,7 @@
>> 	struct rpcrdma_ia *ia =3D &r_xprt->rx_ia;
>>=20
>> 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
>> -		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frwr_depth);
>> +		     (ia->ri_max_segs - 2) * ia->ri_max_frwr_depth);
>> }
>>=20
>> static void
>> diff --git a/net/sunrpc/xprtrdma/transport.c =
b/net/sunrpc/xprtrdma/transport.c
>> index a16296b..fbb14bf 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -704,8 +704,10 @@
>>  *	%-ENOTCONN if the caller should reconnect and call again
>>  *	%-EAGAIN if the caller should call again
>>  *	%-ENOBUFS if the caller should call again after a delay
>> - *	%-EIO if a permanent error occurred and the request was not
>> - *		sent. Do not try to send this message again.
>> + *	%-EMSGSIZE if encoding ran out of buffer space. The request
>> + *		was not sent. Do not try to send this message again.
>> + *	%-EIO if an I/O error occurred. The request was not sent.
>> + *		Do not try to send this message again.
>>  */
>> static int
>> xprt_rdma_send_request(struct rpc_rqst *rqst)

--
Chuck Lever



