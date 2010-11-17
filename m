Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52633 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935214Ab0KQSA6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:00:58 -0500
Received: by mail-iw0-f174.google.com with SMTP id 35so2387538iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:00:58 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/12] NFS: Squelch compiler warning in decode_getdeviceinfo()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:00:55 -0500
Message-ID: <20101117180054.29429.21780.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
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
index f77b08d..1daff25 100644
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

