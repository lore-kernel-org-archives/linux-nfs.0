Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4579C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 21:33:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DCB3217D4
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 21:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="R0rMc/C/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726257AbfAYVdJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 16:33:09 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:59416 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726179AbfAYVdI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 16:33:08 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0PLSf1f103934;
        Fri, 25 Jan 2019 21:33:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=JU0erfgdEssn8oWE9g5dBgeYOGOXgiNWeckczuIaxOo=;
 b=R0rMc/C/x/8mk9kzqlXuOE6QY3A6ec0EApsSeIbgpW8qqjJdy2OwzYqUhQ00H6OU9N4D
 uTqi2/qA8gTCd4Jd3QKB5RqT/YQFduyFEpX6qtVO5dWQLzm7PQOZQO8CWIRRbnY3bT3C
 y6+eAkIpTS+N0HtSVGGRJDRIVBw9M49UAgApwxKyyslYbgqFGcAcCOnWdcBXfPH+yNrP
 v5jzEZm9SRW/3Ywe1p/CEVxdfGyHXgOuy8pUsJWZNZkmMIpJ2rxWOYGZxfLpuxY+RkOo
 LVx289Eqfg8SwX7JNDfdGA11maPYrykl1z7AT6NXdTIbGm1fd4buMhNRLOBqF3hJhC2r yg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2q3vhs7x2a-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 21:33:04 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0PLX3Ud025925
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 21:33:03 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0PLX0LZ013617;
        Fri, 25 Jan 2019 21:33:03 GMT
Received: from [10.126.150.87] (/148.87.23.44)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 25 Jan 2019 13:33:00 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190125203001.GA5972@fieldses.org>
Date:   Fri, 25 Jan 2019 13:32:58 -0800
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <40A18BC9-E3F9-45D0-98FF-7BCA171A3E62@oracle.com>
References: <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
 <20190109165142.GB32189@fieldses.org>
 <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
 <20190111211235.GA27206@fieldses.org>
 <BB7240BE-3F20-43AD-B709-7F18CC33CC02@oracle.com>
 <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
 <20190111221030.GA28794@fieldses.org>
 <A33F8CE5-3E5D-4359-8061-8DB8214B012B@oracle.com>
 <20190112005613.GA29181@fieldses.org>
 <F21839E5-A5DB-4BC8-8F3B-2AD02D4B2652@oracle.com>
 <20190125203001.GA5972@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9147 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=949
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901250164
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 25, 2019, at 12:30 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Mon, Jan 14, 2019 at 12:24:24PM -0500, Chuck Lever wrote:
>>=20
>>=20
>>> On Jan 11, 2019, at 7:56 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> On Fri, Jan 11, 2019 at 05:27:30PM -0500, Chuck Lever wrote:
>>>>=20
>>>>=20
>>>>> On Jan 11, 2019, at 5:10 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>>>>=20
>>>>> On Fri, Jan 11, 2019 at 04:54:01PM -0500, Chuck Lever wrote:
>>>>>>> On Jan 11, 2019, at 4:52 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>> So, I think we need your patch plus something like this.
>>>>>>>>=20
>>>>>>>> Chuck, maybe you could help me with the "XXX: Chuck:" parts?
>>>>>>>=20
>>>>>>> I haven't been following. Why do you think those are necessary?
>>>>>=20
>>>>> I'm worried something like this could happen:
>>>>>=20
>>>>> 	CPU 1				CPU 2
>>>>> 	-----				-----
>>>>>=20
>>>>> 	set XPT_DATA			dec xpt_nr_rqsts
>>>>>=20
>>>>> 	svc_xprt_enqueue		svc_xprt_enqueue
>>>>>=20
>>>>> And both decide nothing should be done if neither sees the change =
that
>>>>> the other made.
>>>>>=20
>>>>> Maybe I'm still missing some reason that couldn't happen.
>>>>>=20
>>>>> Even if it can happen, it's an unlikely race that will likely be =
fixed
>>>>> when another event comes along a little later, which would explain =
why
>>>>> we've never seen any reports.
>>>>>=20
>>>>>>> We've had set_bit and atomic_{inc,dec} in this code for ages,
>>>>>>> and I've never noticed a problem.
>>>>>>>=20
>>>>>>> Rather than adding another CPU pipeline bubble in the RDMA code,
>>>>>>> though, could you simply move the set_bit() call site inside the
>>>>>>> critical sections?
>>>>>>=20
>>>>>> er, inside the preceding critical section. Just reverse the order
>>>>>> of the spin_unlock and the set_bit.
>>>>>=20
>>>>> That'd do it, thanks!
>>>>=20
>>>> I can try that here and see if it results in a performance =
regression.
>>>=20
>>> Thanks, I've got a version with a typo fixed at
>>>=20
>>> 	git://linux-nfs.org/~bfields/linux.git nfsd-next
>>=20
>> Applied all four patches here. I don't see any performance =
regressions,
>> but my server has only a single last-level CPU cache.
>=20
> Thanks!
>=20
> I'm adding a Tested-by: for you if that's OK.

Sorry, yes! that's fine with me.



--
Chuck Lever



