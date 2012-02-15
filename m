Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37226 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab2BOVfn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:35:43 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so1972889iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:35:43 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/13] NFS: Reduce debugging noise from encode_compound_hdr
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:35:42 -0500
Message-ID: <20120215213542.3254.50291.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When NFSDBG_XDR debugging is enabled, I see a lot of

  encode_compound: tag=

on the console.  This is noise if the tag is empty.  Some might argue
that it is noise even if the tag isn't empty...

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 606852a..2fb129d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -889,7 +889,9 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	 * but this is not required as a MUST for the server to do so. */
 	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
 
-	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
+	if (unlikely(hdr->taglen != 0))
+		dprintk("%s: tag=%.*s\n", __func__,
+				(int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	p = reserve_space(xdr, 4 + hdr->taglen + 8);
 	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);

