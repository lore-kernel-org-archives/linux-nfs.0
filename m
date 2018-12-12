Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38E1DC67839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 15:54:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F23EB2084E
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 15:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2hEiSQya"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F23EB2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726922AbeLLPyx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 10:54:53 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:54204 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726358AbeLLPyx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 10:54:53 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBCFrjTn015166;
        Wed, 12 Dec 2018 15:54:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=TckxmfsZBV1AMPQHn20wubEUrgvy1KapMbOmBLksOa4=;
 b=2hEiSQya2uotBlLFu6vQ0ZnmVBwIxXlfOr0goTiDHUTp1XJADrc12QO2vXK8mB9GjoR3
 9NqYbg5ebvpU+6rGcxm1o8KAJYIzvww20zAeNErHsCMhbmnutQfWXI3uqQ1A2whCqkdl
 zEr7OuUQAXkFdW3TyjxkoJDhOANIu1sXtJBEL/YPYzZ5MVdAeKwEFDMtIktoRQchyV81
 bCV7UMqZsHAaRXQt6DuOI+gVoHY5rnPqItLRQwhRshlUUxFLEONNKL8SQA3b70z7s5sS
 +9Eor1FJoDymgYzUm/dIVhVbHLzW5vIgxK4eYYsUI2TFABj9sh7zwU24CAaeNJZjhWuv FA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2p86kr2q1e-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 12 Dec 2018 15:54:36 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBCFsVSZ013555
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 12 Dec 2018 15:54:31 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBCFsVNN026556;
        Wed, 12 Dec 2018 15:54:31 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 12 Dec 2018 07:54:30 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] nfsref: switch the way libraries are linked.
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <40177ab7-bf23-7966-fbfa-9bac12d4655c@RedHat.com>
Date:   Wed, 12 Dec 2018 10:54:29 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <BEDC3A34-5C04-4AF9-852B-B8BD104A4BA4@oracle.com>
References: <20181211190944.71940-1-steved@redhat.com>
 <0F088877-F56A-47FF-BBF3-95A8293BF912@oracle.com>
 <40177ab7-bf23-7966-fbfa-9bac12d4655c@RedHat.com>
To:     Steve Dickson <SteveD@redhat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9104 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=908
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812120138
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 11, 2018, at 5:27 PM, Steve Dickson <SteveD@redhat.com> wrote:
>=20
>=20
>=20
> On 12/11/18 2:12 PM, Chuck Lever wrote:
>>=20
>>> On Dec 11, 2018, at 2:09 PM, Steve Dickson <steved@redhat.com> =
wrote:
>>>=20
>>> Link the static libs before the dynamic libs allowing
>>> the routines in the static libs to be defined
>>> by the dynamic libs
>>=20
>> Hi Steve, Why is this change necessary? Is there a bug report?
> No... when I enabled junctions in the Fedora rawhide (F30) I got
> a bunch of xml undefined routines=20
>   =
https://koji.fedoraproject.org/koji/getfile?taskID=3D31408933&volume=3DDEF=
AULT&name=3Dbuild.log&offset=3D-4000
>=20
> It compiled fine on f29 but not on rawhide
>=20
> After asking if the XML api changed, people suggested I simply
> change the order of how the static and dynamic libs are linked,
> which worked
>=20
> =
https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.or=
g/message/6UIAF47S73QFLCJDWEWXKQHZTOMB5JXQ/
>=20
> =
https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.or=
g/message/VK2XPHV2MELV6IRKBG2ITI6GKUBMMRQW/

OK. See also:

=
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dcommit;h=3D05d645002=
3265e15bdc6e6bd24c05b1586e87d1d

which is a similar change, but it hits other Makefiles as well.
I wonder why only nfsref/Makefile.am is affected for you.


> steved.
>=20
>>=20
>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> utils/nfsref/Makefile.am | 6 +++---
>>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>>=20
>>> diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
>>> index 44edc83..2409dd0 100644
>>> --- a/utils/nfsref/Makefile.am
>>> +++ b/utils/nfsref/Makefile.am
>>> @@ -27,9 +27,9 @@ noinst_HEADERS		=3D nfsref.h
>>>=20
>>> sbin_PROGRAMS		=3D nfsref
>>> nfsref_SOURCES		=3D add.c lookup.c nfsref.c remove.c
>>> -LDADD			=3D $(LIBXML2) $(LIBCAP) \
>>> -			  ../../support/nfs/libnfs.la \
>>> -			  ../../support/junction/libjunction.la
>>> +LDADD			=3D ../../support/nfs/libnfs.la \
>>> +			  ../../support/junction/libjunction.la \
>>> +			  $(LIBXML2) $(LIBCAP)
>>>=20
>>> man8_MANS		=3D nfsref.man
>>>=20
>>> --=20
>>> 2.19.2
>>>=20
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20

--
Chuck Lever



