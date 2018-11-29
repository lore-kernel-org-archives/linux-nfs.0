Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81596C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:47:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48CC9213A2
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:47:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WEtA+7em"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48CC9213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726557AbeK3Fxs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 00:53:48 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:42156 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726393AbeK3Fxs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2018 00:53:48 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wATIhqDH064494;
        Thu, 29 Nov 2018 18:47:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=FteQIVTFgIm5PS8tYlKownI0MaMAsDKrjgXyfgSkD+Y=;
 b=WEtA+7emPY5uACAS/hokK9842izXFU/XvBZcnUujxMRAgavi6sQYeTJUCT+a+HdS8VlW
 fGU/fvDFtcYANwoUooJZOYTllqJJDk4i+yaCWC4Q9c3UTGLbkAapVUu8fMLec82Qms6v
 EI4x687PyiKUB9XF6MmhhFlC1sI9/z84lNNQW/PR18+Yfr5NZrHLjOeU9dhhGsTFOzHb
 z3xKFC/AxfcHxqglatC+grnwahafKdypCn29/J5L8ofnwtTPtC58zqc+MGaCv6YuATU2
 iVC6cqwG2WORjBx8L9lVOLUEfgDB9yf232LIROPP5aoK610tyuFtApUOCDeYEwkptWQ9 Tw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2nxy9rj03t-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 29 Nov 2018 18:47:24 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wATIlN2t012076
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 29 Nov 2018 18:47:23 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wATIlMj1016531;
        Thu, 29 Nov 2018 18:47:23 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 29 Nov 2018 10:47:22 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 1/3] Fix quoting in configure.ac
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2d71fb1b-d0dc-df8e-f201-0badd56d9244@RedHat.com>
Date:   Thu, 29 Nov 2018 13:47:21 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3A3A5920-5F9D-4268-88AF-C53A34B2202F@oracle.com>
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
 <2d71fb1b-d0dc-df8e-f201-0badd56d9244@RedHat.com>
To:     Steve Dickson <SteveD@RedHat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9092 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811290154
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 29, 2018, at 1:46 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 10/31/18 4:02 PM, Chuck Lever wrote:
>> Replace an unmatched single quote to help syntax coloring editors.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> configure.ac |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/configure.ac b/configure.ac
>> index cf1c4b9..16eae06 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -165,7 +165,7 @@ AC_ARG_ENABLE(uuid,
>> 	choose_blkid=3Ddefault)
>> AC_ARG_ENABLE(mount,
>> 	[AC_HELP_STRING([--disable-mount],
>> -		[Don't build mount.nfs and do use the util-linux =
mount(8) functionality. @<:@default=3Dno@:>@])],
>> +		[Do not build mount.nfs and do use the util-linux =
mount(8) functionality. @<:@default=3Dno@:>@])],
>> 	enable_mount=3D$enableval,
>> 	enable_mount=3Dyes)
>> 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" =3D "yes"])
>>=20
> All three patches committed....=20

Excellent, thanks!


--
Chuck Lever



