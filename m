Return-Path: <SRS0=oebN=QK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0231EC169C4
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 16:49:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB64121773
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 16:49:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0dU0Ams3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727932AbfBCQtX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Feb 2019 11:49:23 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:36714 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726616AbfBCQtX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Feb 2019 11:49:23 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x13Gk7xx130108;
        Sun, 3 Feb 2019 16:49:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=8FiorOjf/+A+NT3Xamh0f+yqAGvQKKkunLU/dpAR4WA=;
 b=0dU0Ams3hOlrfV8aPyb8Vf4VOs7TOTn6ktN5uZzvN5AsdvC3YiPriqVnPBljycsR1YmV
 YJ84q/ZrrImGJSLRUm1xYZ+uMTiF+WzSFIyMB9jwDA8PZRsBwqBBh/d4UGBLGgJ3MCA7
 tPjEGrfsWkb2/61ioWM/mu/jV2HgXk999zWX5H3xV1y8qvY6tkyIK5kkWWDPm6DudMoE
 cy/CPlWTwJAsvf+x6i9Lu3ca/romQpXCKvDSGExNAyqc8Ai5/TEb9JpiulM/vWsl1EQk
 AbDuuYuTCcfVc2+d9FdOjXJBq89b4FLOAZmY1zq3OizYeBmnHJuuAriWsRzAsV1KouHH 7A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2qd97ej558-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 03 Feb 2019 16:49:16 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x13GnELp004469
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 3 Feb 2019 16:49:14 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x13GnBI6006297;
        Sun, 3 Feb 2019 16:49:14 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 03 Feb 2019 16:49:11 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fdcf717bf7ccd45b29bd26162223afc07ba4ed2a.camel@hammerspace.com>
Date:   Sun, 3 Feb 2019 11:49:10 -0500
Cc:     Tom Talpey <tom@talpey.com>, "simo@redhat.com" <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <B5C94F11-2434-4114-9827-F3731E1A11D0@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
 <1EDAC62A-8F55-400B-A473-BF2ED133C2CF@oracle.com>
 <fdcf717bf7ccd45b29bd26162223afc07ba4ed2a.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9156 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902030139
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 3, 2019, at 10:00 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Sat, 2019-02-02 at 17:46 -0500, Chuck Lever wrote:
>>> On Feb 1, 2019, at 9:30 PM, Tom Talpey <tom@talpey.com> wrote:
>>>=20
>>> On 2/1/2019 2:57 PM, Chuck Lever wrote:
>>>> Byte-swapping causes a CPU pipeline bubble on some processors.
>>>> When
>>>> a decoder is comparing an on-the-wire value for equality, byte-
>>>> swapping can be avoided by comparing it directly to a pre-byte-
>>>> swapped constant value.
>>>> The current set of pre-xdr'd constants is missing some common
>>>> values
>>>> used in the RPC header. Fill those out.
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> include/linux/sunrpc/auth_gss.h |    5 ++-
>>>> include/linux/sunrpc/xdr.h      |   66 ++++++++++++++++++++++++-
>>>> --------------
>>>> 2 files changed, 45 insertions(+), 26 deletions(-)
>>>> diff --git a/include/linux/sunrpc/auth_gss.h
>>>> b/include/linux/sunrpc/auth_gss.h
>>>> index 30427b7..adc4be2 100644
>>>> --- a/include/linux/sunrpc/auth_gss.h
>>>> +++ b/include/linux/sunrpc/auth_gss.h
>>>> @@ -19,7 +19,10 @@
>>>> #include <linux/sunrpc/svc.h>
>>>> #include <linux/sunrpc/gss_api.h>
>>>> -#define RPC_GSS_VERSION		1
>>>> +enum {
>>>> +	RPC_GSS_VERSION =3D 1,
>>>> +	rpc_gss_version =3D cpu_to_be32(RPC_GSS_VERSION)
>>>> +};
>>>>   #define MAXSEQ 0x80000000 /* maximum legal sequence number,
>>>> from rfc 2203 */
>>>> diff --git a/include/linux/sunrpc/xdr.h
>>>> b/include/linux/sunrpc/xdr.h
>>>> index 787939d..69161cb 100644
>>>> --- a/include/linux/sunrpc/xdr.h
>>>> +++ b/include/linux/sunrpc/xdr.h
>>>> @@ -17,6 +17,7 @@
>>>> #include <asm/byteorder.h>
>>>> #include <asm/unaligned.h>
>>>> #include <linux/scatterlist.h>
>>>> +#include <linux/sunrpc/msg_prot.h>
>>>>   struct bio_vec;
>>>> struct rpc_rqst;
>>>> @@ -79,31 +80,46 @@ struct xdr_buf {
>>>> 	buf->buflen =3D len;
>>>> }
>>>> -/*
>>>> - * pre-xdr'ed macros.
>>>> - */
>>>> -
>>>> -#define	xdr_zero	cpu_to_be32(0)
>>>> -#define	xdr_one		cpu_to_be32(1)
>>>> -#define	xdr_two		cpu_to_be32(2)
>>>> -
>>>> -#define	rpc_success		cpu_to_be32(RPC_SUCCESS)
>>>> -#define	rpc_prog_unavail	cpu_to_be32(RPC_PROG_UNAVAIL)
>>>> -#define	rpc_prog_mismatch	cpu_to_be32(RPC_PROG_MISMATCH)
>>>> -#define	rpc_proc_unavail	cpu_to_be32(RPC_PROC_UNAVAIL)
>>>> -#define	rpc_garbage_args	cpu_to_be32(RPC_GARBAGE_ARGS)
>>>> -#define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ER
>>>> R)
>>>> -#define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPL
>>>> Y)
>>>> -
>>>> -#define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
>>>> -#define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
>>>> -#define	rpc_autherr_rejectedcred
>>>> cpu_to_be32(RPC_AUTH_REJECTEDCRED)
>>>> -#define	rpc_autherr_badverf	cpu_to_be32(RPC_AUTH_BADVERF)
>>>> -#define	rpc_autherr_rejectedverf
>>>> cpu_to_be32(RPC_AUTH_REJECTEDVERF)
>>>> -#define	rpc_autherr_tooweak	cpu_to_be32(RPC_AUTH_TOOWEAK)
>>>> -#define	rpcsec_gsserr_credproblem	=
cpu_to_be32(RPCSEC_GSS_CR
>>>> EDPROBLEM)
>>>> -#define	rpcsec_gsserr_ctxproblem	=
cpu_to_be32(RPCSEC_GSS_CT
>>>> XPROBLEM)
>>>> -#define	rpc_autherr_oldseqnum	cpu_to_be32(101)
>>>> +enum xdr_be32_equivalents {
>>>> +	xdr_zero		=3D cpu_to_be32(0),
>>>> +	xdr_one			=3D cpu_to_be32(1),
>>>> +	xdr_two			=3D cpu_to_be32(2),
>>>=20
>>> It is clever to use an enum to pre-compute these values, but
>>=20
>> Perhaps not clever; it is a current Linux kernel coding
>> practice to use an enum in favor of a C macro for constants.
>=20
> Sure, but won't that confuse 'sparse' static checking? These constants
> will no longer appear as being big endian.

Agreed, that is not a desirable situation for these symbolic constants.


> Doesn't gcc's __builtin_bswap32() already compute the result at =
compile
> time when you feed it a constant value? AFAICS it is supposed to, =
which
> is why we use it directly in include/uapi/linux/swab.h instead of =
using
> a special cased __builtin_constant_p().

The return type of __builtin_bswap32 is uint32_t, not __be32.

I will stick with cpu_to_be32(), and simply add the missing constants.


--
Chuck Lever



