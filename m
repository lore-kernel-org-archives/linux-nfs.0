Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:42936 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751024Ab2CAWAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:00:49 -0500
Received: by mail-tul01m020-f174.google.com with SMTP id uo6so901220obb.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:00:49 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/15] NFS: Reduce debugging noise from encode_compound_hdr
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:00:48 -0500
Message-ID: <20120301220048.2138.1342.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of

  encode_compound: tag=

when XDR debugging is enabled.  The current Linux client never sets
compound tags.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4ca87cb..d1b7914d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -889,7 +889,9 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	 * but this is not required as a MUST for the server to do so. */
 	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
 
+#if 0
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
+#endif
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	p = reserve_space(xdr, 4 + hdr->taglen + 8);
 	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);

