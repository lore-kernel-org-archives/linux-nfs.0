Return-Path: <SRS0=O3Iw=PW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0879AC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Jan 2019 17:24:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CB5302070B
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Jan 2019 17:24:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="cZ3a61gT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726706AbfANRYd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Jan 2019 12:24:33 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:54990 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726646AbfANRYd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2019 12:24:33 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0EHOK5u116614;
        Mon, 14 Jan 2019 17:24:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=W4mMutscSVfo2xhomTdGllmEIJ08BJyk8/lZYjAoN7U=;
 b=cZ3a61gTntEthotxVZDRe277meIzkQOJ+8/bnkhhHHR4WjGRZw7+1vNBi8TJVENBuScT
 FXgoWe0oD2trke0knilT82jKWfzgjE8KttoBAcNhKocT6JEZ5xT/GwLJH+eQZ9Idbzs5
 Pcyy6TqDMQ9qkp5xHI8Q1pM5JCqpY5sr/ONgnNgKr12vn6pyNKfTMqHwE/VTPxcIqCxI
 kl1AyVcuCzG6ZjTwqAGmVc4O8IwKMzaPiaUbciIkXq3leO9+9v5Duq0+GXPRBi1WSXr+
 NGeqZtiDlly9fWxWyR0MWFBlI0epV4LWJ7C544tA6pLoaU+13ng6IhFH+5Z+/24ZvU8F 9A== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2pybkc6u7b-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 14 Jan 2019 17:24:28 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0EHORes001160
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 14 Jan 2019 17:24:28 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0EHOPUX014926;
        Mon, 14 Jan 2019 17:24:27 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 14 Jan 2019 09:24:25 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190112005613.GA29181@fieldses.org>
Date:   Mon, 14 Jan 2019 12:24:24 -0500
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F21839E5-A5DB-4BC8-8F3B-2AD02D4B2652@oracle.com>
References: <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
 <20190108150107.GA15921@fieldses.org>
 <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
 <20190109165142.GB32189@fieldses.org>
 <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
 <20190111211235.GA27206@fieldses.org>
 <BB7240BE-3F20-43AD-B709-7F18CC33CC02@oracle.com>
 <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
 <20190111221030.GA28794@fieldses.org>
 <A33F8CE5-3E5D-4359-8061-8DB8214B012B@oracle.com>
 <20190112005613.GA29181@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9136 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=879
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901140141
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 11, 2019, at 7:56 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Fri, Jan 11, 2019 at 05:27:30PM -0500, Chuck Lever wrote:
>>=20
>>=20
>>> On Jan 11, 2019, at 5:10 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> On Fri, Jan 11, 2019 at 04:54:01PM -0500, Chuck Lever wrote:
>>>>> On Jan 11, 2019, at 4:52 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>>>> So, I think we need your patch plus something like this.
>>>>>>=20
>>>>>> Chuck, maybe you could help me with the "XXX: Chuck:" parts?
>>>>>=20
>>>>> I haven't been following. Why do you think those are necessary?
>>>=20
>>> I'm worried something like this could happen:
>>>=20
>>> 	CPU 1				CPU 2
>>> 	-----				-----
>>>=20
>>> 	set XPT_DATA			dec xpt_nr_rqsts
>>>=20
>>> 	svc_xprt_enqueue		svc_xprt_enqueue
>>>=20
>>> And both decide nothing should be done if neither sees the change =
that
>>> the other made.
>>>=20
>>> Maybe I'm still missing some reason that couldn't happen.
>>>=20
>>> Even if it can happen, it's an unlikely race that will likely be =
fixed
>>> when another event comes along a little later, which would explain =
why
>>> we've never seen any reports.
>>>=20
>>>>> We've had set_bit and atomic_{inc,dec} in this code for ages,
>>>>> and I've never noticed a problem.
>>>>>=20
>>>>> Rather than adding another CPU pipeline bubble in the RDMA code,
>>>>> though, could you simply move the set_bit() call site inside the
>>>>> critical sections?
>>>>=20
>>>> er, inside the preceding critical section. Just reverse the order
>>>> of the spin_unlock and the set_bit.
>>>=20
>>> That'd do it, thanks!
>>=20
>> I can try that here and see if it results in a performance =
regression.
>=20
> Thanks, I've got a version with a typo fixed at
>=20
> 	git://linux-nfs.org/~bfields/linux.git nfsd-next

Applied all four patches here. I don't see any performance regressions,
but my server has only a single last-level CPU cache.


--
Chuck Lever



