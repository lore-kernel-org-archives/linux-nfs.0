Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:63790 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab2E1RH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 13:07:26 -0400
Received: by dady13 with SMTP id y13so4351793dad.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 10:07:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1338222809.3472.13.camel@lade.trondhjem.org>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
 <1338096780-2763-4-git-send-email-bergwolf@gmail.com> <1338136717.3044.13.camel@lade.trondhjem.org>
 <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
 <1338176720.2265.8.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805F0BADF5D@MX09A.corp.emc.com>
 <1338222809.3472.13.camel@lade.trondhjem.org>
From: Peng Tao <tao.peng@emc.com>
Date: Tue, 29 May 2012 01:07:05 +0800
Message-ID: <CA+a=Yy5J8KaVNVWSwprUeZKsUMTV09C-OoaS59CUsd0ohii2OA@mail.gmail.com>
Subject: Re: [PATCH 3/3] pnfsblock: bail out unaligned DIO
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 29, 2012 at 12:33 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2012-05-28 at 00:26 -0400, tao.peng@emc.com wrote:
>> > -----Original Message-----
>> > From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
>> > Sent: Monday, May 28, 2012 11:45 AM
>> > To: Peng, Tao
>> > Cc: bergwolf@gmail.com; linux-nfs@vger.kernel.org
>> > Subject: RE: [PATCH 3/3] pnfsblock: bail out unaligned DIO
>> >
>> > On Sun, 2012-05-27 at 22:30 -0400, tao.peng@emc.com wrote:
>> > > As explain in the other mail, it is necessary to have pnfs_dio_begin/end, so I prefer to do the test
>> > as early as possible, which is in pnfs_dio_begin.
>> >
>> > There is no pnfs_dio_begin/end.
>> OK. I will put DIO alignment tests inside pg_init.
>>
>> And any comments on for stable patch in the thread ([PATCH] pnfsblock: bail out page unaligned IO)? If you agree, I will base DIO changes on top of it to avoid conflicts.
>> There are reasons to test alignment at different place for buffer IO and DIO. For buffer IO, pg_init isn't the right place because we don't have nfs page there. For DIO, pg_test isn't the right place because we need to check cross page boundary.
>
> Since all pages in the struct nfs_pageio_descriptor are guaranteed to be
> contiguous, you really only need to check the first and last page in the
> series for alignment.
>
> pg_init() does take the first nfs_page request as its argument and so it
> should be possible to check the alignment of the first page in the
> series there.
> You can then check the alignment of the last page in your
> ->write_pagelist() and return PNFS_NOT_ATTEMPTED if appropriate.
>
Thanks. Will do it as you suggested.

> Note that all applications that use O_DIRECT are expected to use aligned
> memory, since that's what the open() manpage implies is the safe option
> for all filesystems. Unaligned memory is therefore not something that we
> need to optimise for.
>
do_blockdev_direct_IO() is checking memory alignment for direct IO. Is
there any difference between NFS and other FS here?

Cheers,
Tao
