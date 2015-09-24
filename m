Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35350 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbbIXM5u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:57:50 -0400
Received: by pacfv12 with SMTP id fv12so73917833pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:57:49 -0700 (PDT)
Subject: [PATCH 5/8] NFS: Use NFS4_MAX_SESSIONID_LEN directly for
 decode/encode sessionid
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F341.1050605@gmail.com>
Date: Thu, 24 Sep 2015 20:57:37 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's no need to define a temporary variables for NFS4_MAX_SESSIONID_LEN.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e87d7f0..09aeb9a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -380,13 +380,12 @@ static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
 	__be32 *p;
-	int len = NFS4_MAX_SESSIONID_LEN;
 
-	p = read_buf(xdr, len);
+	p = read_buf(xdr, NFS4_MAX_SESSIONID_LEN);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 
-	memcpy(sid->data, p, len);
+	memcpy(sid->data, p, NFS4_MAX_SESSIONID_LEN);
 	return 0;
 }
 
@@ -679,13 +678,12 @@ static __be32 encode_sessionid(struct xdr_stream *xdr,
 				 const struct nfs4_sessionid *sid)
 {
 	__be32 *p;
-	int len = NFS4_MAX_SESSIONID_LEN;
 
-	p = xdr_reserve_space(xdr, len);
+	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 
-	memcpy(p, sid, len);
+	memcpy(p, sid, NFS4_MAX_SESSIONID_LEN);
 	return 0;
 }
 
-- 
2.5.0

