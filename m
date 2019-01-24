Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5326C282C3
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 20:15:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 93705217D7
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 20:15:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ij/A1hyq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728340AbfAXUPd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 15:15:33 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:44168 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729560AbfAXTYV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2019 14:24:21 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0OJEt9s057595;
        Thu, 24 Jan 2019 19:24:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=2yR/Np1y0PqjousgqnkFSWIs+rZL3Xp/cl6fJbRP4dA=;
 b=Ij/A1hyqSjYmT5f9D2yFVREm+6Q3OBHT0Wgj5nYOE7uYf2Vu/te6aWVDirn8pKR3zSBd
 zUNwuOHXzijYdEhr9Wn/+6Pb0UMJhiYv410VMOGceCPAag9UFj+2d7uGUGDBbGCw8JWV
 496jl4sN5r5/R8fAA6pOMV/921OMOj2eZWUoZGTiojbaN4AUXucJ6Mmizq0rf9PIIHlS
 HDcnBBtscJdG841v7K520fgfHomCSQl1UW+S0s3GbWRsJg1waxJpZQOR2+fRnFRCk+M/
 PmKVT91N1A/gvzpey9Ak+K9JND/D2GpzJvc+eSRRHKZ97SapNwh7+enDFi7coo1UF3VE iw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2q3sdet0ax-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 24 Jan 2019 19:24:16 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0OJOEgQ009104
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 24 Jan 2019 19:24:15 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0OJOEYD032458;
        Thu, 24 Jan 2019 19:24:14 GMT
Received: from [10.3.0.116] (/8.25.222.2)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 24 Jan 2019 11:24:14 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0e2e8737-9ec7-f3b5-ff0c-f178330b826c@talpey.com>
Date:   Thu, 24 Jan 2019 11:24:13 -0800
Cc:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <52830D82-25DB-43ED-A480-0BEDA4555F98@oracle.com>
References: <164839c0-399e-d01b-dafc-5c873e650bdb@suse.com>
 <0e2e8737-9ec7-f3b5-ff0c-f178330b826c@talpey.com>
To:     Tom Talpey <tom@talpey.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9146 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901240131
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 24, 2019, at 8:04 AM, Tom Talpey <tom@talpey.com> wrote:
>=20
> On 1/23/2019 11:02 PM, Nicolas Morey-Chaisemartin wrote:
>> Make sure the device has at least 2 completion vectors before =
allocating to compvec#1
>=20
> I agree this fixes the bug, but wouldn't it be better to attempt
> to steer the affinity to chosen cores, rather than unconditionally
> using static values?

The goal for the moment is to create a patch that can be
backported to stable kernels with minimal fuss.


> At least make some determination that the
> device, and the memory that was just allocated, were pointed to
> slightly optimal NUMA node to handle its completions.
>=20
> Does the verbs API not support this? I thought that was discussed
> a while back.

It is true that spreading CQs across interrupt vectors is
desirable, but for various reasons, it has been difficult to
do it in a way that doesn't have bad behavior in some common
cases.

Sagi has constructed some infrastructure that works well for
ULPs that can create many transport instances, but we don't
yet have that ability for NFS.

I'm open to suggestions for a subsequent patch after Nicolas'
fix is merged.


> Tom.
>=20
>> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
>> Signed-off-by: Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com>
>> ---
>> Fixes since v1:
>>  - Use num_comp_vector instead online_cpus
>>  net/sunrpc/xprtrdma/verbs.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> diff --git a/net/sunrpc/xprtrdma/verbs.c =
b/net/sunrpc/xprtrdma/verbs.c
>> index b725911c0f3f..db913bcef984 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -546,7 +546,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct =
rpcrdma_ia *ia,
>>    	sendcq =3D ib_alloc_cq(ia->ri_device, NULL,
>>  			     ep->rep_attr.cap.max_send_wr + 1,
>> -			     1, IB_POLL_WORKQUEUE);
>> +			     ia->ri_device->num_comp_vectors > 1 ? 1 : =
0, IB_POLL_WORKQUEUE);
>>  	if (IS_ERR(sendcq)) {
>>  		rc =3D PTR_ERR(sendcq);
>>  		dprintk("RPC:       %s: failed to create send CQ: %i\n",

--
Chuck Lever



