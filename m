Return-Path: <SRS0=aDhS=QJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10C23C282D7
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 22:46:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA5E920855
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 22:46:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="yQDRYCgP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726825AbfBBWqz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 2 Feb 2019 17:46:55 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:36606 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726821AbfBBWqz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2019 17:46:55 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x12Mkoq3058785;
        Sat, 2 Feb 2019 22:46:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=fZ1CK+nQbCAeJmR26Gnr9oTkefOnklc2lIoiwF1Agk0=;
 b=yQDRYCgPJ1o8vEOEN23GRfMxH/o01g6Ew9IXhSMOknPO0eaL59lutACYx/G+CcU1DNqb
 wh3VDGEKQliHen8EQNKpc2+oZH/AGIZaG3XnOeHzbQTNb4qbkwBXFtOgIWS0gQVX7+nu
 z3uMm7FVlmLoTBgHxXr3Rt7rqUT+WdMMbBxtfGEd5nRcuIBi4gP/G8//AKuN1DrhYBoM
 TNAruNHJ07//Yg05GrkRCPJW06RbOMpuI6BQ6Dvr+Y4yg+Vgzs8wOozzjUbRfOxS2Va4
 bQ9TYkVDWsA812AU/VJF5d0dpLC696gWhicjDsZ5U2G0WNR3vKESGx4udiCMBsfUEtT3 3A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2qd9ar0ssy-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 02 Feb 2019 22:46:50 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x12Mkm47000904
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 2 Feb 2019 22:46:49 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x12MkmDF014619;
        Sat, 2 Feb 2019 22:46:48 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 02 Feb 2019 22:46:47 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
Date:   Sat, 2 Feb 2019 17:46:46 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <1EDAC62A-8F55-400B-A473-BF2ED133C2CF@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
To:     Tom Talpey <tom@talpey.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9155 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902020189
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 1, 2019, at 9:30 PM, Tom Talpey <tom@talpey.com> wrote:
>=20
> On 2/1/2019 2:57 PM, Chuck Lever wrote:
>> Byte-swapping causes a CPU pipeline bubble on some processors. When
>> a decoder is comparing an on-the-wire value for equality, byte-
>> swapping can be avoided by comparing it directly to a pre-byte-
>> swapped constant value.
>> The current set of pre-xdr'd constants is missing some common values
>> used in the RPC header. Fill those out.
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  include/linux/sunrpc/auth_gss.h |    5 ++-
>>  include/linux/sunrpc/xdr.h      |   66 =
++++++++++++++++++++++++---------------
>>  2 files changed, 45 insertions(+), 26 deletions(-)
>> diff --git a/include/linux/sunrpc/auth_gss.h =
b/include/linux/sunrpc/auth_gss.h
>> index 30427b7..adc4be2 100644
>> --- a/include/linux/sunrpc/auth_gss.h
>> +++ b/include/linux/sunrpc/auth_gss.h
>> @@ -19,7 +19,10 @@
>>  #include <linux/sunrpc/svc.h>
>>  #include <linux/sunrpc/gss_api.h>
>>  -#define RPC_GSS_VERSION		1
>> +enum {
>> +	RPC_GSS_VERSION =3D 1,
>> +	rpc_gss_version =3D cpu_to_be32(RPC_GSS_VERSION)
>> +};
>>    #define MAXSEQ 0x80000000 /* maximum legal sequence number, from =
rfc 2203 */
>>  diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
>> index 787939d..69161cb 100644
>> --- a/include/linux/sunrpc/xdr.h
>> +++ b/include/linux/sunrpc/xdr.h
>> @@ -17,6 +17,7 @@
>>  #include <asm/byteorder.h>
>>  #include <asm/unaligned.h>
>>  #include <linux/scatterlist.h>
>> +#include <linux/sunrpc/msg_prot.h>
>>    struct bio_vec;
>>  struct rpc_rqst;
>> @@ -79,31 +80,46 @@ struct xdr_buf {
>>  	buf->buflen =3D len;
>>  }
>>  -/*
>> - * pre-xdr'ed macros.
>> - */
>> -
>> -#define	xdr_zero	cpu_to_be32(0)
>> -#define	xdr_one		cpu_to_be32(1)
>> -#define	xdr_two		cpu_to_be32(2)
>> -
>> -#define	rpc_success		cpu_to_be32(RPC_SUCCESS)
>> -#define	rpc_prog_unavail	cpu_to_be32(RPC_PROG_UNAVAIL)
>> -#define	rpc_prog_mismatch	cpu_to_be32(RPC_PROG_MISMATCH)
>> -#define	rpc_proc_unavail	cpu_to_be32(RPC_PROC_UNAVAIL)
>> -#define	rpc_garbage_args	cpu_to_be32(RPC_GARBAGE_ARGS)
>> -#define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ERR)
>> -#define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPLY)
>> -
>> -#define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
>> -#define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
>> -#define	rpc_autherr_rejectedcred =
cpu_to_be32(RPC_AUTH_REJECTEDCRED)
>> -#define	rpc_autherr_badverf	cpu_to_be32(RPC_AUTH_BADVERF)
>> -#define	rpc_autherr_rejectedverf =
cpu_to_be32(RPC_AUTH_REJECTEDVERF)
>> -#define	rpc_autherr_tooweak	cpu_to_be32(RPC_AUTH_TOOWEAK)
>> -#define	rpcsec_gsserr_credproblem	=
cpu_to_be32(RPCSEC_GSS_CREDPROBLEM)
>> -#define	rpcsec_gsserr_ctxproblem	=
cpu_to_be32(RPCSEC_GSS_CTXPROBLEM)
>> -#define	rpc_autherr_oldseqnum	cpu_to_be32(101)
>> +enum xdr_be32_equivalents {
>> +	xdr_zero		=3D cpu_to_be32(0),
>> +	xdr_one			=3D cpu_to_be32(1),
>> +	xdr_two			=3D cpu_to_be32(2),
>=20
> It is clever to use an enum to pre-compute these values, but

Perhaps not clever; it is a current Linux kernel coding
practice to use an enum in favor of a C macro for constants.


> it becomes a concern that the type (and size) of an enum may
> not be the same as values they may be compared to.

Indeed, an enum is a variably-sized signed integer, IIUC.


> Commonly, code may compare them to int32, uint32, etc. What
> guarantees are there that such comparisons will yield the
> appropriate result, especially if a < or > test is performed?

I believe for the purposes of assignment and equality comparison
the compiler will promote these to the size and sign of the
variable. We would never perform a greater or less than test with
these values, obviously.

However, they probably should have an obvious and well-defined
type, and I should leave the already-defined macros as they
are.


> Tom.
>=20
>> +
>> +	rpc_version		=3D cpu_to_be32(RPC_VERSION),
>> +
>> +	rpc_auth_null		=3D cpu_to_be32(RPC_AUTH_NULL),
>> +	rpc_auth_unix		=3D cpu_to_be32(RPC_AUTH_UNIX),
>> +	rpc_auth_short		=3D cpu_to_be32(RPC_AUTH_SHORT),
>> +	rpc_auth_des		=3D cpu_to_be32(RPC_AUTH_DES),
>> +	rpc_auth_krb		=3D cpu_to_be32(RPC_AUTH_KRB),
>> +	rpc_auth_gss		=3D cpu_to_be32(RPC_AUTH_GSS),
>> +
>> +	rpc_call		=3D cpu_to_be32(RPC_CALL),
>> +	rpc_reply		=3D cpu_to_be32(RPC_REPLY),
>> +
>> +	rpc_msg_accepted	=3D cpu_to_be32(RPC_MSG_ACCEPTED),
>> +	rpc_msg_denied		=3D cpu_to_be32(RPC_MSG_DENIED),
>> +
>> +	rpc_success		=3D cpu_to_be32(RPC_SUCCESS),
>> +	rpc_prog_unavail	=3D cpu_to_be32(RPC_PROG_UNAVAIL),
>> +	rpc_prog_mismatch	=3D cpu_to_be32(RPC_PROG_MISMATCH),
>> +	rpc_proc_unavail	=3D cpu_to_be32(RPC_PROC_UNAVAIL),
>> +	rpc_garbage_args	=3D cpu_to_be32(RPC_GARBAGE_ARGS),
>> +	rpc_system_err		=3D cpu_to_be32(RPC_SYSTEM_ERR),
>> +	rpc_drop_reply		=3D cpu_to_be32(RPC_DROP_REPLY),
>> +
>> +	rpc_mismatch		=3D cpu_to_be32(RPC_MISMATCH),
>> +	rpc_auth_error		=3D cpu_to_be32(RPC_AUTH_ERROR),
>> +
>> +	rpc_auth_ok		=3D cpu_to_be32(RPC_AUTH_OK),
>> +	rpc_autherr_badcred	=3D cpu_to_be32(RPC_AUTH_BADCRED),
>> +	rpc_autherr_rejectedcred =3D cpu_to_be32(RPC_AUTH_REJECTEDCRED),
>> +	rpc_autherr_badverf	=3D cpu_to_be32(RPC_AUTH_BADVERF),
>> +	rpc_autherr_rejectedverf =3D cpu_to_be32(RPC_AUTH_REJECTEDVERF),
>> +	rpc_autherr_tooweak	=3D cpu_to_be32(RPC_AUTH_TOOWEAK),
>> +	rpcsec_gsserr_credproblem =3D =
cpu_to_be32(RPCSEC_GSS_CREDPROBLEM),
>> +	rpcsec_gsserr_ctxproblem =3D cpu_to_be32(RPCSEC_GSS_CTXPROBLEM),
>> +};
>>    /*
>>   * Miscellaneous XDR helper functions

--
Chuck Lever



