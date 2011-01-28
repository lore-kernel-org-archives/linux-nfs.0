Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40005 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061Ab1A1Rk6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 12:40:58 -0500
Received: by qwa26 with SMTP id 26so3545054qwa.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 Jan 2011 09:40:58 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFS: Micro-optimize nfs4_decode_dirent()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 28 Jan 2011 12:40:55 -0500
Message-ID: <20110128174055.3235.83374.stgit@matisse.1015granger.net>
In-Reply-To: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
References: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make the decoding of NFSv4 directory entries slightly more efficient
by:

  1.  Avoiding unnecessary byte swapping when checking XDR booleans,
      and

  2.  Not bumping "p" when its value will be immediately replaced by
      xdr_inline_decode()

This commit makes nfs4_decode_dirent() consistent with similar logic
in the other two decode_dirent() functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2ab8e5c..009aef9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6086,11 +6086,11 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	if (!ntohl(*p++)) {
+	if (*p == xdr_zero) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		if (!ntohl(*p++))
+		if (*p == xdr_zero)
 			return -EAGAIN;
 		entry->eof = 1;
 		return -EBADCOOKIE;
@@ -6101,7 +6101,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		goto out_overflow;
 	entry->prev_cookie = entry->cookie;
 	p = xdr_decode_hyper(p, &entry->cookie);
-	entry->len = ntohl(*p++);
+	entry->len = be32_to_cpup(p);
 
 	p = xdr_inline_decode(xdr, entry->len);
 	if (unlikely(!p))

