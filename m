Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64211 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627Ab3GWP7m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 11:59:42 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so3008973pab.25
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jul 2013 08:59:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
	<1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
Date: Tue, 23 Jul 2013 17:59:41 +0200
Message-ID: <CAHsu+b-b=-pQ4f8AfHHDaPpAK3YvHomS3X-QuEJkzbAsuJBYfg@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap
 and attribute length
From: Andre Heider <a.heider@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Rick Macklem <rmacklem@uoguelph.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> The attribute length is already calculated in advance. There is no
> reason why we cannot calculate the bitmap in advance too so that
> we don't have to play pointer games.

I'm sorry to report that this patch seems to be more than just a cleanup.

I just tested 3.11-rc2 against my FreeBSD server, and with just patch
1/2 (as in -rc2) I still get the failure upon `touch`. It fails with
or without Rick's server patch.

Applying this one on top of -rc2 fixes it.

Regards,
Andre
