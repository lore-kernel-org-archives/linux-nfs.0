Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:65475 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaE3A2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 20:28:20 -0400
Received: by mail-ie0-f180.google.com with SMTP id tp5so1097163ieb.11
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 17:28:19 -0700 (PDT)
Message-ID: <1401409695.7587.3.camel@leira.trondhjem.org>
Subject: Re: [nfs:testing 48/48] fs/nfs/filelayout/filelayout.c:1351
 filelayout_alloc_layout_hdr() error: potential null dereference 'flo'.
 (kzalloc returns null)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 29 May 2014 20:28:15 -0400
In-Reply-To: <5387ad28.m0xKsvjghVV/maKQ%fengguang.wu@intel.com>
References: <5387ad28.m0xKsvjghVV/maKQ%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-05-30 at 05:56 +0800, kbuild test robot wrote:
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   a27d2ba9829d092f64076231629ba9bd576facbf
> commit: a27d2ba9829d092f64076231629ba9bd576facbf [48/48] Push the file layout driver into a subdirectory
> 
> fs/nfs/filelayout/filelayout.c:1351 filelayout_alloc_layout_hdr() error: potential null dereference 'flo'.  (kzalloc returns null)
> 
> vim +/flo +1351 fs/nfs/filelayout/filelayout.c
> 

Hi Tom,

Looks like your rename unearthed an old skeleton from the closet. I'm
applying the following patch before yours in order to fix it.

Cheers
  Trond

8<------------------------------------------------
>From 6df200f5d5191bdde4d2e408215383890f956781 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 29 May 2014 20:06:55 -0400
Subject: [PATCH 1/2] pNFS: Handle allocation errors correctly in
 filelayout_alloc_layout_hdr()

Return the NULL pointer when the allocation fails.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: <stable@vger.kernel.org> # 3.5.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4filelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 63a16375660a..21e921147d21 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -1348,7 +1348,7 @@ filelayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 	struct nfs4_filelayout *flo;
 
 	flo = kzalloc(sizeof(*flo), gfp_flags);
-	return &flo->generic_hdr;
+	return flo != NULL ? &flo->generic_hdr : NULL;
 }
 
 static void
-- 
1.9.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


