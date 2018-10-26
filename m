Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D83ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:44:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C0E2C20665
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LLtwdvcY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E2C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726243AbeJ0AVl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 20:21:41 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:41502 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726113AbeJ0AVl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 20:21:41 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9QFi1bn181508;
        Fri, 26 Oct 2018 15:44:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=1XWVHkfPDhEdsFh43e1oy3XfgUXwiiQHxfefdAbYjr4=;
 b=LLtwdvcYtyKp8XOQAV0joLGtyBUTArf5jfgsVHOdK/q8tWfn3uEUkV9sm78l7fnqlrhq
 wAJc7PlWgwp0T6d0xNFRYAxA8xoUUsagIKvowY2RSsbV6kgJao/VDsq/PHfx/BPORAIf
 /iBFCCQN6mXo/gabUozK30JFsD12OsL5G5dQ926ROqOhg2IfpIiDEslIZ9afIAeKAD0p
 bPlK/KcDsUvXQ/NUgTs1jiwLmOX1hV8KJh0MbroYYLVk71Xe+XOyUgsvL+oLEfPBwD4x
 piYpTDimy2EbXdTvGOpGm1I2Cp5QRnilHZq5+GbYz8WAEaad+lwFgZ2ygWztNUfndFQi 1Q== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2n7usur1t0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 26 Oct 2018 15:44:01 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9QFhqxL026118
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 26 Oct 2018 15:43:52 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w9QFhpD7009289;
        Fri, 26 Oct 2018 15:43:51 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 26 Oct 2018 08:43:47 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: copy offload support and absent file system
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyE25JYUbnhvRD32_ZxyALdXd+emy2qK315DeXb+DgLn1Q@mail.gmail.com>
Date:   Fri, 26 Oct 2018 11:43:40 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E2EE0769-0ED0-407B-B3EE-F22F58AD458F@oracle.com>
References: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
 <6CA0FBE4-6B7C-4D05-BE1E-AB3BEDD90171@oracle.com>
 <CAN-5tyE25JYUbnhvRD32_ZxyALdXd+emy2qK315DeXb+DgLn1Q@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9057 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810260132
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Oct 26, 2018, at 11:39 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>=20
> On Fri, Oct 26, 2018 at 11:04 AM Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>=20
>>> On Oct 26, 2018, at 8:54 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>> In the context of doing a copy between different "types" of
>>> filesystems, it was pointed out to me that NFS has many types:
>>> nfs4_fs_type, nfs4_remote_fs_type, nfs4_remote_referral_fs_type,
>>> nfs4_referral_fs_type. So doing a simple check that fs type of "in"
>>> and "out" might not be sufficient. Do you see any issues allowing a
>>> copy offload between different types? Basically checking that "in" =
and
>>> "out" descriptions come from any of the these types?
>>=20
>> I'm no expert... so what follows is an uninformed opinion.
>=20
> I was wondering if there was anything different about the
> migrated/replicated filesystem that maybe say they are typically
> read-only and thus doing a copy there wouldn't be appropriate. But it
> sounds like you don't see anything special about doing a copy from
> nfs4_fs_type to say nfs_remote_fs_type?

If I recall correctly the distinction between these "types" is
the way they are attached to the client's filesystem namespace.
I don't believe that would have any impact on whether copy
offload is supported or not.


>> All of these are NFSv4 file systems. But I don't think that's an
>> adequate check (it's necessary, but not sufficient).
>=20
>=20
>> The minor version of the mount point has to be 2 or higher, and
>> the client must confirm that the mounted server supports copy
>> offload (because all NFSv4.2 features are OPTIONAL).
>=20
> I agree that we should check for 4.2 versioning but the latter I don't
> think is necessary, as the COPY call will just gets not supported
> error (we already have the capability check for CAP_COPY inside of
> nfs42_proc_copy , just in case we already sent one copy and then
> negated the capabilities).

The COPY call could also return EROFS if the destination filesystem
is a read-only replica.

--
Chuck Lever



