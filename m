Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B02C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:36:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1CBF2146D
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:36:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Jdznf/il"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1CBF2146D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726028AbeLAHrT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:47:19 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:39862 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725847AbeLAHrT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:47:19 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAUKYaW6085505;
        Fri, 30 Nov 2018 20:36:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=FjPj+9IreXQA7lB5bi4xcmGwYACEnxqILm1mPFIcK0g=;
 b=Jdznf/ilvaerlHjCQyzm+oUyYVFSdSfjZm7wcGczIDJUZvzXZ6x5JxY12kPTc28WxyW0
 AK98vAmlkUQq7fPP991LJoUs/AYAjx2SUT+4FHXXyIFWPqchpK7arD1t7AIsLe2Bmddo
 NxEalLLcwwhitU6F+v+nSP8uI8HcYHpmiSPtm6h+Y2JtrW4kYwXZBSAm6BnegVciV7Lg
 rDQqZiIFN5K5hYlUI048H2YIdnbS78y2+OTsWR6uA/TwYrlhBptClQZXMxDHlcUWGWlH
 wkAqEPJRTNbU4dBXEdjUVKGA1fPmXDerRdUpDW3TbAgYHd01uPWZOQNzjnCo7873Ua7H 6g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2120.oracle.com with ESMTP id 2nxxkr09wb-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 20:36:45 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAUKaeq2022868
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 20:36:40 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wAUKacsM018389;
        Fri, 30 Nov 2018 20:36:39 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 12:36:38 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: kerberos with v4.20-rc4 heads up
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <d1f07dd56fff6ee1888ca51b1b263825c3a9fd04.camel@hammerspace.com>
Date:   Fri, 30 Nov 2018 15:36:37 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <AD8370DF-74BF-45D5-A9AD-41FBE2794779@oracle.com>
References: <028A9DC5-4136-413C-8A79-F32F997A8AB1@oracle.com>
 <d1f07dd56fff6ee1888ca51b1b263825c3a9fd04.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300175
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 1:40 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Fri, 2018-11-30 at 12:08 -0500, Chuck Lever wrote:
>> Hi-
>>=20
>> I'm testing krb5/krb5i/krb5p with stock v4.20-rc4 and NFS/TCP.
>> The workload is synthetic:
>>=20
>> /home/cel/bin/iozone -M -+u -i0 -i1 -s1g -r8k -t16 -c
>>=20
>> The client is a 12-core Xeon system.
>>=20
>>=20
>> I'm seeing all kinds of symptoms:
>>=20
>> - memory leaks: bvec and enc_pages are leaking
>>=20
>> - EBADMSG is reported to user space
>>=20
>> - data corruption
>>=20
>> - connect deadlocks resulting in a mount hang
>>=20
>> - invalid soft IRQ receive buffer warnings
>>=20
>=20
> Does the following patch help?

With this patch applied I am able to reproduce at least the
soft IRQ warnings and the connect deadlock. There is possibly
more than one bug.

I've found and fixed the enc_pages leak. Patch forthcoming.


> 8<----------------------------------------------
> =46rom 8ff4cd9f0f6912e14f657371b6b7eecf6d2091ee Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Fri, 30 Nov 2018 12:48:47 -0500
> Subject: [PATCH] SUNRPC: call_connect_status() must handle tasks that =
got
> transmitted
>=20
> If a task failed to get the write lock in the call to xprt_connect(), =
then
> it will be queued on xprt->sending. In that case, it is possible for =
it
> to get transmitted before the call to call_connect_status(), in which
> case it needs to be handled by call_transmit_status() instead.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index ae3b8145da35..e35d642558e7 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1915,6 +1915,13 @@ call_connect_status(struct rpc_task *task)
> 	struct rpc_clnt *clnt =3D task->tk_client;
> 	int status =3D task->tk_status;
>=20
> +	/* Check if the task was already transmitted */
> +	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
> +		xprt_end_transmit(task);
> +		task->tk_action =3D call_transmit_status;
> +		return;
> +	}
> +
> 	dprint_status(task);
>=20
> 	trace_rpc_connect_status(task);
> --=20
> 2.19.2
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



