Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:37179 "EHLO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049Ab1IMGlR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 02:41:17 -0400
From: Sricharan R <r.sricharan@ti.com>
References: <CAJ7qFSeB8bAGdYfZs-LFHuYqGWNA2RidY0EBEFw_1CndvG7q5A@mail.gmail.com>
 <1315594317.17611.25.camel@lade.trondhjem.org> <dbdc7c3761a82e0b84f2f49c533c07a5@mail.gmail.com>
 <1315838509.12736.4.camel@lade.trondhjem.org> <1315842858.15975.2.camel@lade.trondhjem.org>
In-Reply-To: <1315842858.15975.2.camel@lade.trondhjem.org>
Date: Tue, 13 Sep 2011 12:11:09 +0530
Message-ID: <7c29a4c977b98cf95ef8c7f69e094896@mail.gmail.com>
Subject: RE: Regression seen when HIGHMEM enabled with NFS on 3.1rc4 kernel
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-omap@vger.kernel.org, linux-nfs@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[..]
>>
>> Can you please tell me what the mount options are for this setup?
>
>I'm guessing you've got wsize=1024, in which case, can you please try
>the following patch?
>
The mount options for nfs is rw.

Yes, in my setup wsize=1024 when the issue happened.
I tried your patch and I was not able to see the issue after that,
where as in the other case the issue happened quite frequently.
So I think that the patch fixes the issue.
Thanks a lot for your help.

>Cheers
>  Trond
>8<-----------------------------------------------------------------------
--
>-
>From 7b4a9c76b55dd254431902552528137a2ea5e55d Mon Sep 17 00:00:00 2001
>From: Trond Myklebust <Trond.Myklebust@netapp.com>
>Date: Mon, 12 Sep 2011 11:47:53 -0400
>Subject: [PATCH] NFS: Fix a typo in nfs_flush_multi
>
>Fix a typo which causes an Oops in the RPC layer, when using wsize < 4k.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
> fs/nfs/write.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>index b39b37f..c9bd2a6 100644
>--- a/fs/nfs/write.c
>+++ b/fs/nfs/write.c
>@@ -958,7 +958,7 @@ static int nfs_flush_multi(struct
nfs_pageio_descriptor
>*desc, struct list_head
> 		if (!data)
> 			goto out_bad;
> 		data->pagevec[0] = page;
>-		nfs_write_rpcsetup(req, data, wsize, offset,
desc->pg_ioflags);
>+		nfs_write_rpcsetup(req, data, len, offset,
desc->pg_ioflags);
> 		list_add(&data->list, res);
> 		requests++;
> 		nbytes -= len;
>--
>1.7.6
>
>
>
>--
>Trond Myklebust
>Linux NFS client maintainer
>
>NetApp
>Trond.Myklebust@netapp.com
>www.netapp.com
