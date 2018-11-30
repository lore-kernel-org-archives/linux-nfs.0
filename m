Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E225C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:31:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10EFC20863
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:31:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4eoYq3Ek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10EFC20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726841AbeLAJmY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:42:24 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:37926 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726825AbeLAJmY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:42:24 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAUMT8hp166640;
        Fri, 30 Nov 2018 22:31:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=OLqBepnZDl/ITpO3qxl7TthhefxsOFCrDvmpDaT3dIE=;
 b=4eoYq3EkoVecfouM5Rk9WlYV8YgCmjC7FHeCOpuEao+41EqqNVQvDMsAmLNhh4+2sOAD
 oKvB+7Wa+J3rwQ2/V72abF16sXMacBUC8H3foIfCrCckzEHpdzOBTwdh0LWSb09uu4p3
 WLBhRQKb4tpypjQjmfk5zUBy73NXoH1h9tf4ipc1rAvtlb4v7KJZkjLnHEqPP7m/OHh6
 x7JJlsR4WsfdA+WbOkC963YEc4AokepgmGO/aXCvIWi50ttXZy6nHtfKTCxSdep6Ut1c
 4vYKT+MEoBlEVSj7bkiwEuj5LEU4gWKkJpLVwWK2EoGSbDg/nNH5ed0H338zfIwEZWWd XQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2120.oracle.com with ESMTP id 2nxxkr0p1b-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 22:31:32 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAUMVWCb003049
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 22:31:32 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAUMVWAu031052;
        Fri, 30 Nov 2018 22:31:32 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 14:31:32 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <499a31eab46be4e0ad0ec13e7ae693cd133a0444.camel@hammerspace.com>
Date:   Fri, 30 Nov 2018 17:31:31 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <5F42A4A1-59EA-4467-8FC1-40E1872351B8@oracle.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
 <20181130215555.91107-2-trond.myklebust@hammerspace.com>
 <20181130215555.91107-3-trond.myklebust@hammerspace.com>
 <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
 <545d13619ffe92a69097f8f68fc36df85944cac2.camel@hammerspace.com>
 <7B7D615F-8A5B-4EBD-96DC-FDDA9DC35DD9@oracle.com>
 <499a31eab46be4e0ad0ec13e7ae693cd133a0444.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=480
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300190
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 5:30 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Fri, 2018-11-30 at 17:23 -0500, Chuck Lever wrote:
>>> On Nov 30, 2018, at 5:18 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Fri, 2018-11-30 at 17:15 -0500, Chuck Lever wrote:
>>>>> On Nov 30, 2018, at 4:55 PM, Trond Myklebust <trondmy@gmail.com
>>>>>>=20
>>>>> wrote:
>>>>>=20
>>>>> A call to gss_wrap_req_priv() will end up replacing the
>>>>> original
>>>>> array
>>>>> in rqstp->rq_snd_buf.pages with a new one containing the
>>>>> encrypted
>>>>> data. In order to avoid having the rqstp->rq_snd_buf.bvec point
>>>>> to
>>>>> the
>>>>> wrong page data, we need to refresh that too.
>>>>=20
>>>> I would add a note here that this patch fixes a memory leak. And
>>>> you might want to add a Fixes: tag.
>>>>=20
>>>=20
>>> It only applies to new code that went into 4.20, so it won't need
>>> any
>>> stable backporting.
>>>=20
>>> That said, I'm realising (slowly - apparently I'm asleep today)
>>> that
>>> this is receive side code, so
>>>=20
>>> a) The contents of rq_snd_buf are irrelevant.
>>> b) We want to beware of changing it while there is a copy in
>>> rq_private_buf.
>>>=20
>>> IOW: a v4 is forthcoming.
>>=20
>> fwiw, i see the soft IRQ warnings with NFS/RDMA too.
>>=20
>> I would like to turn those into a pr_warn_rate_limited. I don't
>> see much point in the backtrace blather.
>>=20
>=20
> Your initial email mentioned these soft IRQ warnings, but didn't
> provide an example. Which warnings are these exactly, and where are
> they coming from?

The WARN_ON in call_decode that fires when rq_rcv_buf does not
exactly match rq_private_buf.


--
Chuck Lever



