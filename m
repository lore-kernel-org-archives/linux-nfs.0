Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD439C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:58:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DC7E20831
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:58:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iDlxCZBB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DC7E20831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730441AbeKTGXh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 01:23:37 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:41818 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730219AbeKTGXh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 01:23:37 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAJJs8Wb100330;
        Mon, 19 Nov 2018 19:58:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=7yEBSjFr/uZhcLrh9s0s/I28mcheFkrxap/InZFHq7w=;
 b=iDlxCZBBBAUTrNTxCIsNjqKQF6E+/r/yGqZaaKbyy1ZaV6KQen7Gr46r2ri0Zav1IS2U
 EYaeh77YdfRDcXGZWdBPY2zlzBnZSbBx9v25OFoOpY4k0U5vUvCXRY8J7yxWhFfDfGxb
 GyBiZkj0oju1t9YzyAP2x0/AXPzLUuCbNAJPtRrmgM/S9vKqACzi90DCZgy88ZlmD69S
 +pk9+9Z7RmyrP9M9nvIISPmgjuxxvcBeaoMM245cfASI2jNWJRQ2u+LBVZ1oSdG65lP6
 8qwCGZam4x1l1GAvECUA1QdZmFbNo7/L1SvjCcMHjv4/gU92cvVTcjQzicO7WCPC+3J0 OA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2ntbmqg1m5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 19:58:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAJJwI7q001739
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 19:58:19 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAJJwISC016724;
        Mon, 19 Nov 2018 19:58:18 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 19 Nov 2018 11:58:18 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill
 helper
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181119195442.GA22976@fieldses.org>
Date:   Mon, 19 Nov 2018 14:58:17 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A6299E15-DDDB-4BF4-8F54-62BC799215AF@oracle.com>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151905.21878.62693.stgit@klimt.1015granger.net>
 <20181115163246.GB9022@fieldses.org>
 <A6FEE9E7-0226-460F-AA3E-42D7CEE9A781@oracle.com>
 <20181119195442.GA22976@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9082 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=916
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811190178
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 19, 2018, at 2:54 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Thu, Nov 15, 2018 at 04:19:52PM -0800, Chuck Lever wrote:
>>=20
>>=20
>>> On Nov 15, 2018, at 8:32 AM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> Um, I somehow managed to overlook a pynfs regression till just now:
>>>=20
>>> On Fri, Jul 27, 2018 at 11:19:05AM -0400, Chuck Lever wrote:
>>>> fill_in_write_vector() is nearly the same logic as
>>>> svc_fill_write_vector(), but there are a few differences so that
>>>> the former can handle multiple WRITE payloads in a single COMPOUND.
>>>>=20
>>>> svc_fill_write_vector() can be adjusted so that it can be used in
>>>> the NFSv4 WRITE code path too. Instead of assuming the pages are
>>>> coming from rq_args.pages, have the caller pass in the page list.
>>>>=20
>>>> The immediate benefit is a reduction of code duplication. It also
>>>> prevents the NFSv4 WRITE decoder from passing an empty vector
>>>> element when the transport has provided the payload in the =
xdr_buf's
>>>> page array.
>>>>=20
>>> ...
>>>> @@ -1027,7 +1009,10 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>>>> 	write->wr_how_written =3D write->wr_stable_how;
>>>> 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
>>>>=20
>>>> -	nvecs =3D fill_in_write_vector(rqstp->rq_vec, write);
>>>> +	nvecs =3D svc_fill_write_vector(rqstp, write->wr_pagelist,
>>>> +				      &write->wr_head, =
write->wr_buflen);
>>>> +	if (!nvecs)
>>>> +		return nfserr_io;
>>>=20
>>> Do you remember why you added this check?
>>=20
>> Yes, at one point svc_fill_write_vector() called the transport
>> layer to do some processing, and I needed a way for it to
>> indicate a graceful failure.
>>=20
>>=20
>>> It's causing zero-length writes to fail, in violation of the spec:
>>>=20
>>> 	"If the count is zero, the WRITE will succeed and return a count
>>> 	of zero subject to permissions checking."
>>=20
>> RFC 7530, Section 16.36.4.
>>=20
>>=20
>>> I'm not seeing a reason why it wouldn't be safe just to remove that
>>> check.
>>=20
>> Or, make the check more specific:
>>=20
>> 	if (!nvecs && write->wr_buflen)
>> 		return nfserr_io;
>>=20
>> This is a little more bullet proof, in case of bugs in the
>> transport layer.
>=20
> The current svc_fill_write_vector is pretty short and obviously can't
> hit that case, so I'd just find that confusing.  We can re-add that
> check when if and when it's needed.

Should I send you a patch?


--
Chuck Lever



