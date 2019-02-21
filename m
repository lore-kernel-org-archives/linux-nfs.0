Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80D2AC10F08
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 14:49:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 529A920700
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 14:49:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kLJlcN9n"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728406AbfBUOtY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 09:49:24 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:36622 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727594AbfBUOtX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 09:49:23 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1LEhsCO180137;
        Thu, 21 Feb 2019 14:49:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=gU4/lIIXfp5axGfGZemOTwBmY15/bZEdGRpknUuohV8=;
 b=kLJlcN9neikNjCFWfa93W88rTRw3dfIhYRUZKe9ZhE/yH/x0nLJOXdUiNPqNHKA2K/Z8
 Vab68LRp0J4hFQKQPRBU7nyMcexJMpKG7yO6i3sT3AWCwxs5fTFYPUGsex6NZSv/TotO
 PqTA8DJumJQpZPiZQi+6F1m+ODhTeMq32ywlFZrfUd9d0Kzdw3SAMacxNmoqIUCMVOl0
 r5f7zLblr1GoycHmu+bS//Aixvy7jNWXmTFs5o/C8CbpAal7hTTwBibb5EveZq+Vg+zn
 7c6fIlmNLD/gmDO44hEv65UBiKe0hlYIUIaLXs+DjDbqeJGekI12ASDLU4+hee2qYMkb lA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2qp9xu8ey9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Feb 2019 14:49:19 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1LEnI2Q007552
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Feb 2019 14:49:18 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1LEnHgF031964;
        Thu, 21 Feb 2019 14:49:17 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 21 Feb 2019 06:49:17 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1550665596.17768.32.camel@linux.ibm.com>
Date:   Thu, 21 Feb 2019 09:49:16 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <71608AB6-ED45-43BA-A520-0DC2DA7D1C44@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <1550623002.17768.10.camel@linux.ibm.com>
 <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
 <1550665596.17768.32.camel@linux.ibm.com>
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9173 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902210108
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 20, 2019, at 7:26 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>=20
> On Tue, 2019-02-19 at 22:51 -0500, Chuck Lever wrote:
>>> On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>>> EVM is not supported in this prototype. NFS does not support =
several
>>>> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
>>>> Linux file capabilities are not supported, which makes EVM more
>>>> difficult to support on NFS mounts.
>>>=20
>>> There's no requirement for all of these xattrs to exist.  If an =
xattr
>>> does exist, then it is included in the security.evm hmac/signature.
>>=20
>> Understood. The issue is that if they exist on a file residing on an =
NFS server,
>> such xattrs would not be visible to clients. My understanding is that =
then EVM
>> verification would fail on such files on NFS clients.
>>=20
>> We could possibly make EVM work in limited scenarios until such time =
that
>> the NFS protocol can make those xattrs available to NFS clients. I =
hope that
>> having only security.ima is useful at least for experimenting and =
maybe more.
>>=20
>> However, if folks think having security.evm also is needed, that is =
straight-
>> forward... just saying that there are currently other limits in NFS =
that make a
>> full EVM implementation problematic.
>=20
> Thank you for the explanation.  Yes, I think there is a benefit of
> having a file signature, without EVM.

It's been pointed out to me that a malicious actor inserted between
an NFS server and an NFS client can concurrently substitute the IMA
signature and a file's content with that of another file on the same
NFS share.

This could be used to substitute /etc/group for /etc/passwd, for
example. Both files are unchanged and have verifiable IMA signatures.
The /etc/group file contains a passwd-like entry for root in it, but
without a password field. That would allow the actor to gain root
access on the NFS client.

NFS can mitigate this substitution by using Kerberos 5 integrity to
protect wire traffic from tampering. However, a malicious NFS server
could also perform this substitution, and krb5i would not be able to
detect it.

I'm wondering if there's a mechanism within IMA's toolset to detect
such a substitution on an NFS client.

--
Chuck Lever



