Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32915 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbbIXM6w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:58:52 -0400
Received: by pacex6 with SMTP id ex6so72735761pac.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:58:52 -0700 (PDT)
Subject: [PATCH 8/8] NFS: Return directly if encode_sessionid fail
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F37E.1050002@gmail.com>
Date: Thu, 24 Sep 2015 20:58:38 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

encode_sessionid() may return error, nfs needs process the return value.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4ad39fe..646cdac 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -699,7 +699,9 @@ static __be32 encode_cb_sequence_res(struct svc_rqst *rqstp,
 	if (unlikely(status != 0))
 		goto out;
 
-	encode_sessionid(xdr, &res->csr_sessionid);
+	status = encode_sessionid(xdr, &res->csr_sessionid);
+	if (status)
+		goto out;
 
 	p = xdr_reserve_space(xdr, 4 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
-- 
2.5.0

