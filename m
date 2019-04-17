Return-Path: <SRS0=8+CZ=ST=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E961C282DA
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 19:50:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 47E97205C9
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 19:50:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ivTyudvb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729779AbfDQTuy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Apr 2019 15:50:54 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:55242 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729291AbfDQTuy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Apr 2019 15:50:54 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJmxD6020750;
        Wed, 17 Apr 2019 19:50:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=xHh1XCCcsqRN6jAQY9CQp7zW5i2v3TqrPxyXZXxMxhI=;
 b=ivTyudvbO4Ntg4d1sb3B9R4a9aF/w5wEgWSe89XOd1gkH2rdzi0b0q7BIoKS2HQCvhI9
 KW4G4VArBiXN3LNKU/LmemtRuMm4KeF4jAdVspmJEN2YrjzgAE9QH9qKTeTsUstXsvDS
 HlDJnJ9OcwDjFXjLI7OvndlA/HiXR+yrvNOUu2CHMYKgu4ZCqQc9sxHaD/OHm4Hstino
 f6ieH6SL9C0JM9YXU42LJiK9bAc7UMDcYuX7yHAaij5Bm0R7hN+j1+7kv96orZx9GW38
 VlWtEW4pqDbNpk3d3ZNvzcZCQIozONfnZ3D1ner+3w+aMOppIo3a0oJFemeON0swXapu kw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
        by aserp2130.oracle.com with ESMTP id 2ru59dd4jj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 17 Apr 2019 19:50:51 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
        by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJoUuL027453;
        Wed, 17 Apr 2019 19:50:50 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userp3020.oracle.com with ESMTP id 2rubq74ra9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 17 Apr 2019 19:50:50 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3HJokvn006212;
        Wed, 17 Apr 2019 19:50:49 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 17 Apr 2019 12:50:45 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: error=Invalid slot
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
Date:   Wed, 17 Apr 2019 15:50:45 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E4E29768-915F-4DC9-84C9-E0BA1C106CEC@oracle.com>
References: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
 <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=880
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170128
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=906 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170128
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 15, 2019, at 12:05 PM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> Hi Chuck,
>=20
>=20
> On Mon, 2019-04-15 at 11:04 -0400, Chuck Lever wrote:
>> Just happened again. Any thoughts about where I should start looking?
>>=20
>> Mon Apr 15 11:01:40 EDT 2019
>> 4k100test: (g=3D0): rw=3Drandread, bs=3D(R) 4096B-4096B, (W) =
4096B-4096B,
>> (T) 4096B-4096B, ioengine=3Dlibaio, iodepth=3D1024
>> ...
>> fio-3.1
>> Starting 12 processes
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> fio: io_u error on file 4k100test.7.0: Invalid slot: read
>> offset=3D938229760, buflen=3D4096
>=20
> Does the following patch fix the race?
>=20
> 8<--------------------------------------
> =46rom 4c8759eafad9bb7ea2626a53296e30618aeefcc7 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Mon, 15 Apr 2019 11:54:13 -0400
> Subject: [PATCH] SUNRPC: Ignore queue transmission errors on =
successful
> transmission
>=20
> If a request transmission fails due to write space or slot =
unavailability
> errors, but the queued task then gets transmitted before it has time =
to
> process the error in call_transmit_status() or =
call_bc_transmit_status(),
> we need to suppress the transmission error code to prevent it from =
leaking
> out of the RPC layer.
>=20
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 7 +++++--
> 1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index fa900bb44cd5..369a2648dafc 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2101,8 +2101,8 @@ call_transmit_status(struct rpc_task *task)
> 	 * test first.
> 	 */
> 	if (rpc_task_transmitted(task)) {
> -		if (task->tk_status =3D=3D 0)
> -			xprt_request_wait_receive(task);
> +		task->tk_status =3D 0;
> +		xprt_request_wait_receive(task);
> 		return;
> 	}
>=20
> @@ -2187,6 +2187,9 @@ call_bc_transmit_status(struct rpc_task *task)
> {
> 	struct rpc_rqst *req =3D task->tk_rqstp;
>=20
> +	if (rpc_task_transmitted(task))
> +		task->tk_status =3D 0;
> +
> 	dprint_status(task);
>=20
> 	switch (task->tk_status) {
> --=20
> 2.20.1
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

I haven't been able to reproduce the problem.

Tested-by: Chuck Lever <chuck.lever@oracle.com>


--
Chuck Lever



