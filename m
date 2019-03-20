Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C87BC10F05
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 13:40:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F05852184E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 13:40:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="O25ccRyM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726366AbfCTNkr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 09:40:47 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:45124 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727137AbfCTNko (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 09:40:44 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2KDXpX0019571;
        Wed, 20 Mar 2019 13:40:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=2beHcMZ0nUXjkWAIGV4BudvweLQXmEfJPO/sbJdhZUE=;
 b=O25ccRyM3RaGq0KCGUZYJdWk8Tjs5vxs3/LWanvXHOLFlWuHmaLNtOk8j2Z4Il8WI/OH
 yo8976KieQAaEqf+M62sPiNrRoZ8CxCkBfMplE1Xd4qQAHjY6+Gx0P39CAA1TjN3076U
 rPCrMoAwjl3iOL+tXGLXlfDP5k7Vr0+X/uvnycaeWhBaxQ9USd5p963t9zRThfQePEgV
 aTrzxLCHchiHsGMVlF6pNOOhkcFovvuv91x7ZsfkpvnArLlKdNemu1dGxFrDRT7mkjV7
 crMqRfziZg39Zs0t/uO5hfq+9a/k5tkUXrz2MkinEdfvi6JZVwsVoO7DCxWeQm7P0x8K AQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2r8pneu15h-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Mar 2019 13:40:32 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2KDeR2X030477
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Mar 2019 13:40:27 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2KDePHW010457;
        Wed, 20 Mar 2019 13:40:25 GMT
Received: from [100.66.188.10] (/198.214.85.110)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 20 Mar 2019 06:40:24 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1553027371.4899.116.camel@linux.ibm.com>
Date:   Wed, 20 Mar 2019 08:40:25 -0500
Cc:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <0E02D70A-A5E9-4B27-9922-521D5A0755A3@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
 <20190307152854.11306.84006.stgit@manet.1015granger.net>
 <20190308211016.GB27011@fieldses.org>
 <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
 <20190308212310.GB28002@fieldses.org>
 <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
 <1553027371.4899.116.camel@linux.ibm.com>
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9200 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903200105
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 19, 2019, at 3:29 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>=20
> On Fri, 2019-03-08 at 16:29 -0500, Chuck Lever wrote:
>=20
> Thanks Serge for bringing this thread to my attention.  Sorry for the
> delay in responding ...
>=20
>>> On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
>>>>=20
>>>>=20
>>>>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
>>>>>=20
>>>>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
>>>>>> The NFS server needs to allow NFS clients to perform their own
>>>>>> attestation and measurement.
>=20
> Measurement and attestation is only one aspect.  The other aspect is
> verifying the integrity of files.  Shouldn't the NFS server verify the
> integrity of a file before allowing it to be served (eg. malware)?

Hi Mimi, thanks for the review.

Architecturally, the server is not using the file's data, it is
merely part of the filesystem that stores it. But that said, there
are several concrete reasons why I feel an NFS server should not be
involved in measurement/attestation, but only with storing file
content and IMA metadata.

1. The broadest attack surface for a remote filesystem is modification
of data in flight. Attestation of the file on the server is not going
to defend against that attack, only attestation on the client will do
that. Is there a good reason to pay the cost of double attestation?

2. It is possible (perhaps even likely) that the NFS server and a
client of that server will have different IMA policies and even
different file signing authorities.

A third, perhaps related, reason is that NFS can run on non-Linux NFS
servers which would not have any attestation at all. An NFS client
should not have to rely on the server for attestation, but should
trust only its own measurement of each file, which would be done as
late as possible before use.

Lastly, the NFS protocol does not enable an NFS client to tell a
server how the file is to be used. For example, the server's policy
might block execution of an unverifiable file, but the server won't
have any way of knowing how the client is going to use that file.
The client might be opening the file to copy it or update its IMA
metadata.

Speaking of protocol, there's no special error code that reports an
integrity verification failure. The client just sees that the UID
does not have access to the file. There's no way the user or client
can do anything to clear this condition via NFS without IMA support.

If these reasons make sense, should I add them to the patch description?


>>>>> Can we really remove this call?
>>>>=20
>>>> Why wouldn't we be able to?
>>>=20
>>> I don't know the first thing about IMA, but surely it's there for =
some
>>> reason--
>>=20
>> It was originally added because the number of opens and closes of =
@file
>> were counted, and not having that call was triggering a warning. =
Since
>> commit 8eb988c70e770 ("fix ima breakage") the counters are maintained
>> separately.
>=20
> If that was the only reason, then the call itself would have been
> removed with the counter code.
>=20
> Mimi
>=20
>>=20
>>=20
>>> is it really OK just to skip this on opens by nfsd?
>>=20
>> That's why I split this out into a separate patch. I'm hoping to get
>> some commentary from the linux-integrity community.
>>=20
>>=20
>>> --b.
>>>=20
>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>> ---
>>>>>> fs/nfsd/vfs.c |    6 ------
>>>>>> 1 file changed, 6 deletions(-)
>>>>>>=20
>>>>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>>>>> index 3c00072..524c6e5 100644
>>>>>> --- a/fs/nfsd/vfs.c
>>>>>> +++ b/fs/nfsd/vfs.c
>>>>>> @@ -802,12 +802,6 @@ static int nfsd_open_break_lease(struct =
inode *inode, int access)
>>>>>> 		goto out_nfserr;
>>>>>> 	}
>>>>>>=20
>>>>>> -	host_err =3D ima_file_check(file, may_flags);
>>>>>> -	if (host_err) {
>>>>>> -		fput(file);
>>>>>> -		goto out_nfserr;
>>>>>> -	}
>>>>>> -
>>>>>> 	if (may_flags & NFSD_MAY_64BIT_COOKIE)
>>>>>> 		file->f_mode |=3D FMODE_64BITHASH;
>>>>>> 	else
>>>>=20
>>>> --
>>>> Chuck Lever
>>>>=20
>>>>=20
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
>=20

--
Chuck Lever



