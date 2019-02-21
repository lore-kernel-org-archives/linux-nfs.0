Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C549C00319
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:58:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CD232084D
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:58:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MSOxxz10"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728197AbfBUP65 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 10:58:57 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:49076 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725870AbfBUP65 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 10:58:57 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1LFmmXw053121;
        Thu, 21 Feb 2019 15:58:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=CHX19JXKRwHLYMABYR4JC1y0bm1M4KD2kPvXInJZKd4=;
 b=MSOxxz10X9MYCU1bNaNR3WgxPV6VeyKTAc3n/NJyj2tLjklAQYRUZlsg+g5+f29qcLeV
 6G+oxwldW4+fpJ84PK5dpE6Jc6nS8iP3jaxrGmquoYjUn9HRZ0sNifcDrSp6arnFPnPz
 b1/819+vlF3LMxrBfJWNlhVxmVx2DEo/uyRJbgcSIZez5n2QW8uWKChTFXiIAdnSr2dM
 NGN1pQs4DKGtISooTJjy8KaU4/13DPDoVFhVHDBy/qfeQT+F3FTU07Bv4prGYldYSYob
 Hez5JQGiakVEItq4SR/Uqn/TGg8GF5RElBAThaE89kSpGOPGq4B+QC/QYd6F+4KhIJZd jQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2qp81eh2t0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Feb 2019 15:58:52 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1LFwoah015113
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Feb 2019 15:58:51 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1LFwoYC025651;
        Thu, 21 Feb 2019 15:58:50 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 21 Feb 2019 07:58:50 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1550764295.17768.108.camel@linux.ibm.com>
Date:   Thu, 21 Feb 2019 10:58:49 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        Allison Henderson <allison.henderson@oracle.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <65FC50F1-0EE6-4A3E-95E4-50D9737D3089@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <1550623002.17768.10.camel@linux.ibm.com>
 <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
 <1550665596.17768.32.camel@linux.ibm.com>
 <71608AB6-ED45-43BA-A520-0DC2DA7D1C44@oracle.com>
 <1550764295.17768.108.camel@linux.ibm.com>
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9174 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902210115
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 21, 2019, at 10:51 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>=20
> On Thu, 2019-02-21 at 09:49 -0500, Chuck Lever wrote:
>>=20
>>> On Feb 20, 2019, at 7:26 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>>>=20
>>> On Tue, 2019-02-19 at 22:51 -0500, Chuck Lever wrote:
>>>>> On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> =
wrote:
>>>>>=20
>>>>> Hi Chuck,
>>>>>=20
>>>>>> EVM is not supported in this prototype. NFS does not support =
several
>>>>>> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
>>>>>> Linux file capabilities are not supported, which makes EVM more
>>>>>> difficult to support on NFS mounts.
>>>>>=20
>>>>> There's no requirement for all of these xattrs to exist.  If an =
xattr
>>>>> does exist, then it is included in the security.evm =
hmac/signature.
>>>>=20
>>>> Understood. The issue is that if they exist on a file residing on =
an NFS server,
>>>> such xattrs would not be visible to clients. My understanding is =
that then EVM
>>>> verification would fail on such files on NFS clients.
>>>>=20
>>>> We could possibly make EVM work in limited scenarios until such =
time that
>>>> the NFS protocol can make those xattrs available to NFS clients. I =
hope that
>>>> having only security.ima is useful at least for experimenting and =
maybe more.
>>>>=20
>>>> However, if folks think having security.evm also is needed, that is =
straight-
>>>> forward... just saying that there are currently other limits in NFS =
that make a
>>>> full EVM implementation problematic.
>>>=20
>>> Thank you for the explanation.  Yes, I think there is a benefit of
>>> having a file signature, without EVM.
>>=20
>> It's been pointed out to me that a malicious actor inserted between
>> an NFS server and an NFS client can concurrently substitute the IMA
>> signature and a file's content with that of another file on the same
>> NFS share.
>>=20
>> This could be used to substitute /etc/group for /etc/passwd, for
>> example. Both files are unchanged and have verifiable IMA signatures.
>> The /etc/group file contains a passwd-like entry for root in it, but
>> without a password field. That would allow the actor to gain root
>> access on the NFS client.
>>=20
>> NFS can mitigate this substitution by using Kerberos 5 integrity to
>> protect wire traffic from tampering. However, a malicious NFS server
>> could also perform this substitution, and krb5i would not be able to
>> detect it.
>>=20
>> I'm wondering if there's a mechanism within IMA's toolset to detect
>> such a substitution on an NFS client.
>=20
> This problem isn't limited to NFS, but is a general problem.  The file
> name is part of the directory information, which would need to be
> protected all the way up to root. (Dmitry's directory patches protects
> one level of the directory tree.)

OK, glad to know NFS is not alone!

We would need to guarantee that the file's absolute pathname as seen
by NFS clients is the same as its pathname as seen locally on the NFS
server. This wasn't true for NFSv3, but is usually true for NFSv4,
which exposes a pseudofilesystem root -- on many NFSv4 servers this
looks just like the real local filesystem missing any files that are
not shared. (NFS folks, feel free to chime in and tell me I'm wrong).


> At last years LSF/MM, Allison Henderson gave a talk titled "XFS parent
> pointers" - https://lwn.net/Articles/753480/.  After Allison's talk,
> instead of protecting the entire filesystem directory hierarchy, Boaz
> Harrosh suggested including the XFS parent pointers' pathname, stored
> as an xattr, in the set of EVM protected xattrs.

What is to be done about hard linked files?


--
Chuck Lever



