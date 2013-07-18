Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:64678 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab3GRO4R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 10:56:17 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so3169110pde.37
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jul 2013 07:56:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
	<1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 18 Jul 2013 16:56:17 +0200
Message-ID: <CAHsu+b-rnxqTSBfg=cn_gCR-Jv83U3ks96b6c0AF-uLzj0UFGQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap
 and attribute length
From: Andre Heider <a.heider@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Rick Macklem <rmacklem@uoguelph.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> The attribute length is already calculated in advance. There is no
> reason why we cannot calculate the bitmap in advance too so that
> we don't have to play pointer games.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Tested-by: Andre Heider <a.heider@gmail.com>
