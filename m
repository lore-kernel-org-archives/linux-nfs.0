Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ironport-1.zdv.net ([134.93.178.241]:12191 "EHLO
        ironport-1.zdv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbeEQVsY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2018 17:48:24 -0400
Subject: Re: Regression in [v2] nfs: Fix ugly referral attributes ?
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        <898165-forwarded@bugs.debian.org>, <898165@bugs.debian.org>,
        <ben@decadent.org.uk>, Pradeep <pradeepthomas@gmail.com>,
        Christoph Martin <martin@uni-mainz.de>
References: <20171105204404.10847.33767.stgit@manet.1015granger.net>
 <19d4d696-3abc-42cd-28fb-86a24b572ddd@uni-mainz.de>
 <832B58A4-C78E-44D4-AF79-31A619456106@oracle.com>
From: Moritz Schlarb <schlarbm@uni-mainz.de>
Message-ID: <204712da-d456-8134-00af-735769cd74dd@uni-mainz.de>
Date: Thu, 17 May 2018 23:48:21 +0200
MIME-Version: 1.0
In-Reply-To: <832B58A4-C78E-44D4-AF79-31A619456106@oracle.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 17.05.2018 16:15, Chuck Lever wrote:

> Just a shot in the dark: Wondering if v3.16 needs
> 
> commit ea96d1ecbe4fcb1df487d99309d3157b4ff5fc02
> Author:     Anna Schumaker <Anna.Schumaker@netapp.com>
> AuthorDate: Fri Apr 3 14:35:59 2015 -0400
> Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
> CommitDate: Thu Apr 23 14:43:54 2015 -0400
> 
>     nfs: Fetch MOUNTED_ON_FILEID when updating an inode

Gosh, it seems you're right!
When I take that patch and apply it, the referrals are being followed again!

Thanks for your idea!
Now how do we make sure it gets applied soonish?

Regards,
Moritz
