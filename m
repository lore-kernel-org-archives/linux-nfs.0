Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45914 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521AbaE2O5k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 10:57:40 -0400
Received: by mail-ie0-f180.google.com with SMTP id tp5so401841ieb.11
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 07:57:40 -0700 (PDT)
Message-ID: <1401375457.6543.1.camel@leira.trondhjem.org>
Subject: Re: [nfs:devel 41/48] nls_iso8859-1.c:undefined reference to
 `__aeabi_uldivmod'
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 29 May 2014 10:57:37 -0400
In-Reply-To: <538745be.7mlU/ffncT1nxA17%fengguang.wu@intel.com>
References: <538745be.7mlU/ffncT1nxA17%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-05-29 at 22:35 +0800, kbuild test robot wrote:
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
> head:   c75c3b0bfffdb21daecb7dadbd30eb2e353fe66d
> commit: fa1165eda0eeaee57c292df3af1c98e10223f0f5 [41/48] pnfs: filelayout: support non page aligned layouts
> config: make ARCH=arm kzm9g_defconfig
> 
> All error/warnings:
> 
>    fs/built-in.o: In function `filelayout_pg_test':
> >> nls_iso8859-1.c:(.text+0x9cf3c): undefined reference to `__aeabi_uldivmod'
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

Hi Dros,

I'm applying the following patch to fix this up:

>From 64060d5dd6bf8d6d611c342f9a42a2ad7640ed4a Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 29 May 2014 10:49:12 -0400
Subject: [PATCH] fixup! pnfs: filelayout: support non page aligned layouts

---
 fs/nfs/nfs4filelayout.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9419061b6d1b..63a16375660a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -950,7 +950,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	stripe_offset = ((u64)req_offset(req) - segment_offset) % stripe_unit;
+	div_u64_rem((u64)req_offset(req) - segment_offset,
+			stripe_unit,
+			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
 	if (stripe_offset >= stripe_unit)
 		return 0;
-- 
1.9.3



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


