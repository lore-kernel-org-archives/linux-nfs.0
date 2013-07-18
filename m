Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:49812 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab3GROzy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 10:55:54 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so3320300pad.37
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jul 2013 07:55:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 18 Jul 2013 16:55:54 +0200
Message-ID: <CAHsu+b_FuHaa9LG1vRv1d5LwA5Ue_Ss2eoJsKEC5dx-rnuApOg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix a regression against the FreeBSD server
From: Andre Heider <a.heider@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Rick Macklem <rmacklem@uoguelph.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> Technically, the Linux client is allowed by the NFSv4 spec to send
> 3 word bitmaps as part of an OPEN request. However, this causes the
> current FreeBSD server to return NFS4ERR_ATTRNOTSUPP errors.
>
> Fix the regression by making the Linux client use a 2 word bitmap unless
> doing NFSv4.2 with labeled NFS.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Tested-by: Andre Heider <a.heider@gmail.com>
