Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 142FBC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 17:28:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D7C712133F
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 17:28:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HgpVoK0e"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727163AbeLRR2J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 12:28:09 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:44140 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726638AbeLRR2I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2018 12:28:08 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBIHJ8ln143796;
        Tue, 18 Dec 2018 17:28:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=+ywJuIVPI+Tfbdep8zOqfXEjF+jVqYYkyCC6klhXdGw=;
 b=HgpVoK0eH2gm1PX1lum04n/O8JmWddkQK8aJ0USJ03bppmOG9xqnL4nCEJx/FRnUP4TL
 lxCRu2X1Qtcs58WuAqp0vftKzZmeQX5U6XfQWlIa7r4MdWc3vwqko928B7jdQVRR2+NX
 OCN67rtkBeeq+KGZA5cJysl6RrUJ/wHRY5cnaxuZAuWgxeLInXJ4mVX1DYmYrjR4s3Ro
 /lniLGBJrs+1v/9qJxpbrOyKhBkznZR2TmiL28a3nEbYlBkwxWsMC1zGTmlSoqwUmwou
 OOKWC31qpvuU72CVWEOvR/vKbhvfRvB9G9IReZdCwxX+OhsxrqC7230xNxoJBYh4B+Tc 7A== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2pct8qvrtm-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 17:28:04 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBIHRvvE030702
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 18 Dec 2018 17:27:57 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBIHRtIn000559;
        Tue, 18 Dec 2018 17:27:56 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 18 Dec 2018 09:27:55 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 1/3] SUNRPC: Fix disconnection races
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <b4b3eeb9ed30437998c9cc7766012ff0fd316b8e.camel@hammerspace.com>
Date:   Tue, 18 Dec 2018 12:27:53 -0500
Cc:     "smayhew@redhat.com" <smayhew@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <68DFAB69-180B-4B78-B4F3-EB7DD7B8152C@oracle.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
 <20181218142055.GK27213@coeurl.usersys.redhat.com>
 <2acfb506b55380b3c46ef62cd597d724a517fd75.camel@hammerspace.com>
 <5499D539-B24A-4E54-B9A7-11A91ADE9C0B@oracle.com>
 <b4b3eeb9ed30437998c9cc7766012ff0fd316b8e.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9111 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=874
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812180144
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 18, 2018, at 11:02 AM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Tue, 2018-12-18 at 10:59 -0500, Chuck Lever wrote:
>>> On Dec 18, 2018, at 10:55 AM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Tue, 2018-12-18 at 09:20 -0500, Scott Mayhew wrote:
>>>> I ran Dave's test in a loop over night with these 3 patches on
>>>> top of
>>>> v4.20-rc7 and didn't see any more of the XPRT_WRITE_SPACE hangs.
>>>>=20
>>>=20
>>> Thanks for verifying that!
>>=20
>> With these three patches and my RDMA-related disconnect fixes, fio8
>> on krb5i
>> now works fine, even though the connect count was 508. No stalls or
>> deadlocks.
>>=20
>> Tested-by: Chuck Lever <chuck.lever@oracle.com>
>=20
> Yay! Thanks Chuck.

I am highly in favor of fewer thundering herd wake-ups !  ;-)


--
Chuck Lever



