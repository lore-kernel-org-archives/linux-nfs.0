Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07A29C10F09
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:29:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC63620855
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:29:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nEYOae00"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726414AbfCHV3l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 16:29:41 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:55168 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726375AbfCHV3k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2019 16:29:40 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28LNe8W159310;
        Fri, 8 Mar 2019 21:29:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=b1YXD3tfQhcX4mPXEMx52mq+geJD7BafV8v8Mxkdv0I=;
 b=nEYOae00ZLMsGVQPnxzQwh0upMMvv/X7zDU4GSMRj30tnGtCGkvbFWMIVw5ReG3NVM9I
 4+92SOENhWGjJ9z9SK9f1b1JKIZzk8WA3vDvMoa0qCu80qLh0LlMrz2Lqcg9vS16ccEP
 KTdVfpHYvrfKzvUV2O+NFuB8jkx1oLsJrceJp7VTT5koslrkAh2+oR1PbALdvedsQwOJ
 qtoz211N59Ma9kh11uH29OlYvyO/6QMP3/WS/qi1EL22Wxgwp2UmlBSXPXuE3KYHUf0b
 Yl4ZhXMf7XHxBmRDndu3VIs+0UEDYb7RH9I7tbwGPAsebW4Zw+c86eBTK2vB3MEjayjF dw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2qyjfs2g3t-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 08 Mar 2019 21:29:38 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x28LTbT0022898
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 8 Mar 2019 21:29:37 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x28LTbiP008146;
        Fri, 8 Mar 2019 21:29:37 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 08 Mar 2019 13:29:37 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190308212310.GB28002@fieldses.org>
Date:   Fri, 8 Mar 2019 16:29:36 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
 <20190307152854.11306.84006.stgit@manet.1015granger.net>
 <20190308211016.GB27011@fieldses.org>
 <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
 <20190308212310.GB28002@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080148
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> wrote:
>=20
> On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
>>=20
>>=20
>>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
>>>=20
>>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
>>>> The NFS server needs to allow NFS clients to perform their own
>>>> attestation and measurement.
>>>=20
>>> Can we really remove this call?
>>=20
>> Why wouldn't we be able to?
>=20
> I don't know the first thing about IMA, but surely it's there for some
> reason--

It was originally added because the number of opens and closes of @file
were counted, and not having that call was triggering a warning. Since
commit 8eb988c70e770 ("fix ima breakage") the counters are maintained
separately.


> is it really OK just to skip this on opens by nfsd?

That's why I split this out into a separate patch. I'm hoping to get
some commentary from the linux-integrity community.


> --b.
>=20
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> fs/nfsd/vfs.c |    6 ------
>>>> 1 file changed, 6 deletions(-)
>>>>=20
>>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>>> index 3c00072..524c6e5 100644
>>>> --- a/fs/nfsd/vfs.c
>>>> +++ b/fs/nfsd/vfs.c
>>>> @@ -802,12 +802,6 @@ static int nfsd_open_break_lease(struct inode =
*inode, int access)
>>>> 		goto out_nfserr;
>>>> 	}
>>>>=20
>>>> -	host_err =3D ima_file_check(file, may_flags);
>>>> -	if (host_err) {
>>>> -		fput(file);
>>>> -		goto out_nfserr;
>>>> -	}
>>>> -
>>>> 	if (may_flags & NFSD_MAY_64BIT_COOKIE)
>>>> 		file->f_mode |=3D FMODE_64BITHASH;
>>>> 	else
>>=20
>> --
>> Chuck Lever
>>=20
>>=20

--
Chuck Lever



