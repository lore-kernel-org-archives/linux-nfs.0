Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B85DC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 16:00:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0C70D21871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 16:00:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ugZrDjsh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727083AbeLRQAL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 11:00:11 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:44856 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727071AbeLRQAL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2018 11:00:11 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBIFtpIC067223;
        Tue, 18 Dec 2018 16:00:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=LIKxGWmlRkz3ndrmLe05fmtGpuBzSRPoX4bW4DYag7U=;
 b=ugZrDjshxk5lxbUKYflfmCWLs0004jXa7OadKVz6L7qs6iQXSeY9vqkLXems+0PxI73z
 FwPMe3htYhne22F1iFlJ6rKGhMaYSbM8Sj0WMwFywvbGRlqCrRlrekfNYPzhfZNtmk5r
 /Q2vyPBDiJ5ht6mv2J1H+VnHWvXwt0d8R/e/GkIHfz6Tm0ynIwbULu2+kGhOSb8b9Y8q
 efKjO4IkwvRL+F8XNniyVkVC1OusLwHs/qJ7gYrZri/x1DUkncNXr/ekO+53iYNrLuWe
 WZjosvYsD9+DYoxOjw2xr9JeVXbcSbneLYlG/kiiolUpREoupPGuqDhFLb9fpdYkON6S Og== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2pct8qv7t2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 16:00:00 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBIG00cx001310
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 16:00:00 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBIFxxXf023958;
        Tue, 18 Dec 2018 16:00:00 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 18 Dec 2018 07:59:59 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 1/3] SUNRPC: Fix disconnection races
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2acfb506b55380b3c46ef62cd597d724a517fd75.camel@hammerspace.com>
Date:   Tue, 18 Dec 2018 10:59:57 -0500
Cc:     "smayhew@redhat.com" <smayhew@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <5499D539-B24A-4E54-B9A7-11A91ADE9C0B@oracle.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
 <20181218142055.GK27213@coeurl.usersys.redhat.com>
 <2acfb506b55380b3c46ef62cd597d724a517fd75.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9111 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=924
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812180134
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 18, 2018, at 10:55 AM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Tue, 2018-12-18 at 09:20 -0500, Scott Mayhew wrote:
>> I ran Dave's test in a loop over night with these 3 patches on top of
>> v4.20-rc7 and didn't see any more of the XPRT_WRITE_SPACE hangs.
>>=20
>=20
> Thanks for verifying that!

With these three patches and my RDMA-related disconnect fixes, fio8 on =
krb5i
now works fine, even though the connect count was 508. No stalls or =
deadlocks.

Tested-by: Chuck Lever <chuck.lever@oracle.com>

--
Chuck Lever



