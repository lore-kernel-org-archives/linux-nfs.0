Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55072 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab0LNO6Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:58:24 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so374133gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:58:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/31] NFS: Squelch compiler warning in decode_getdeviceinfo()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:21 -0500
Message-ID: <20101214145821.2293.84825.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

.../linux/nfs-2.6/fs/nfs/nfs4xdr.c: In function ‘decode_getdeviceinfo’:
.../linux/nfs-2.6/fs/nfs/nfs4xdr.c:5008: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index be9f00a..a15fe99 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5000,7 +5000,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		goto out_overflow;
 	len = be32_to_cpup(p);
 	if (len) {
-		int i;
+		uint32_t i;
 
 		p = xdr_inline_decode(xdr, 4 * len);
 		if (unlikely(!p))

