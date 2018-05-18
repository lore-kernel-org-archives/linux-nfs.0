Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:45938 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbeEROfj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 10:35:39 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Regression in [v2] nfs: Fix ugly referral attributes ?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <204712da-d456-8134-00af-735769cd74dd@uni-mainz.de>
Date: Fri, 18 May 2018 10:35:11 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        898165-forwarded@bugs.debian.org, 898165@bugs.debian.org,
        ben@decadent.org.uk, Pradeep <pradeepthomas@gmail.com>,
        Christoph Martin <martin@uni-mainz.de>
Message-Id: <3FC07091-70EF-49DC-9674-C44A4DE0DC75@oracle.com>
References: <20171105204404.10847.33767.stgit@manet.1015granger.net>
 <19d4d696-3abc-42cd-28fb-86a24b572ddd@uni-mainz.de>
 <832B58A4-C78E-44D4-AF79-31A619456106@oracle.com>
 <204712da-d456-8134-00af-735769cd74dd@uni-mainz.de>
To: Moritz Schlarb <schlarbm@uni-mainz.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 17, 2018, at 5:48 PM, Moritz Schlarb <schlarbm@uni-mainz.de> =
wrote:
>=20
> Hi Chuck,
>=20
> On 17.05.2018 16:15, Chuck Lever wrote:
>=20
>> Just a shot in the dark: Wondering if v3.16 needs
>>=20
>> commit ea96d1ecbe4fcb1df487d99309d3157b4ff5fc02
>> Author:     Anna Schumaker <Anna.Schumaker@netapp.com>
>> AuthorDate: Fri Apr 3 14:35:59 2015 -0400
>> Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
>> CommitDate: Thu Apr 23 14:43:54 2015 -0400
>>=20
>>    nfs: Fetch MOUNTED_ON_FILEID when updating an inode
>=20
> Gosh, it seems you're right!
> When I take that patch and apply it, the referrals are being followed =
again!
>=20
> Thanks for your idea!
> Now how do we make sure it gets applied soonish?

Hi Moritz-

Anyone (including you or your distributor) can request that this
patch be applied to the upstream v3.16 LTS branch. Since you have
confirmed that it applies and fixes your problem, it would be
appropriate to report that along with your backport request.


--
Chuck Lever



